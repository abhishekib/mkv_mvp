import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:goodchannel/data/app_exception.dart';
import 'package:goodchannel/data/network/BaseApiServices.dart';
import 'package:http/http.dart' as http;

class NetworkApiservice extends BaseApiAServices {
  @override
  Future<Map<String, dynamic>> getPostApiResponse(String url, Map<String, dynamic> data) async {
    Map<String, dynamic> responseJson;
    try {
      final http.Response response =
          await http.post(Uri.parse(url), body: data);
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Map<String, dynamic> returnResponse(http.Response response) {
    //Map<String, dynamic> responseData = jsonDecode(response.body);
    if (kDebugMode) {
      print('Response =>${response.body}');
    }
    /* if (responseData['message'] == 'Unauthenticated.') {
      Provider.of<UserViewModel>(navigatorKey.currentContext!, listen: false)
          .remove();
      Provider.of<UserViewModel>(navigatorKey.currentContext!, listen: false)
          .removeDeviceToken();
      Provider.of<UserViewModel>(navigatorKey.currentContext!, listen: false)
          .removeUser();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
          RoutesName.login, (route) => false,
          arguments: {'isOnboarding': false});
    } */
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        Map<String, dynamic> errorJson = jsonDecode(response.body);
        String errorMessage = errorJson['message'];
        throw BadRequestException(errorMessage);
      case 404:
        Map<String, dynamic> errorJson = jsonDecode(response.body);
        String errorMessage = errorJson['message'];
        throw UnauthorisedException(errorMessage);
      default:
        Map<String, dynamic> errorJson = jsonDecode(response.body);
        String errorMessage = errorJson['message'];
        throw FetchDataException(
          /*'Error accorded while communicating with server' +
              'with status code\n' +*/
          //response.statusCode.toString(),
          errorMessage,
        );
    }
  }
}
