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
  const ValidationFailure({AppKey? messageKey, super.statusCode})
    : super(messageKey: messageKey ?? ErrorKeys.validation);
}

// ─────────── NetworkFailure ───────────

class NetworkFailure extends Failure {
  const NetworkFailure({AppKey? messageKey, super.statusCode})
    : super(messageKey: messageKey ?? ErrorKeys.network);
}
// ─────────── CacheFailure ───────────

class CacheFailure extends Failure {
  const CacheFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.cache);
}

// ─────────── ServerFailure ───────────

class ServerFailure extends Failure {
  const ServerFailure({AppKey? messageKey, super.statusCode})
    : super(messageKey: messageKey ?? ErrorKeys.server);
}
// ─────────── Other Failures ───────────

class GoogleSignInFailure extends Failure {
  const GoogleSignInFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.googleSignIn);
}

class PermissionFailure extends Failure {
  const PermissionFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.permission);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.unknown);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.unauthorized);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({AppKey? messageKey})
    : super(messageKey: messageKey ?? ErrorKeys.notFound);
}
