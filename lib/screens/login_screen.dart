import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodchannel/provider/auth_view_model.dart';
import 'package:goodchannel/screens/forgot_screen.dart';
import 'package:goodchannel/screens/sign_up_screen.dart';
import 'package:goodchannel/widgets/utils.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Enable fullscreen immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Scaffold(
      // Remove SafeArea to use full screen
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: Utils.getScreenGradient(),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
              child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                padding: EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0),
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
                child: Stack(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo/Icon
                          Utils.getLogo(),

                          // Welcome Text
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                          ),
                          // Username Field

                          Utils.textField(
                            label: 'Email',
                            validator: (value) => value!.isEmpty
                                ? "Please enter email address"
                                : EmailValidator.validate(value)
                                    ? null
                                    : "Please enter a valid email address", // Add email validation here if needednull,
                            controller:
                                context.read<AuthViewModel>().emailController,
                            hint: 'Enter your Email',
                          ),

                          //),

                          SizedBox(height: 20),

                          // Password Field
                          Utils.textField(
                            label: "Password",
                            validator: (value) => value!.isEmpty
                                ? "Please enter your password"
                                : null,
                            controller: context
                                .read<AuthViewModel>()
                                .passwordController,
                            hint: 'Enter your Password',
                            keyboardType: TextInputType.visiblePassword,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),

                          SizedBox(height: 16),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen()),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 24),

                          // Login and Sign-up buttons
                          Row(
                            children: [
                              Utils.button(
                                  text: 'Login',
                                  onPressed: () {
                                    // Dismiss the keyboard
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    if (_formKey.currentState!.validate()) {
                                      context
                                          .read<AuthViewModel>()
                                          .login(context);
                                    }
                                  }),
                              SizedBox(width: 12),
                              Utils.button(
                                text: 'Sign Up',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => SignUpScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Selector<AuthViewModel, bool>(
                      selector: (context, viewModel) => viewModel.authLoader,
                      builder: (context, authLoader, child) {
                        return authLoader
                            ? Positioned(
                                left: 50,
                                right: 50,
                                top: 300,
                                bottom: 50,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Container();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
