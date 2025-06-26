class AppException implements Exception {
  final _message;
  AppException([this._message]);

  String toString() {
    return '$_message';
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? super.message]);
}

class BadRequestException extends AppException {
  BadRequestException([String? super.message]);
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String? super.message]);
}

class InvalidInputException extends AppException {
  InvalidInputException([String? super.message]);
}