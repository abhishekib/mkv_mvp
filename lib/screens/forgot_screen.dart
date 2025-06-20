import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodchannel/screens/new_password_screen.dart';
import 'package:goodchannel/widgets/utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color(0xFF6A1B9A), // Deep Purple
                  Color(0xFF303F9F), // Indigo
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 600),
                    padding:
                        EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0),
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
                          width: 200,
                          height: 80,
                          child: Image.asset(
                            'assets/text_icon.png',
                            width: 200,
                            height: 110,
                          ),
                        ),

                        // Title
                        Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Description
                        Text(
                          'Please enter your email for the verification process, we will send a OTP to your email.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 22),

                        // Email Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
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
                              child: Utils.textField(
                                controller: _emailController,
                                hint: 'Enter email here',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),

                        // Continue Button
                        ElevatedButton(
                          onPressed: () {
                            // Handle continue action
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => NewPasswordScreen()),
                            );
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
                            'Continue',
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
            Utils.backButton(context)
          ],
        ),
      ),
    );
  }
}
