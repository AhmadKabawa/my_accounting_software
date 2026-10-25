import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/exceptions.dart';
import 'package:accounting_software/app/core/error/error_handling/mapper/server_error_mapper.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/utils/logger.dart';

class ExceptionMapper {
  static Failure map(AppException exception) {
    Logger.error(exception.toString());

    if (exception is ApiException) {
      return _mapApiException(exception);
    }

    if (exception is CacheException) {
      return CacheFailure(messageKey: AppKeys.errors.cache);
    }

    if (exception is ValidationException) {
      return ValidationFailure(messageKey: AppKeys.errors.validation);
    }

    if (exception is PermissionException) {
      return PermissionFailure(messageKey: AppKeys.errors.permission);
    }

    return UnexpectedFailure(messageKey: AppKeys.errors.unexpected);
  }

  static Failure _mapApiException(ApiException e) {
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
