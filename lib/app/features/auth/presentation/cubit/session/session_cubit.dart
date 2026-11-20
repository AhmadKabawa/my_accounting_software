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
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';

class SessionCubit extends Cubit<SessionStatus>
    implements SessionGate, SessionAuthenticator {
  SessionCubit({
    required GetCurrentUserUseCase getCurrentUser,
    required LogoutUseCase logout,
    required Stream<void> sessionCleared,
    required FlashMessages flash,
    AccessCubit? access,
  }) : _getCurrentUser = getCurrentUser,
       _logout = logout,
       _flash = flash,
       _access = access,
       super(const SessionChecking()) {
    _sessionSub = sessionCleared.listen(_onSessionCleared);
  }

  final GetCurrentUserUseCase _getCurrentUser;
  final LogoutUseCase _logout;
  final FlashMessages _flash;
  final AccessCubit? _access;
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

  void _onSessionCleared(void _) {
    if (_signingOut) return;
    _access?.clear();
    if (state is SessionUnauthenticated) return;
    emit(const SessionUnauthenticated());
    _error(UnauthorizedFailure());
  }

  Future<void> checkAuthentication() async {
    if (state is SessionAuthenticated) return;
    emit(const SessionChecking());

    final Either<Failure, UserEntity?> result;
    try {
      result = await _getCurrentUser(NoParams());
    } catch (e, st) {
      Logger.error(
        'SessionCubit: session check threw',
        error: e,
        stackTrace: st,
        name: 'SessionCubit',
      );
      _access?.clear();
      emit(const SessionUnauthenticated());
      return;
    }

    result.fold(
      (failure) {
        _access?.clear();
        emit(const SessionUnauthenticated());
        _error(failure);
      },
      (user) {
        if (user == null) {
          _access?.clear();
          emit(const SessionUnauthenticated());
        } else {
          emit(SessionAuthenticated(user));
          final access = _access;
          if (access != null) unawaited(access.load());
        }
      },
    );
  }

  @override
  void onAuthenticated(UserEntity user) {
    emit(SessionAuthenticated(user));
    final access = _access;
    if (access != null) unawaited(access.load());
  }

  void updateUser(UserEntity user) {
    if (state is SessionAuthenticated) emit(SessionAuthenticated(user));
  }

  Future<void> signOut() async {\n    await signOutWithResult();\n  }\n\n  Future<bool> signOutWithResult() async {
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

    if (result == null) {
      _error(UnexpectedFailure());
      return false;
    }

    return result.fold(
      (failure) {
        _error(failure);
        return false;
      },
      (_) {
        _access?.clear();
        emit(const SessionUnauthenticated());
        _flash.post(AuthKeys.signOutSuccess, MessageType.success);
        return true;
      },
    );
  }
}
