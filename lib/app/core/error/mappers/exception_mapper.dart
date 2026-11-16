import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/mappers/server_error_mapper.dart';
import 'package:accounting_software/app/core/localization/keys/erp_error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/foundation/utils/logger.dart';

class ExceptionMapper {
  static Failure map(AppException exception) {
    Logger.error(exception.toString());

    if (exception is ApiException) {
      return _mapApiException(exception);
    }

    if (exception is CacheException) {
      return CacheFailure(messageKey: ErrorKeys.cache);
    }

    if (exception is ValidationException) {
      return ValidationFailure(messageKey: ErrorKeys.validation);
    }

    if (exception is PermissionException) {
      return PermissionFailure(messageKey: ErrorKeys.permission);
    }

    return UnexpectedFailure(messageKey: ErrorKeys.unexpected);
  }

  static Failure _mapApiException(ApiException e) {
    // A database business-rule code (ERPnn) has its own translated text;
    // the server's raw message is never shown (decision 76).
    if (e.type == ApiExceptionType.businessRule) {
      final erpKey = ErpErrorKeys.fromCode(e.errorCode);
      return e.errorCode == 'ERP16'
          ? PermissionFailure(messageKey: erpKey)
          : ValidationFailure(messageKey: erpKey, statusCode: e.statusCode);
    }

    final messageKey = ServerErrorMapper.map(
      e.message,
      statusCode: e.statusCode,
    );

    return switch (e.type) {
      // ── Network ──
      ApiExceptionType.noInternet ||
      ApiExceptionType.timeout ||
      ApiExceptionType.cancelled => NetworkFailure(
        messageKey: messageKey,
        statusCode: e.statusCode,
      ),

      // ── Auth ──
      ApiExceptionType.unauthorized => UnauthorizedFailure(
        messageKey: messageKey,
      ),

      ApiExceptionType.forbidden => PermissionFailure(messageKey: messageKey),

      // ── Client ──
      ApiExceptionType.businessRule ||
      ApiExceptionType.validation ||
      ApiExceptionType.badRequest ||
      ApiExceptionType.conflict => ValidationFailure(
        messageKey: messageKey,
        statusCode: e.statusCode,
      ),

      ApiExceptionType.notFound => NotFoundFailure(messageKey: messageKey),

      // ── Server ──
      ApiExceptionType.serverError => ServerFailure(
        messageKey: messageKey,
        statusCode: e.statusCode,
      ),

      // ── Unknown ──
      ApiExceptionType.unknown => UnexpectedFailure(messageKey: messageKey),
    };
  }
}
