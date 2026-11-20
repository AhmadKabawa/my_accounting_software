import 'dart:async';

import 'package:dartz/dartz.dart' show Either, Unit;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/utils/logger.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_authenticator.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_cached_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_must_change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';

class SessionCubit extends Cubit<SessionStatus> implements SessionGate, SessionAuthenticator {
  SessionCubit({
    required GetCurrentUserUseCase getCurrentUser,
    required GetMustChangePasswordUseCase getMustChangePassword,
    required LogoutUseCase logout,
    required Stream<void> sessionCleared,
    required FlashMessages flash,
    AccessCubit? access,
  }) : _getCurrentUser = getCurrentUser,
       _getMustChangePassword = getMustChangePassword,
       _logout = logout,
       _flash = flash,
       _access = access,
       super(const SessionChecking()) {
    _sessionSub = sessionCleared.listen(_onSessionCleared);
  }

  final GetCurrentUserUseCase _getCurrentUser;
  final GetMustChangePasswordUseCase _getMustChangePassword;
  final LogoutUseCase _logout;
  final FlashMessages _flash;
  final AccessCubit? _access;
  late final StreamSubscription<void> _sessionSub;
  bool _signingOut = false;
  int _sessionRequest = 0;

  @override
  SessionStatus get current => state;
  @override
  Stream<SessionStatus> get changes => stream;

  @override
  Future<void> close() async {
    await _sessionSub.cancel();
    return super.close();
  }

  void _error(Failure failure) => _flash.post(failure.messageKey, MessageType.error);

  void _onSessionCleared(void _) {
    if (_signingOut) return;
    _sessionRequest++;
    _access?.clear();
    if (state is SessionUnauthenticated) return;
    emit(const SessionUnauthenticated());
    _error(UnauthorizedFailure());
  }

  Future<void> checkAuthentication() async {
    if (state is SessionAuthenticated) return;
    final request = ++_sessionRequest;
    emit(const SessionChecking());
    final Either<Failure, UserEntity?> result;
    try {
      result = await _getCurrentUser(NoParams());
    } catch (error, stackTrace) {
      Logger.error('SessionCubit: session check threw', error: error, stackTrace: stackTrace, name: 'SessionCubit');
      if (!isClosed && request == _sessionRequest) {
        _access?.clear();
        emit(const SessionUnauthenticated());
        _error(UnexpectedFailure());
      }
      return;
    }
    if (isClosed || request != _sessionRequest) return;
    await result.fold<Future<void>>(
      (failure) async {
        _access?.clear();
        emit(const SessionUnauthenticated());
        _error(failure);
      },
      (user) async {
        if (user == null) {
          _access?.clear();
          emit(const SessionUnauthenticated());
        } else {
          await _publishAuthenticated(user, request);
        }
      },
    );
  }

  @override
  void onAuthenticated(UserEntity user) {
    final request = ++_sessionRequest;
    emit(const SessionChecking());
    unawaited(_publishAuthenticated(user, request));
  }

  Future<void> _publishAuthenticated(UserEntity user, int request) async {
    final Either<Failure, bool> result;
    try {
      result = await _getMustChangePassword(GetMustChangePasswordParams(userId: user.id));
    } catch (error, stackTrace) {
      Logger.error('SessionCubit: password policy check threw', error: error, stackTrace: stackTrace, name: 'SessionCubit');
      if (!isClosed && request == _sessionRequest) {
        _access?.clear();
        emit(const SessionUnauthenticated());
        _error(UnexpectedFailure());
      }
      return;
    }
    if (isClosed || request != _sessionRequest) return;
    result.fold(
      (failure) {
        _access?.clear();
        emit(const SessionUnauthenticated());
        _error(failure);
      },
      (requiredChange) {
        emit(SessionAuthenticated(user, mustChangePassword: requiredChange));
        final access = _access;
        if (access != null) unawaited(access.load());
      },
    );
  }

  /// Called only after Auth accepted the new password and the completion RPC
  /// cleared the database flag. Access is refreshed before the router releases
  /// the AUTH-02 gate.
  Future<void> passwordChangeCompleted() async {
    final authenticated = state;
    if (authenticated is! SessionAuthenticated) return;
    final request = ++_sessionRequest;
    final access = _access;
    if (access != null) await access.load();
    if (isClosed || request != _sessionRequest) return;
    emit(SessionAuthenticated(authenticated.user, mustChangePassword: false));
  }

  void updateUser(UserEntity user) {
    final authenticated = state;
    if (authenticated is SessionAuthenticated) {
      emit(SessionAuthenticated(user, mustChangePassword: authenticated.mustChangePassword));
    }
  }

  Future<void> signOut() async { await signOutWithResult(); }

  Future<bool> signOutWithResult() async {
    _signingOut = true;
    Either<Failure, Unit>? result;
    try {
      result = await _logout(NoParams());
    } catch (e, st) {
      Logger.error('SessionCubit: sign-out threw', error: e, stackTrace: st, name: 'SessionCubit');
    } finally {
      _signingOut = false;
    }
    if (result == null) {
      _error(UnexpectedFailure());
      return false;
    }
    return result.fold(
      (failure) { _error(failure); return false; },
      (_) {
        _sessionRequest++;
        _access?.clear();
        emit(const SessionUnauthenticated());
        _flash.post(AuthKeys.signOutSuccess, MessageType.success);
        return true;
      },
    );
  }
}