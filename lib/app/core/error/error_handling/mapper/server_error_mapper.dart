import 'package:accounting_software/app/core/foundation/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';

class ServerErrorMapper {
  ServerErrorMapper._();
  static final Map<String, AppKey> _serverToKey = {
    // ───────────── Email ─────────────
    'already been taken': AppKeys.server.emailAlreadyExists,
    'email already exists': AppKeys.server.emailAlreadyExists,
    'email_already_exists': AppKeys.server.emailAlreadyExists,
    'duplicate entry': AppKeys.server.emailAlreadyExists,
    'email not found': AppKeys.server.emailNotFound,
    'email_not_found': AppKeys.server.emailNotFound,

    // ───────────── Credentials ─────────────
    'invalid credentials': AppKeys.server.invalidCredentials,
    'invalid_credentials': AppKeys.server.invalidCredentials,
    'wrong password': AppKeys.server.invalidCredentials,
    'incorrect password': AppKeys.server.invalidCredentials,
    'these credentials do not': AppKeys.server.invalidCredentials,
    'authentication failed': AppKeys.server.invalidCredentials,

    // ───────────── Account ─────────────
    'account disabled': AppKeys.server.accountDisabled,
    'account_disabled': AppKeys.server.accountDisabled,
    'account suspended': AppKeys.server.accountDisabled,
    'user disabled': AppKeys.server.accountDisabled,

    // ───────────── Rate limiting ─────────────
    'too many attempts': AppKeys.server.tooManyAttempts,
    'too_many_attempts': AppKeys.server.tooManyAttempts,
    'rate limit': AppKeys.server.tooManyAttempts,
    'too many requests': AppKeys.server.tooManyAttempts,

    // ───────────── Password ─────────────
    'current password': AppKeys.server.passwordIncorrect,
    'password_incorrect': AppKeys.server.passwordIncorrect,
    'old password is wrong': AppKeys.server.passwordIncorrect,

    // ───────────── Token ─────────────
    'token expired': AppKeys.server.tokenExpired,
    'token_expired': AppKeys.server.tokenExpired,
    'link expired': AppKeys.server.tokenExpired,
    'token invalid': AppKeys.server.tokenInvalid,
    'token_invalid': AppKeys.server.tokenInvalid,
    'invalid token': AppKeys.server.tokenInvalid,

    // ───────────── User ─────────────
    'user not found': AppKeys.server.userNotFound,
    'user_not_found': AppKeys.server.userNotFound,
    'no user': AppKeys.server.userNotFound,

    // ───────────── Phone ─────────────
    'phone already': AppKeys.server.phoneAlreadyExists,
    'phone_already_exists': AppKeys.server.phoneAlreadyExists,

    // ───────────── Auth ─────────────
    'unauthenticated': AppKeys.server.unauthenticated,
    'not authenticated': AppKeys.server.unauthenticated,
    'please login': AppKeys.server.unauthenticated,

    // ───────────── Email verification ─────────────
    'email not verified': AppKeys.server.unverifiedEmail,
    'unverified_email': AppKeys.server.unverifiedEmail,
    'verify your email': AppKeys.server.unverifiedEmail,
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
      400 => AppKeys.errors.validation,
      401 => AppKeys.errors.unauthorized,
      403 => AppKeys.errors.forbidden,
      404 => AppKeys.errors.notFound,
      408 => AppKeys.errors.timeout,
      409 => AppKeys.errors.conflict,
      422 => AppKeys.errors.validation,
      429 => AppKeys.server.tooManyAttempts,
      500 => AppKeys.errors.server,
      503 => AppKeys.errors.serviceUnavailable,
      _ => AppKeys.errors.unexpected,
    };
  }
}
