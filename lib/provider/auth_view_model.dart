import 'package:flutter/material.dart';
import 'package:goodchannel/provider/user_view_model.dart';
import 'package:goodchannel/repository/auth_repository.dart';
import 'package:goodchannel/screens/dashboard_screen.dart';
import 'package:goodchannel/screens/login_screen.dart';
import 'package:goodchannel/screens/new_password_screen.dart';
import 'package:goodchannel/screens/otp_screen.dart';
import 'package:goodchannel/screens/subscription_plan_screen.dart';
import 'package:goodchannel/widgets/utils.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:provider/provider.dart';

class AuthViewModel extends ChangeNotifier {
  final authRepo = AuthRepository();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool authLoader = false;

  Future<String> _getDeviceId() async {
    final mobileDeviceIdentifier = await MobileDeviceIdentifier().getDeviceId();
    return mobileDeviceIdentifier ?? '';
  }

  Future<void> login(BuildContext context) async {
    try {
      final mobileDeviceIdentifier = await _getDeviceId();
      Map<String, String> data = {
        'email': emailController.text,
        'password': passwordController.text,
        'deviceId': mobileDeviceIdentifier,
      };
      authLoader = true;
      notifyListeners();
      Map<String, dynamic> response = await authRepo.login(data);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DashboardScreen()));
      context.read<UserViewModel>().saveToken(response['data']['token']);
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
      Map<String, dynamic> registerResponse = await authRepo.register(data);
      Map<String, dynamic> loginResponse = await authRepo.login(data);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlanSelectionScreen(),
      ));
      context.read<UserViewModel>().saveToken(loginResponse['token']);
      emailController.clear();
      passwordController.clear();
      usernameController.clear();
      Utils.toastMessage(registerResponse['message']);
    } catch (e) {
      Utils.toastMessage(e.toString());
    } finally {
      authLoader = false;
      notifyListeners();
    }
  }
  
  Future<void> logout(BuildContext context) async {
    try {
      final mobileDeviceIdentifier = await _getDeviceId();
      Map<String, dynamic> data = {'deviceId': mobileDeviceIdentifier};
      Map<String, dynamic> response = await authRepo.logout(data);
      context.read<UserViewModel>().clearAll();
      Utils.toastMessage(response['message']);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      Utils.toastMessage(e.toString());
    }
  }

  Future<void> generateAndSendOtp(BuildContext context, String email) async {
    try {
      Map<String, String> data = {'email': email};
      authLoader = true;
      notifyListeners();
      Map<String, dynamic> response = await authRepo.generateAndSendOtp(data);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: email),
        ),
      );
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage(e.toString());
    }
    finally{
      authLoader = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(BuildContext context, String email ,String otp) async {
    try {
      Map<String, String> data = {'email': email,'otp': otp};
      authLoader = true;
      notifyListeners();
      Map<String, dynamic> response = await authRepo.verifyOtp(data);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NewPasswordScreen(email: email,)));
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage(e.toString());
    }
    finally{
      authLoader = false;
      notifyListeners();
    }
  }

  Future<void> updatePassword(BuildContext context, String email ,String password) async {
    try{
      Map<String, String> data = {'email': email,'newPassword': password};
      authLoader = true;
      notifyListeners();
      Map<String, dynamic> response = await authRepo.updatePassword(data);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
      Utils.toastMessage(response['message']);
    }
    catch (e){
      Utils.toastMessage(e.toString());
    }
    finally{
      authLoader = false;
      notifyListeners();
    }
  }
}
