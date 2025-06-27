import 'package:flutter/material.dart';
import 'package:goodchannel/provider/user_view_model.dart';
import 'package:goodchannel/repository/auth_repository.dart';
import 'package:goodchannel/screens/dashboard_screen.dart';
import 'package:goodchannel/screens/subscription_plan_screen.dart';
import 'package:goodchannel/widgets/utils.dart';
import 'package:provider/provider.dart';

class AuthViewModel extends ChangeNotifier {
  final authRepo = AuthRepository();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool authLoader = false;

  Future<void> login(BuildContext context) async {
    try {
      Map<String, String> data = {
        'username': usernameController.text,
        'password': passwordController.text
      };
      authLoader = true;
      notifyListeners();
      Map<String, dynamic> response = await authRepo.login(data);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DashboardScreen()));
      context.read<UserViewModel>().saveToken(response['token']);
      usernameController.clear();
      passwordController.clear();
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage(e.toString());
    } finally {
      authLoader = false;
      notifyListeners();
    }
  }

  Future<void> register(BuildContext context) async {
    try {
      Map<String, String> data = {
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text
      };
      authLoader = true;
      notifyListeners();
      Map<String, dynamic> response = await authRepo.register(data);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlanSelectionScreen(),
      ));
      emailController.clear();
      passwordController.clear();
      usernameController.clear();
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage(e.toString());
    } finally {
      authLoader = false;
      notifyListeners();
    }
  }
}
