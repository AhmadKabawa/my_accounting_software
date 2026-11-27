import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';

class ApiException extends AppException {
  final ApiExceptionType type;

  /// Business-rule code raised by the database (`ERPnn`), when there is one.
  /// Drives the translated message (decision 76); [message] stays the raw
  /// server text and is for diagnostics only in that case.
  final String? errorCode;

  /// Extra detail the database sent with the error (diagnostics only).
  final String? details;

  const ApiException._({
    required super.message,
    required this.type,
    super.statusCode,
    this.errorCode,
    this.details,
  });

  // ───────────── Network ─────────────

  factory ApiException.noInternet({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.network.key,
      type: ApiExceptionType.noInternet,
    );
  }

  factory ApiException.timeout({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.timeout.key,
      type: ApiExceptionType.timeout,
    );
  }

  factory ApiException.cancelled({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.cancelled.key,
      type: ApiExceptionType.cancelled,
    );
  }

  // ───────────── Auth ─────────────

  factory ApiException.unauthorized({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.unauthorized.key,
      statusCode: 401,
      type: ApiExceptionType.unauthorized,
    );
  }

  factory ApiException.forbidden({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.forbidden.key,
      statusCode: 403,
      type: ApiExceptionType.forbidden,
    );
  }

  // ───────────── Client Errors ─────────────

  factory ApiException.badRequest({String? serverMessage, int? statusCode, String? errorCode, String? details}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.badRequest.key,
      statusCode: statusCode ?? 400,
      type: ApiExceptionType.badRequest,
      errorCode: errorCode,
      details: details,
    );
  }

  factory ApiException.notFound({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.notFound.key,
      statusCode: 404,
      type: ApiExceptionType.notFound,
    );
  }

  factory ApiException.validationError({String? serverMessage, String? errorCode, String? details}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.validation.key,
      statusCode: 422,
      type: ApiExceptionType.validation,
      errorCode: errorCode,
      details: details,
    );
  }

  factory ApiException.conflict({
    String? serverMessage,
    String? errorCode,
    String? details,
  }) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.conflict.key,
      statusCode: 409,
      type: ApiExceptionType.conflict,
      errorCode: errorCode,
      details: details,
    );
  }

  /// A business rule of the database rejected the request (`ERPnn`).
  factory ApiException.erp({
    required String errorCode,
    String? serverMessage,
    String? details,
    int? statusCode,
  }) {
    return ApiException._(
      message: serverMessage ?? errorCode,
      statusCode: statusCode ?? 400,
      type: ApiExceptionType.businessRule,
      errorCode: errorCode,
      details: details,
    );
  }

  // ───────────── Server ─────────────

  factory ApiException.server({int? statusCode, String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.server.key,
      statusCode: statusCode ?? 500,
      type: ApiExceptionType.serverError,
    );
  }

  factory ApiException.serviceUnavailable({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.serviceUnavailable.key,
      statusCode: 503,
      type: ApiExceptionType.serverError,
    );
  }

  // ───────────── Unknown ─────────────

  factory ApiException.unknown({String? serverMessage}) {
    return ApiException._(
      message: serverMessage ?? ErrorKeys.unknown.key,
      type: ApiExceptionType.unknown,
    );
  }

  @override
  String toString() {
    final code = errorCode == null ? '' : ', code: $errorCode';
    final extra = details == null ? '' : ', details: $details';
    return 'ApiException[$type] '
        '(status: $statusCode$code, message: $message$extra)';
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
  businessRule,
  serverError,
  unknown,
}
