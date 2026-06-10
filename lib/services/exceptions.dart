class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException([String message = 'No Internet Connection']) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized access']) : super(message, 401);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message, 422);
}
