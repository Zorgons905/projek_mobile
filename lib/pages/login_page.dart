import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart'; // Ini tidak selalu diperlukan jika hanya pakai Material widgets
import 'register_page.dart';
import '../services/auth_service.dart'; // Pastikan ini mengarah ke AuthService Anda yang benar

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final authService = AuthService();

  bool isLoading = false;
  String? _selectedRole; // State untuk menyimpan pilihan peran

  // List of roles for the dropdown
  final List<String> _roles = ["Dosen", "Mahasiswa"];

  // Warna dan gaya umum (konsisten dengan RegisterPage)
  final Color primaryBlue = const Color(0xFF1E88E5);
  final Color lightBlue = const Color(0xFFBBDEFB);
  final TextStyle buttonTextStyle =
      const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
  final TextStyle linkTextStyle =
      const TextStyle(color: Colors.grey, fontSize: 14);

  void login() async {
    if (_selectedRole == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select your role (Dosen/Mahasiswa)")),
        );
      }
      return;
    }

    setState(() => isLoading = true);
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signInWithEmailPassword(email, password);
      
      // Setelah login berhasil, Anda mungkin ingin memeriksa role yang benar
      // dan menavigasi ke halaman yang sesuai. Contohnya:
      // if (_selectedRole == "Dosen") {
      //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DosenHomePage()));
      // } else if (_selectedRole == "Mahasiswa") {
      //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MahasiswaHomePage()));
      // }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final horizontalPadding = screenWidth > 600 ? screenWidth * 0.1 : 30.0;

    return Scaffold(
      backgroundColor: Colors.white,
      // Pastikan resizeToAvoidBottomInset diatur true (default)
      resizeToAvoidBottomInset: true, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: screenHeight * 0.35 > 220 ? 220 : screenHeight * 0.35, // Cap max height slightly lower
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        "GEOSCHOLAR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.07 < 28 ? screenWidth * 0.07 : 28, // Slightly smaller font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: ArcPainter(backgroundColor: primaryBlue),
                    child: Container(height: 50),
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
                  Text(
                    "SIGN IN",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25), // Reduced from 30
                  _buildTextField(_emailController, 'Email', Icons.email),
                  const SizedBox(height: 15), // Reduced from 20
                  _buildTextField(_passwordController, 'Password', Icons.lock,
                      obscureText: true),
                  const SizedBox(height: 15), // Reduced from 20
                  _buildRoleDropdown(),
                  const SizedBox(height: 15), // Reduced from 20
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password logic
                      },
                      child: Text(
                        "Forgot Password?",
                        style: linkTextStyle.copyWith(color: primaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25), // Reduced from 30
                  ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50),
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
                            "SIGN IN",
                            style: buttonTextStyle,
                          ),
                  ),
                  const SizedBox(height: 15), // Reduced from 20
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: Text(
                      "Don't have an account? Register here",
                      style: linkTextStyle,
                    ),
                  ),
                  // SizedBox(height: 30), // Can be removed or reduced if still scrolling
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SizedBox(width: screenWidth * 0.05),
                  //     _buildSocialIcon(Icons.g_mobiledata),
                  //     SizedBox(width: screenWidth * 0.05),
                  //     _buildSocialIcon(Icons.facebook),
                  //     SizedBox(width: screenWidth * 0.05),
                  //     _buildSocialIcon(Icons.apple),
                  //     SizedBox(width: screenWidth * 0.05),
                  //   ],
                  // ),
                  // Added a small bottom padding to ensure content is not cut off by system UI
                  const SizedBox(height: 20), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: lightBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryBlue),
          prefixIcon: Icon(icon, color: primaryBlue),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Icon(icon, color: Colors.grey.shade600, size: 30),
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
    final paint = Paint()..color = Colors.white;
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