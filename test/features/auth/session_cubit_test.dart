import 'dart:async';

import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_cached_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_auth_repository.dart';

void main() {
  late StreamController<void> cleared;
  late FakeAuthRepository repo;
  late FlashMessages flash;
  late SessionCubit cubit;
  late List<FlashMessage> shown;

  setUp(() {
    cleared = StreamController<void>.broadcast(sync: true);
    repo = FakeAuthRepository(onLogout: () => cleared.add(null));
    flash = FlashMessages();
    shown = [];
    flash.listen(shown.add);
    cubit = SessionCubit(
      getCurrentUser: GetCurrentUserUseCase(repository: repo),
      logout: LogoutUseCase(repository: repo),
      sessionCleared: cleared.stream,
      flash: flash,
    );
  });

  tearDown(() async {
    await cubit.close();
    await cleared.close();
  });

  test('starts in checking and exposes itself as a SessionGate', () {
    expect(cubit.state, isA<SessionChecking>());
    expect(cubit, isA<SessionGate>());
    expect(cubit.current, same(cubit.state));
  });

  test('a stored user authenticates', () async {
    repo.currentUser = const Right(testUser);
    await cubit.checkAuthentication();
    expect(cubit.state, const SessionAuthenticated(testUser));
  });

  test('no stored user ends unauthenticated without a message', () async {
    await cubit.checkAuthentication();
    expect(cubit.state, isA<SessionUnauthenticated>());
    expect(shown, isEmpty);
  });

  test('a throwing check ends signed out, never stuck in checking', () async {
    repo.currentUserError = StateError('boom');
    await cubit.checkAuthentication();
    expect(cubit.state, isA<SessionUnauthenticated>());
  });

  test('a failed check says why', () async {
    repo.currentUser = Left(NetworkFailure());
    await cubit.checkAuthentication();
    expect(cubit.state, isA<SessionUnauthenticated>());
    expect(shown.single.type, MessageType.error);
    expect(shown.single.key, NetworkFailure().messageKey);
  });

  test('onAuthenticated and updateUser change the user', () {
    cubit.onAuthenticated(testUser);
    expect(cubit.state, const SessionAuthenticated(testUser));
    const renamed = UserEntity(id: 'u1', email: 'a@b.c', fullName: 'New');
    cubit.updateUser(renamed);
    expect((cubit.state as SessionAuthenticated).user, renamed);
  });

  test('updateUser is ignored when signed out', () {
    cubit.updateUser(testUser);
    expect(cubit.state, isA<SessionChecking>());
  });

  test('a cleared session moves to unauthenticated with an error', () {
    cubit.onAuthenticated(testUser);
    cleared.add(null);
    expect(cubit.state, isA<SessionUnauthenticated>());
    expect(shown.single.type, MessageType.error);
  });

  test('a deliberate sign-out is reported as success, not as expiry', () async {
    cubit.onAuthenticated(testUser);
    await cubit.signOut();
    expect(cubit.state, isA<SessionUnauthenticated>());
    expect(shown, hasLength(1));
    expect(shown.single.type, MessageType.success);
    expect(shown.single.key, AuthKeys.signOutSuccess);
  });

  test('a throwing sign-out still ends signed out with an error', () async {
    cubit.onAuthenticated(testUser);
    repo.logoutError = StateError('boom');
    await cubit.signOut();
    expect(cubit.state, isA<SessionUnauthenticated>());
    expect(shown.single.type, MessageType.error);
  });

  test('messages posted with no listener replay to the first new one', () async {
    final late = FlashMessages()..post(AuthKeys.signOutSuccess, MessageType.success);
    final got = <FlashMessage>[];
    late.listen(got.add);
    expect(got.single.key, AuthKeys.signOutSuccess);
    expect(late.pendingCount, 0);
  });
}
