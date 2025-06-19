import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  // String? _selectedPlan;

  // final List<String> _plans = ['Basic', 'Standard', 'Premium'];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6A1B9A), // Deep Purple
                  Color(0xFF303F9F), // Indigo
                ],
                transform: GradientRotation(3.338), // 191.28 degrees in radians
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  padding: EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Image.asset(
                          'assets/text_icon.png',
                          width: 200,
                          height: 100,
                        ),
                      ),
                      // Title
                      Text(
                        'Sign Up for Exclusive Updates!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),

                      // Username Field
                      _buildTextField(
                        label: 'Username',
                        hint: 'Enter user name',
                        controller: _usernameController,
                      ),
                      SizedBox(height: 20),

                      // Email Field
                      _buildTextField(
                        label: 'Email',
                        hint: 'Enter email name',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20),

                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      SizedBox(height: 32),

                      // Sign Up Button
                      ElevatedButton(
                        onPressed: () {
                          // Handle sign up
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 30,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
