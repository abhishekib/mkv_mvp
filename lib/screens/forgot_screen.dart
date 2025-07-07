import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodchannel/provider/auth_view_model.dart';
import 'package:goodchannel/screens/otp_screen.dart';
import 'package:goodchannel/widgets/utils.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: Utils.getScreenGradient(),
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
                          
                            Form(
                                key: _formKey,
                                child:
                                    Utils.textField(
                                  label: 'Email',
                                  validator: (value) => value!.isEmpty
                                      ? "Please enter email address"
                                      : null,
                                  controller: _emailController,
                                  hint: 'Enter email here',
                                )),
                            SizedBox(height: 32),

                            Selector<AuthViewModel, bool>(
                              selector: (context, viewModel) =>
                                  viewModel.authLoader,
                              builder: (context, authLoader, child) {
                                return authLoader
                                    ? Column(
                                        children: [
                                          Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 16)
                                        ],
                                      )
                                    : Container();
                              },
                            ),

                            // Continue Button
                            ElevatedButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                // Handle continue action
                                if (_formKey.currentState!.validate()) {
                                  context
                                      .read<AuthViewModel>()
                                      .generateAndSendOtp(
                                          context, _emailController.text);
                                }
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
