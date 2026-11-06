import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/mappers/server_error_mapper.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
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
