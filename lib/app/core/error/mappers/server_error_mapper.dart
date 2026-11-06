import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/server_error_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';

class ServerErrorMapper {
  ServerErrorMapper._();
  static final Map<String, AppKey> _serverToKey = {
    // ───────────── Email ─────────────
    'already been taken': ServerErrorKeys.emailAlreadyExists,
    'email already exists': ServerErrorKeys.emailAlreadyExists,
    'email_already_exists': ServerErrorKeys.emailAlreadyExists,
    'duplicate entry': ServerErrorKeys.emailAlreadyExists,
    'email not found': ServerErrorKeys.emailNotFound,
    'email_not_found': ServerErrorKeys.emailNotFound,

    // ───────────── Credentials ─────────────
    'invalid login credentials': ServerErrorKeys.invalidCredentials,
    'invalid credentials': ServerErrorKeys.invalidCredentials,
    'invalid_credentials': ServerErrorKeys.invalidCredentials,
    'wrong password': ServerErrorKeys.invalidCredentials,
    'incorrect password': ServerErrorKeys.invalidCredentials,
    'these credentials do not': ServerErrorKeys.invalidCredentials,
    'authentication failed': ServerErrorKeys.invalidCredentials,

    // ───────────── Account ─────────────
    'account disabled': ServerErrorKeys.accountDisabled,
    'account_disabled': ServerErrorKeys.accountDisabled,
    'account suspended': ServerErrorKeys.accountDisabled,
    'user disabled': ServerErrorKeys.accountDisabled,

    // ───────────── Rate limiting ─────────────
    'too many attempts': ServerErrorKeys.tooManyAttempts,
    'too_many_attempts': ServerErrorKeys.tooManyAttempts,
    'rate limit': ServerErrorKeys.tooManyAttempts,
    'too many requests': ServerErrorKeys.tooManyAttempts,

    // ───────────── Password ─────────────
    'current password is': ServerErrorKeys.passwordIncorrect,
    'incorrect current password': ServerErrorKeys.passwordIncorrect,
    'password_incorrect': ServerErrorKeys.passwordIncorrect,
    'old password is wrong': ServerErrorKeys.passwordIncorrect,

    // ───────────── Token ─────────────
    'token expired': ServerErrorKeys.tokenExpired,
    'token_expired': ServerErrorKeys.tokenExpired,
    'link expired': ServerErrorKeys.tokenExpired,
    'token invalid': ServerErrorKeys.tokenInvalid,
    'token_invalid': ServerErrorKeys.tokenInvalid,
    'invalid token': ServerErrorKeys.tokenInvalid,

    // ───────────── User ─────────────
    'user not found': ServerErrorKeys.userNotFound,
    'user_not_found': ServerErrorKeys.userNotFound,
    'no user found': ServerErrorKeys.userNotFound,

    // ───────────── Phone ─────────────
    'phone already': ServerErrorKeys.phoneAlreadyExists,
    'phone_already_exists': ServerErrorKeys.phoneAlreadyExists,

    // ───────────── Auth ─────────────
    'unauthenticated': ServerErrorKeys.unauthenticated,
    'not authenticated': ServerErrorKeys.unauthenticated,
    'please login': ServerErrorKeys.unauthenticated,

    // ───────────── Email verification ─────────────
    'email not verified': ServerErrorKeys.unverifiedEmail,
    'unverified_email': ServerErrorKeys.unverifiedEmail,
    'verify your email': ServerErrorKeys.unverifiedEmail,
  };

  static AppKey map(String? serverMessage, {int? statusCode}) {
    if (serverMessage == null || serverMessage.isEmpty) {
      return _fallbackByStatusCode(statusCode);
    }

    final normalized = serverMessage.toLowerCase().trim();

    for (final entry in _serverToKey.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return _fallbackByStatusCode(statusCode);
  }

  static AppKey _fallbackByStatusCode(int? code) {
    return switch (code) {
      400 => ErrorKeys.validation,
      401 => ErrorKeys.unauthorized,
      403 => ErrorKeys.forbidden,
      404 => ErrorKeys.notFound,
      408 => ErrorKeys.timeout,
      409 => ErrorKeys.conflict,
      422 => ErrorKeys.validation,
      429 => ServerErrorKeys.tooManyAttempts,
      500 => ErrorKeys.server,
      503 => ErrorKeys.serviceUnavailable,
      _ => ErrorKeys.unexpected,
    };
  }
}
