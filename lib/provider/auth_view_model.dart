import 'package:flutter/material.dart';
import 'package:goodchannel/repository/auth_repository.dart';
import 'package:goodchannel/widgets/utils.dart';

class AuthViewModel extends ChangeNotifier {
  final myRepo = AuthRepository();

  bool loginLoader = false;

  Future<void> login(Map<String, String> data) async {
    try {
      loginLoader = true;
      notifyListeners();
      Map<String, dynamic> response = await myRepo.login(data);
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage(e.toString());
    } finally {
      loginLoader = false;
      notifyListeners();
    }
  }
}
