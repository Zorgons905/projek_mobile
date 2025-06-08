import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../pages/simple_cropper_page.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';
import '../models/profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.role, required this.id});

  final String id;
  final String role;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthService();
  final _profileService = ProfileService();
  final _storageService = StorageService();

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();

  bool _loading = false;
  bool _loadingImage = false;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    _profile = await _profileService.getProfile(widget.id);
    if (_profile != null) {
      _nameController.text = _profile!.name ?? '';
      _bioController.text = _profile!.bio ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);
    await _profileService.updateProfile(
      id: widget.id,
      name: _nameController.text,
      bio: _bioController.text,
    );
    await _loadProfile();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Profil berhasil diperbarui")),
    );
    setState(() => _loading = false);
  }

  Future<void> _changePassword() async {
    setState(() => _loading = true);
    try {
      await _auth.changePassword(
        email: _auth.getCurrentUserEmail()!,
        oldPassword: _oldPassController.text,
        newPassword: _newPassController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Password berhasil diganti")),
      );
      _oldPassController.clear();
      _newPassController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Gagal ganti password: $e")));
    }
    setState(() => _loading = false);
  }

  void _onProfilePictureTap() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Ganti Foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _editProfilePicture();
                  },
                ),
                if (_profile?.profilePictureUrl != null)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Hapus Foto'),
                    onTap: () {
                      Navigator.pop(context);
                      _deleteProfilePicture();
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _deleteProfilePicture() async {
    setState(() => _loadingImage = true);
    try {
      final userId = _auth.getCurrentUserID();
      final oldUrl = _profile?.profilePictureUrl;

      if (oldUrl != null) {
        final path = _extractPathFromUrl(oldUrl);

        // Hapus dari storage
        await _storageService.deleteFile(bucket: 'user-pictures', path: path);

        // Set URL ke null di database
        await _profileService.updateProfile(
          id: userId,
          profilePictureUrl: null,
        );

        setState(() {
          _profile = _profile!.copyWith(profilePictureUrl: null);
        });
        await _loadProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Foto profil berhasil dihapus")),
        );
      }
    } catch (e) {
      debugPrint("❌ Gagal menghapus foto profil: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Gagal menghapus foto profil: $e")),
      );
    } finally {
      setState(() => _loadingImage = false);
    }
  }

  String _extractPathFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final index = segments.indexOf('user-pictures');
    if (index != -1 && index + 1 < segments.length) {
      return segments.sublist(index + 1).join('/');
    }
    return '';
  }

  Future<void> _editProfilePicture() async {
    final croppedBytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (_) => const SimpleCropperPage()),
    );

    if (croppedBytes == null) return;

    setState(() => _loadingImage = true);

    final userId = _auth.getCurrentUserID();
    final oldUrl = _profile?.profilePictureUrl;

    try {
      if (oldUrl != null) {
        final oldPath = _extractPathFromUrl(oldUrl);
        await _storageService.deleteFile(
          bucket: 'user-pictures',
          path: oldPath,
        );
      }

      final newPath =
          '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newUrl = await _storageService.uploadBytes(
        bytes: croppedBytes,
        bucket: 'user-pictures',
        path: newPath,
      );

      if (newUrl != null) {
        await _profileService.updateProfile(
          id: userId,
          profilePictureUrl: newUrl,
        );
        setState(() {
          _profile = _profile!.copyWith(profilePictureUrl: newUrl);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Foto profil berhasil diperbarui")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Gagal mengganti foto: $e")));
    } finally {
      setState(() => _loadingImage = false);
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ganti Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _oldPassController,
                decoration: const InputDecoration(labelText: "Password Lama"),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newPassController,
                decoration: const InputDecoration(labelText: "Password Baru"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _changePassword();
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Widget _editableFieldCard({
    required String label,
    required TextEditingController controller,
    required VoidCallback onSave,
  }) {
    bool isEditing = false;
    final originalText = controller.text;

    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                      isEditing
                          ? TextField(
                            controller: controller,
                            decoration: InputDecoration(labelText: label),
                          )
                          : ListTile(
                            title: Text(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            subtitle: Text(
                              controller.text.isEmpty
                                  ? 'Belum diisi'
                                  : controller.text,
                            ),
                          ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        isEditing ? Icons.check : Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(6),
                      ),
                      onPressed: () {
                        if (isEditing) {
                          onSave();
                        }
                        setState(() => isEditing = !isEditing);
                      },
                    ),
                    if (isEditing)
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.all(6),
                        ),
                        onPressed: () {
                          controller.text = originalText;
                          setState(() => isEditing = false);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_profile!.profilePictureUrl != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProfilePicturePreviewPage(
                                imageUrl: _profile!.profilePictureUrl!,
                              ),
                        ),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _profile!.profilePictureUrl != null
                            ? NetworkImage(_profile!.profilePictureUrl!)
                            : null,
                    child:
                        _profile!.profilePictureUrl == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                  ),
                ),
                if (_loadingImage)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _onProfilePictureTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// === NAMA ===
            _editableFieldCard(
              label: 'Nama',
              controller: _nameController,
              onSave: _updateProfile,
            ),
            const SizedBox(height: 16),

            /// === BIO ===
            _editableFieldCard(
              label: 'Bio',
              controller: _bioController,
              onSave: _updateProfile,
            ),

            const SizedBox(height: 32),

            /// === PASSWORD ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showChangePasswordDialog(context),
                  icon: const Icon(Icons.lock, color: Colors.white),
                  label: const Text(
                    "Ganti Password",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () => _auth.signOut(),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Keluar",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePicturePreviewPage extends StatelessWidget {
  final String imageUrl;
  const ProfilePicturePreviewPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Center(child: InteractiveViewer(child: Image.network(imageUrl))),
    );
  }
}

  // String userName = "";
  // String userBio = "";
  // String userEmail = "";
  // String userRole = "";
  // String joinDate = "";
  // bool isLoading = false;

  // final _profileService = ProfileService();
  // final _authService = AuthService();

  // Future<void> _loadUserData() async {
  //   setState(() => isLoading = true);
  //   try {
  //     final data = await _profileService.fetchUserData();
  //     final email = _authService.getCurrentUserEmail();

  //     if (data != null) {
  //       setState(() {
  //         userName = data['name'] ?? '';
  //         userBio = data['bio'] ?? '';
  //         userRole = data['role'] ?? '';
  //         userEmail = email ?? '';
  //         final createdAt = data['created_at'];
  //         if (createdAt != null) {
  //           final date = DateTime.parse(createdAt);
  //           joinDate = "Bergabung sejak ${date.month} ${date.year}";
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Error loading user data: $e');
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _loadUserData();
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.grey[50],
  //     body: Column(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.only(
  //             top: 40,
  //             left: 20,
  //             right: 20,
  //             bottom: 30,
  //           ),
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //               colors: [Colors.blue[700]!, Colors.blue[500]!],
  //             ),
  //           ),
  //           child: Column(
  //             children: [
  //               // Header with back button
  //               Center(
  //                 child: Text(
  //                   'Profil Saya',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),

  //               const SizedBox(height: 20),

  //               // Profile Picture with Edit Button
  //               Stack(
  //                 children: [
  //                   Container(
  //                     width: 120,
  //                     height: 120,
  //                     decoration: BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       border: Border.all(color: Colors.white, width: 4),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.black.withOpacity(0.2),
  //                           blurRadius: 10,
  //                           offset: const Offset(0, 4),
  //                         ),
  //                       ],
  //                     ),
  //                     child: CircleAvatar(
  //                       radius: 56,
  //                       backgroundColor: Colors.grey[300],
  //                       backgroundImage:
  //                           null, // Add NetworkImage or AssetImage here
  //                       child: Icon(
  //                         Icons.person,
  //                         size: 60,
  //                         color: Colors.grey[600],
  //                       ),
  //                     ),
  //                   ),
  //                   Positioned(
  //                     bottom: 0,
  //                     right: 0,
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         _showEditProfilePictureDialog();
  //                       },
  //                       child: Container(
  //                         width: 36,
  //                         height: 36,
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           shape: BoxShape.circle,
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: Colors.black.withOpacity(0.2),
  //                               blurRadius: 4,
  //                               offset: const Offset(0, 2),
  //                             ),
  //                           ],
  //                         ),
  //                         child: Icon(
  //                           Icons.camera_alt,
  //                           size: 18,
  //                           color: Colors.blue[700],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),

  //         // Profile Content
  //         Expanded(
  //           child: SingleChildScrollView(
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Username Section
  //                 _buildEditableSection(
  //                   icon: Icons.person_outline,
  //                   label: "Nama Pengguna",
  //                   value: userName,
  //                   onEdit:
  //                       () =>
  //                           _showEditDialog("Nama Pengguna", userName, (value) {
  //                             setState(() {
  //                               userName = value;
  //                             });
  //                           }),
  //                 ),

  //                 const SizedBox(height: 20),

  //                 // Bio Section
  //                 _buildEditableSection(
  //                   icon: Icons.info_outline,
  //                   label: "Bio",
  //                   value: userBio,
  //                   isMultiline: true,
  //                   onEdit:
  //                       () => _showEditDialog("Bio", userBio, (value) {
  //                         setState(() {
  //                           userBio = value;
  //                         });
  //                       }),
  //                 ),

  //                 const SizedBox(height: 20),

  //                 // Email Section (Read-only)
  //                 _buildInfoSection(
  //                   icon: Icons.email_outlined,
  //                   label: "Email",
  //                   value: userEmail,
  //                 ),

  //                 const SizedBox(height: 20),

  //                 // Role Section (Read-only)
  //                 _buildInfoSection(
  //                   icon: Icons.school_outlined,
  //                   label: "Peran",
  //                   value: userRole,
  //                 ),

  //                 const SizedBox(height: 20),

  //                 // Join Date Section (Read-only)
  //                 _buildInfoSection(
  //                   icon: Icons.calendar_today_outlined,
  //                   label: "Bergabung",
  //                   value: joinDate,
  //                 ),

  //                 const SizedBox(height: 40),

  //                 // Settings Section
  //                 Container(
  //                   width: double.infinity,
  //                   padding: const EdgeInsets.all(20),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(12),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.05),
  //                         blurRadius: 8,
  //                         offset: const Offset(0, 2),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         'Pengaturan',
  //                         style: TextStyle(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey[800],
  //                         ),
  //                       ),
  //                       const SizedBox(height: 16),

  //                       // Change Password Button
  //                       _buildSettingButton(
  //                         icon: Icons.lock_outline,
  //                         title: "Ubah Kata Sandi",
  //                         onTap: () {
  //                           _showChangePasswordDialog();
  //                         },
  //                       ),

  //                       const SizedBox(height: 12),

  //                       // Notification Settings Button
  //                       _buildSettingButton(
  //                         icon: Icons.notifications_outlined,
  //                         title: "Pengaturan Notifikasi",
  //                         onTap: () {
  //                           // Navigate to notification settings
  //                         },
  //                       ),

  //                       const SizedBox(height: 12),

  //                       // About Button
  //                       _buildSettingButton(
  //                         icon: Icons.help_outline,
  //                         title: "Tentang Aplikasi",
  //                         onTap: () {
  //                           _showAboutDialog();
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),

  //                 const SizedBox(height: 30),

  //                 // Sign Out Button
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       _showSignOutDialog();
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.red[600],
  //                       foregroundColor: Colors.white,
  //                       padding: const EdgeInsets.symmetric(vertical: 16),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       elevation: 2,
  //                     ),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(Icons.logout, size: 20),
  //                         const SizedBox(width: 8),
  //                         Text(
  //                           'Keluar',
  //                           style: TextStyle(
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 20),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildEditableSection({
  //   required IconData icon,
  //   required String label,
  //   required String value,
  //   required VoidCallback onEdit,
  //   bool isMultiline = false,
  // }) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Colors.blue[50],
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(icon, color: Colors.blue[700], size: 20),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 label,
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: Colors.grey[600],
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 value,
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: Colors.grey[800],
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //                 maxLines: isMultiline ? null : 1,
  //                 overflow: isMultiline ? null : TextOverflow.ellipsis,
  //               ),
  //             ],
  //           ),
  //         ),
  //         GestureDetector(
  //           onTap: onEdit,
  //           child: Container(
  //             padding: const EdgeInsets.all(6),
  //             decoration: BoxDecoration(
  //               color: Colors.blue[700],
  //               borderRadius: BorderRadius.circular(6),
  //             ),
  //             child: Icon(Icons.edit, size: 16, color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildInfoSection({
  //   required IconData icon,
  //   required String label,
  //   required String value,
  // }) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Colors.grey[100],
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(icon, color: Colors.grey[600], size: 20),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 label,
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: Colors.grey[600],
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 value,
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: Colors.grey[800],
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSettingButton({
  //   required IconData icon,
  //   required String title,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
  //       child: Row(
  //         children: [
  //           Icon(icon, color: Colors.grey[600], size: 22),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Text(
  //               title,
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: Colors.grey[800],
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ),
  //           Icon(Icons.chevron_right, color: Colors.grey[400]),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showEditDialog(
  //   String field,
  //   String currentValue,
  //   Function(String) onSave,
  // ) {
  //   final controller = TextEditingController(text: currentValue);

  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Text('Edit $field'),
  //           content: TextField(
  //             controller: controller,
  //             maxLines: field == 'Bio' ? 3 : 1,
  //             decoration: InputDecoration(
  //               hintText: 'Masukkan $field baru',
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text('Batal'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 final newValue = controller.text.trim();
  //                 if (newValue.isEmpty) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text('$field tidak boleh kosong')),
  //                   );
  //                   return;
  //                 }

  //                 final dbField = (field == "Nama Pengguna") ? "name" : "bio";
  //                 final success = await _profileService.updateUserField(
  //                   dbField,
  //                   newValue,
  //                 );

  //                 if (success) {
  //                   onSave(newValue);
  //                   Navigator.pop(context);
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text('$field berhasil diperbarui')),
  //                   );
  //                 } else {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text('Gagal memperbarui $field')),
  //                   );
  //                 }
  //               },
  //               child: Text('Simpan'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  // void _showEditProfilePictureDialog() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder:
  //         (context) => Container(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 'Ubah Foto Profil',
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //               ),
  //               const SizedBox(height: 20),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   _buildPhotoOption(
  //                     icon: Icons.camera_alt,
  //                     label: 'Kamera',
  //                     onTap: () {
  //                       Navigator.pop(context);
  //                       // Implement camera functionality
  //                     },
  //                   ),
  //                   _buildPhotoOption(
  //                     icon: Icons.photo_library,
  //                     label: 'Galeri',
  //                     onTap: () {
  //                       Navigator.pop(context);
  //                       // Implement gallery functionality
  //                     },
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 20),
  //             ],
  //           ),
  //         ),
  //   );
  // }

  // Widget _buildPhotoOption({
  //   required IconData icon,
  //   required String label,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Column(
  //       children: [
  //         Container(
  //           width: 60,
  //           height: 60,
  //           decoration: BoxDecoration(
  //             color: Colors.blue[50],
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(icon, color: Colors.blue[700], size: 30),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
  //       ],
  //     ),
  //   );
  // }

  // void _showChangePasswordDialog() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Text('Ubah Kata Sandi'),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 obscureText: true,
  //                 decoration: InputDecoration(
  //                   labelText: 'Kata Sandi Lama',
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 12),
  //               TextField(
  //                 obscureText: true,
  //                 decoration: InputDecoration(
  //                   labelText: 'Kata Sandi Baru',
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 12),
  //               TextField(
  //                 obscureText: true,
  //                 decoration: InputDecoration(
  //                   labelText: 'Konfirmasi Kata Sandi Baru',
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text('Batal'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 // Implement change password logic
  //               },
  //               child: Text('Ubah'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  // void _showAboutDialog() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Text('Tentang READAILY'),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text('READAILY v1.0.0'),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Aplikasi untuk mengelola dan membaca buku digital dengan mudah.',
  //               ),
  //               const SizedBox(height: 12),
  //               Text('© 2024 READAILY Team'),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text('Tutup'),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  // void _showSignOutDialog() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Text('Keluar'),
  //           content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text('Batal'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 try {
  //                   if (mounted) {
  //                     Navigator.pop(context);
  //                     _authService.signOut();
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                         content: Text('Berhasil keluar dari aplikasi'),
  //                         backgroundColor: Colors.green,
  //                       ),
  //                     );
  //                   }
  //                 } catch (e) {
  //                   if (mounted) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                         content: Text('Gagal keluar: $e'),
  //                         backgroundColor: Colors.red,
  //                       ),
  //                     );
  //                   }
  //                 }
  //               },
  //               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //               child: Text('Keluar', style: TextStyle(color: Colors.white)),
  //             ),
  //           ],
  //         ),
  //   );
  // }
