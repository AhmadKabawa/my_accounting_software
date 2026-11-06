import 'package:accounting_software/app/core/localization/keys/error_keys.dart';

/// Base class for all exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() {
    return 'AppException(status: $statusCode, message: $message)';
  }
}

/// Cache exception - when local storage fails
class CacheException extends AppException {
  CacheException({String? message})
    : super(message: message ?? ErrorKeys.cache.key);
}

/// Validation exception - when input validation fails
class ValidationException extends AppException {
  ValidationException({String? message})
    : super(message: message ?? ErrorKeys.validation.key);
}

class PermissionException extends AppException {
  PermissionException({String? message})
    : super(message: message ?? ErrorKeys.permission.key);
}
