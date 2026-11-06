import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';

abstract class Failure extends Equatable {
  final AppKey messageKey;
  final int? statusCode;

  const Failure({required this.messageKey, this.statusCode});

  @override
  List<Object?> get props => [messageKey, statusCode];
}

// ─────────── ValidationFailure ───────────

// ✅ أضف const للـ constructor إذا كانت الـ AppKey ثابتة
class ValidationFailure extends Failure {
  ValidationFailure({AppKey? messageKey, int? statusCode})
    : super(
        messageKey: messageKey ?? ErrorKeys.validation,
        statusCode: statusCode,
      );
}

// ─────────── NetworkFailure ───────────

class NetworkFailure extends Failure {
  NetworkFailure({AppKey? messageKey, int? statusCode})
    : super(
        messageKey: messageKey ?? ErrorKeys.network,
        statusCode: statusCode,
      );
}
// ─────────── CacheFailure ───────────

class CacheFailure extends Failure {
  CacheFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.cache);
}

// ─────────── ServerFailure ───────────

class ServerFailure extends Failure {
  ServerFailure({AppKey? messageKey, int? statusCode})
    : super(
        messageKey: messageKey ?? ErrorKeys.server,
        statusCode: statusCode,
      );
}
// ─────────── Other Failures ───────────

class GoogleSignInFailure extends Failure {
  GoogleSignInFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.googleSignIn);
}

class PermissionFailure extends Failure {
  PermissionFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.permission);
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.unknown);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.unauthorized);
}

class NotFoundFailure extends Failure {
  NotFoundFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.notFound);
}
