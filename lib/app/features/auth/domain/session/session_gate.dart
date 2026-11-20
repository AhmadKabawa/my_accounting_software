import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';

sealed class SessionStatus {
  const SessionStatus();
}

final class SessionChecking extends SessionStatus {
  const SessionChecking();
}

final class SessionAuthenticated extends SessionStatus {
  const SessionAuthenticated(this.user, {this.mustChangePassword = false});
  final UserEntity user;
  final bool mustChangePassword;

  @override
  bool operator ==(Object other) =>
      other is SessionAuthenticated &&
      other.user == user &&
      other.mustChangePassword == mustChangePassword;

  @override
  int get hashCode => Object.hash(user, mustChangePassword);
}

final class SessionUnauthenticated extends SessionStatus {
  const SessionUnauthenticated();
}

abstract interface class SessionGate {
  SessionStatus get current;
  Stream<SessionStatus> get changes;
}
