import 'dart:io';

abstract class BaseApiAServices {
  //Future<dynamic> getGetApiResponse(String url, String token);

  Future<Map<String, dynamic>> getPostApiResponse(
    String url,
    Map<String, dynamic> data,
  );

  //Future<dynamic> getApiResponse(String url);
}
