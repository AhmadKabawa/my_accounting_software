import 'package:accounting_software/app/core/error/error_handling/exceptions/exceptions.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_keys.dart';

class ApiException extends AppException {
  final ApiExceptionType type;

  const ApiException._({
    required super.message,
    required this.type,
    super.statusCode,
  });

  // ───────────── Network ─────────────

  factory ApiException.noInternet({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.network.toString(),
      type: ApiExceptionType.noInternet,
    );
  }

  factory ApiException.timeout({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.timeout.toString(),
      type: ApiExceptionType.timeout,
    );
  }

  factory ApiException.cancelled({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.cancelled.toString(),
      type: ApiExceptionType.cancelled,
    );
  }

  // ───────────── Auth ─────────────

  factory ApiException.unauthorized({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.unauthorized.toString(),
      statusCode: 401,
      type: ApiExceptionType.unauthorized,
    );
  }

  factory ApiException.forbidden({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.forbidden.toString(),
      statusCode: 403,
      type: ApiExceptionType.forbidden,
    );
  }

  // ───────────── Client Errors ─────────────

  factory ApiException.badRequest({String? serverMessage, int? statusCode}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.badRequest.toString(),
      statusCode: statusCode ?? 400,
      type: ApiExceptionType.badRequest,
    );
  }

  factory ApiException.notFound({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.notFound.toString(),
      statusCode: 404,
      type: ApiExceptionType.notFound,
    );
  }

  factory ApiException.validationError({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.validation.toString(),
      statusCode: 422,
      type: ApiExceptionType.validation,
    );
  }

  factory ApiException.conflict({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.conflict.toString(),
      statusCode: 409,
      type: ApiExceptionType.conflict,
    );
  }

  // ───────────── Server ─────────────

  factory ApiException.server({int? statusCode, String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.server.toString(),
      statusCode: statusCode ?? 500,
      type: ApiExceptionType.serverError,
    );
  }

  factory ApiException.serviceUnavailable({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.serviceUnavailable.toString(),
      statusCode: 503,
      type: ApiExceptionType.serverError,
    );
  }

  // ───────────── Unknown ─────────────

  factory ApiException.unknown({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? AppKeys.errors.unknown.toString(),
      type: ApiExceptionType.unknown,
    );
  }

  @override
  String toString() {
    return 'ApiException[$type] '
        '(status: $statusCode, message: $message)';
  }
}

enum ApiExceptionType {
  noInternet,
  timeout,
  cancelled,
  unauthorized,
  forbidden,
  badRequest,
  notFound,
  validation,
  conflict,
  serverError,
  unknown,
}
