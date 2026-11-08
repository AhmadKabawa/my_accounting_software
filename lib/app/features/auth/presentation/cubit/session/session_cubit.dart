import 'dart:async';

import 'package:dartz/dartz.dart' show Either, Unit;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/utils/logger.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_authenticator.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_cached_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';

/// The app-wide session (singleton). It only knows checking / authenticated /
/// unauthenticated; screen flows live in `AuthFlowCubit` and `ProfileCubit`,
/// which report back through [onAuthenticated] and [updateUser].
///
/// Messages that must outlive the page (signed out, session expired...) go
/// through [FlashMessages].
class SessionCubit extends Cubit<SessionStatus> implements SessionGate, SessionAuthenticator {
  SessionCubit({
    required GetCurrentUserUseCase getCurrentUser,
    required LogoutUseCase logout,
    required Stream<void> sessionCleared,
    required FlashMessages flash,
  }) : _getCurrentUser = getCurrentUser,
       _logout = logout,
       _flash = flash,
       super(const SessionChecking()) {
    _sessionSub = sessionCleared.listen(_onSessionCleared);
  }

  final GetCurrentUserUseCase _getCurrentUser;
  final LogoutUseCase _logout;
  final FlashMessages _flash;
  late final StreamSubscription<void> _sessionSub;
  bool _signingOut = false;

  @override
  SessionStatus get current => state;

  @override
  Stream<SessionStatus> get changes => stream;

  @override
  Future<void> close() async {
    await _sessionSub.cancel();
    return super.close();
  }

  void _error(Failure failure) =>
      _flash.post(failure.messageKey, MessageType.error);

  /// The stored session was removed behind our back (e.g. the refresh token
  /// was rejected). A deliberate [signOut] clears it too, so it is ignored.
  void _onSessionCleared(void _) {
    if (_signingOut || state is SessionUnauthenticated) return;
    emit(const SessionUnauthenticated());
    _error(UnauthorizedFailure());
  }

  /// Verifies the stored session (app start).
  Future<void> checkAuthentication() async {
    if (state is SessionAuthenticated) return;

    emit(const SessionChecking());

    final Either<Failure, UserEntity?> result;
    try {
      result = await _getCurrentUser(NoParams());
    } catch (e, st) {
      // Never leave the app in `checking`: an unexpected error means we cannot
      // prove there is a session, so fall back to signed out.
      Logger.error(
        'SessionCubit: session check threw',
        error: e,
        stackTrace: st,
        name: 'SessionCubit',
      );
      emit(const SessionUnauthenticated());
      return;
    }

    result.fold(
      (failure) {
        // No cached user and the server could not confirm the session: show
        // the login screen but say WHY instead of failing silently.
        emit(const SessionUnauthenticated());
        _error(failure);
      },
      (user) => emit(
        user != null
            ? SessionAuthenticated(user)
            : const SessionUnauthenticated(),
      ),
    );
  }

  /// Called by the sign-in / sign-up flows once the server accepted them.
  @override
  void onAuthenticated(UserEntity user) => emit(SessionAuthenticated(user));

  /// Called by the profile flow after the user's data changed.
  void updateUser(UserEntity user) {
    if (state is SessionAuthenticated) emit(SessionAuthenticated(user));
  }

  Future<void> signOut() async {
    _signingOut = true;
    Either<Failure, Unit>? result;
    try {
      result = await _logout(NoParams());
    } catch (e, st) {
      Logger.error(
        'SessionCubit: sign-out threw',
        error: e,
        stackTrace: st,
        name: 'SessionCubit',
      );
    } finally {
      _signingOut = false;
    }

    // Whatever happened, the user ends signed out; the router moves them to
    // the login page, where the flash message is shown.
    emit(const SessionUnauthenticated());

    if (result == null) {
      _error(UnexpectedFailure());
      return;
    }
    result.fold(
      _error,
      (_) => _flash.post(AuthKeys.signOutSuccess, MessageType.success),
    );
  }
}
