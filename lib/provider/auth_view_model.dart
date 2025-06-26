import 'package:flutter/material.dart';
import 'package:goodchannel/repository/auth_repository.dart';
import 'package:goodchannel/screens/dashboard_screen.dart';
import 'package:goodchannel/widgets/utils.dart';

class AuthViewModel extends ChangeNotifier {
  final myRepo = AuthRepository();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loginLoader = false;

  Future<void> login(BuildContext context) async {
    try {
      Map<String, String> data = {
        'username': usernameController.text,
        'password': passwordController.text
      };
      loginLoader = true;
      notifyListeners();
      Map<String, dynamic> response = await myRepo.login(data);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => DashboardScreen()));
      usernameController.clear();
      passwordController.clear();
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage(e.toString());
    } finally {
      loginLoader = false;
      notifyListeners();
    }
  }
}
