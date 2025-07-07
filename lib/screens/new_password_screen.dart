import 'package:flutter/material.dart';
import 'package:goodchannel/provider/auth_view_model.dart';
import 'package:goodchannel/screens/login_screen.dart';
import 'package:goodchannel/widgets/utils.dart';
import 'package:provider/provider.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formkey = GlobalKey<FormState>();

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            Container(
              decoration: Utils.getScreenGradient(),
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
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
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 50,
                            child: Image.asset(
                              'assets/text_icon.png',
                              width: 200,
                              height: 100,
                            ),
                          ),
                          const Text(
                            "New Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                       
                          Utils.textField(
                              validator: (value) {
                                return value!.isEmpty
                                    ? 'Please Enter your Password'
                                    : newPasswordController.text != value
                                        ? 'Passwords do not match'
                                        : null;
                              },
                              label: 'Enter New Password',
                              hint: 'Enter your new Password here',
                              controller: newPasswordController),
                          const SizedBox(height: 20),
                          
                          Utils.textField(
                              label: 'Confirm Password',
                              hint: 'Retype you Password here',
                              controller: confirmPasswordController,
                              validator: (value) {
                                return value!.isEmpty
                                    ? 'Please Enter your Password'
                                    : newPasswordController.text != value
                                        ? 'Passwords do not match'
                                        : null;
                              },
                              isPassword: true),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  context.read<AuthViewModel>().updatePassword(
                                      context,
                                      widget.email,
                                      confirmPasswordController.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                "Update Password",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
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
            Utils.backButton(context),
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
    );
  }
}
