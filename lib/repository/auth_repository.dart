import 'package:goodchannel/constants.dart';
import 'package:goodchannel/data/network/BaseApiServices.dart';
import '../data/network/NetworkApiServices.dart';

class AuthRepository {
  BaseApiAServices apiServices = NetworkApiservice();

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    try {
      return await apiServices.getPostApiResponse(Constants.loginEndpoint, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      return await apiServices.getPostApiResponse(Constants.registerEndpoint, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateAndSendOtp(Map<String, dynamic> data) async {
    try {
      return await apiServices.getPostApiResponse(Constants.generateAndSendOtpEndpoint, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> data) async {
    try {
      return await apiServices.getPostApiResponse(Constants.verifyOtpEndpoint, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePassword(Map<String, dynamic> data) async {
    try {
      return await apiServices.getPostApiResponse(Constants.updatePasswordEndpoint, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> logout(Map<String, dynamic> data) async {
    try {
      return await apiServices.getPostApiResponse(Constants.logoutEndpoint, data);
    } catch (e) {
      rethrow;
    }
  }
}
