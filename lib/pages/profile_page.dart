import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:test123/pages/simple_cropper_page.dart';
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
