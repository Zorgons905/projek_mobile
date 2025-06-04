// lib/auth/signup_page.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authService = AuthService();

  final _usernameController = TextEditingController(); // Ini akan digunakan untuk Full Name
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? _selectedRole; // State untuk menyimpan peran yang dipilih

  // List of roles for the dropdown
  final List<String> _roles = ["Dosen", "Mahasiswa"];

  // Warna dan gaya umum (konsisten dengan desain gambar)
  final Color primaryBlue = const Color(0xFF1E88E5); // Warna biru yang dominan
  final Color lightBlue = const Color(0xFFBBDEFB); // Warna biru muda untuk field background
  final TextStyle buttonTextStyle = const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
  final TextStyle linkTextStyle = const TextStyle(color: Colors.grey, fontSize: 14);

  void signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords don't match")),
        );
      }
      return;
    }
    if (_selectedRole == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a role (Dosen/Mahasiswa)")),
        );
      }
      return;
    }

    setState(() => isLoading = true);
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signUpWithEmailPassword(email, password, username);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful! Please login.")),
        );
        Navigator.pop(context); // Kembali ke halaman login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine padding based on screen width for larger screens
    final horizontalPadding = screenWidth > 600 ? screenWidth * 0.1 : 30.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Pastikan ini true (default)
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  // Responsive header height, with a cap for very tall screens
                  height: screenHeight * 0.3 > 200 ? 200 : screenHeight * 0.3, // Reduced max height for register
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Align(
                    // === PERUBAHAN DI SINI ===
                    alignment: Alignment.center, // Mengubah alignment menjadi tengah
                    child: Padding(
                      // Menghapus padding kiri, hanya menyisakan padding atas
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.07 < 28 ? screenWidth * 0.07 : 28, // Responsive font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // Pastikan teks juga di-center secara internal
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke halaman sebelumnya
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: ArcPainter(backgroundColor: primaryBlue),
                    child: Container(height: 50), // Ini akan membuat efek lekukan di bagian bawah
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 15.0), // Reduced vertical padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 15), // Reduced from 20
                  _buildStyledTextField(
                      controller: _usernameController,
                      label: 'Full Name',
                      icon: Icons.person,
                  ),
                  const SizedBox(height: 15), // Reduced from 20
                  _buildStyledTextField(
                      controller: _emailController,
                      label: 'Email / Phone Number',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15), // Reduced from 20
                  _buildStyledTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                  ),
                  const SizedBox(height: 15), // Reduced from 20
                  _buildStyledTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock,
                      obscureText: true,
                  ),
                  const SizedBox(height: 25), // Reduced from 30
                  _buildRoleDropdown(), // Mengganti ini dengan dropdown
                  const SizedBox(height: 25), // Reduced from 30
                  ElevatedButton(
                    onPressed: isLoading ? null : signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50), // Mengatur lebar minimum tombol
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "SIGN UP",
                            style: buttonTextStyle,
                          ),
                  ),
                  const SizedBox(height: 15), // Reduced from 20
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke halaman login
                    },
                    child: Text(
                      "Already have an account? Sign in",
                      style: linkTextStyle,
                    ),
                  ),
                  const SizedBox(height: 20), // Added bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: lightBlue.withOpacity(0.3), // Warna latar belakang field
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryBlue), // Warna label
          prefixIcon: Icon(icon, color: primaryBlue), // Warna ikon
          border: InputBorder.none, // Menghilangkan border default
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            "Select Role:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: lightBlue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedRole,
              hint: Text(
                "Choose your role",
                style: TextStyle(color: primaryBlue),
              ),
              icon: Icon(Icons.arrow_drop_down, color: primaryBlue),
              style: TextStyle(color: primaryBlue, fontSize: 16),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
              },
              items: _roles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class ArcPainter extends CustomPainter {
  final Color backgroundColor;

  ArcPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white; // Warna lekukan (putih)
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, size.height - 30, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}