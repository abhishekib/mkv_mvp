import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:goodchannel/provider/auth_view_model.dart';
import 'package:goodchannel/screens/subscription_plan_screen.dart';
import 'package:goodchannel/widgets/utils.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  // String? _selectedPlan;

  // final List<String> _plans = ['Basic', 'Standard', 'Premium'];

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Utils.getLogo(),

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
                          Utils.textField(
                            label: 'Username',
                            hint: 'Enter user name',
                            controller: context
                                .read<AuthViewModel>()
                                .usernameController,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your username'
                                : null,
                          ),
                          SizedBox(height: 20),

                          // Email Field
                          Utils.textField(
                            label: 'Email',
                            hint: 'Enter email name',
                            controller:
                                context.read<AuthViewModel>().emailController,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter email address'
                                : EmailValidator.validate(value)
                                    ? null
                                    : 'Please enter a valid email address',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 20),

                          // Password Field
                          Utils.textField(
                            label: 'Password',
                            hint: 'Enter your password',
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your password'
                                : null,
                            controller: context
                                .read<AuthViewModel>()
                                .passwordController,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            isPassword: true,
                          ),
                          
                          SizedBox(height: 32),

                          // Sign Up Button
                          ElevatedButton(
                            onPressed: () {
                              // Handle sign up
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthViewModel>().register(context);
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
                              'Choose Plan',
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
            ),
          ),

          Selector<AuthViewModel, bool>(
            selector: (context, viewModel) => viewModel.authLoader,
            builder: (context, authLoader, child) {
              return authLoader
                  ? Positioned(
                      right: 200,
                      top: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container();
            },
          ),

          // Back Button
          Utils.backButton(context),
        ],
      ),
    );
  }
}
