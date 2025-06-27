import 'package:goodchannel/constants.dart';
import 'package:goodchannel/data/network/BaseApiServices.dart';
import '../data/network/NetworkApiServices.dart';

class AuthRepository {
  BaseApiAServices apiAServices = NetworkApiservice();

  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    try {
      return await apiAServices.getPostApiResponse(Constants.loginEndpoint, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      return await apiAServices.getPostApiResponse(Constants.registerEndpoint, data);
    } catch (e) {
      rethrow;
    }
  }
}
