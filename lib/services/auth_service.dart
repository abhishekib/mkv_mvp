import 'package:goodchannel/services/api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService({required ApiService apiService}) : _apiService = apiService;

  Future<String> getPlaylist({
    required String username,
    required String password,
    String type = 'm3u_plus',
    String output = 'ts',
  }) async {
    return await _apiService.get(
      'get.php',
      queryParams: {
        'username': 'b81855cb72',
        'password': 'be8622a3cb0e',
        'type': type,
        'output': output,
      },
    );
  }
}
