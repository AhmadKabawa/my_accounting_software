import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';

/// Where the app's session stands. Only three answers exist.
sealed class SessionStatus {
  const SessionStatus();
}

/// The stored session is being verified (app start).
final class SessionChecking extends SessionStatus {
  const SessionChecking();
}

final class SessionAuthenticated extends SessionStatus {
  const SessionAuthenticated(this.user);

  final UserEntity user;

  @override
  bool operator ==(Object other) =>
      other is SessionAuthenticated && other.user == user;

  @override
  int get hashCode => user.hashCode;
}

final class SessionUnauthenticated extends SessionStatus {
  const SessionUnauthenticated();
}

/// The session contract. Splash and the router depend on this interface only,
/// never on a presentation class (`SessionCubit` implements it).
abstract interface class SessionGate {
  SessionStatus get current;

  /// Emits on every change; feeds go_router's `refreshListenable`.
  Stream<SessionStatus> get changes;
}
