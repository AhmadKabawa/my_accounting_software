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
import 'package:bloc_test/bloc_test.dart';
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

  const renamed = UserEntity(id: 'u1', email: 'a@b.c', fullName: 'New');

  test('starts in checking and exposes itself as a SessionGate', () {
    expect(cubit.state, isA<SessionChecking>());
    expect(cubit, isA<SessionGate>());
    expect(cubit.current, same(cubit.state));
  });

  blocTest<SessionCubit, SessionStatus>(
    'a stored user authenticates',
    setUp: () => repo.currentUser = const Right(testUser),
    build: () => cubit,
    act: (c) => c.checkAuthentication(),
    expect: () => [isA<SessionChecking>(), const SessionAuthenticated(testUser)],
  );

  blocTest<SessionCubit, SessionStatus>(
    'no stored user ends unauthenticated without a message',
    build: () => cubit,
    act: (c) => c.checkAuthentication(),
    expect: () => [isA<SessionChecking>(), isA<SessionUnauthenticated>()],
    verify: (_) => expect(shown, isEmpty),
  );

  blocTest<SessionCubit, SessionStatus>(
    'a throwing check ends signed out, never stuck in checking',
    setUp: () => repo.currentUserError = StateError('boom'),
    build: () => cubit,
    act: (c) => c.checkAuthentication(),
    expect: () => [isA<SessionChecking>(), isA<SessionUnauthenticated>()],
  );

  blocTest<SessionCubit, SessionStatus>(
    'a failed check says why',
    setUp: () => repo.currentUser = Left(NetworkFailure()),
    build: () => cubit,
    act: (c) => c.checkAuthentication(),
    expect: () => [isA<SessionChecking>(), isA<SessionUnauthenticated>()],
    verify: (_) {
      expect(shown.single.type, MessageType.error);
      expect(shown.single.key, NetworkFailure().messageKey);
    },
  );

  blocTest<SessionCubit, SessionStatus>(
    'onAuthenticated and updateUser change the user',
    build: () => cubit,
    act: (c) {
      c.onAuthenticated(testUser);
      c.updateUser(renamed);
    },
    expect: () => [
      const SessionAuthenticated(testUser),
      const SessionAuthenticated(renamed),
    ],
  );

  blocTest<SessionCubit, SessionStatus>(
    'updateUser is ignored when signed out',
    build: () => cubit,
    act: (c) => c.updateUser(testUser),
    expect: () => <Matcher>[],
  );

  blocTest<SessionCubit, SessionStatus>(
    'a cleared session moves to unauthenticated with an error',
    seed: () => const SessionAuthenticated(testUser),
    build: () => cubit,
    act: (_) => cleared.add(null),
    expect: () => [isA<SessionUnauthenticated>()],
    verify: (_) => expect(shown.single.type, MessageType.error),
  );

  blocTest<SessionCubit, SessionStatus>(
    'a deliberate sign-out is reported as success, not as expiry',
    seed: () => const SessionAuthenticated(testUser),
    build: () => cubit,
    act: (c) => c.signOut(),
    expect: () => [isA<SessionUnauthenticated>()],
    verify: (_) {
      expect(shown, hasLength(1));
      expect(shown.single.type, MessageType.success);
      expect(shown.single.key, AuthKeys.signOutSuccess);
    },
  );

  blocTest<SessionCubit, SessionStatus>(
    'a throwing sign-out still ends signed out with an error',
    seed: () => const SessionAuthenticated(testUser),
    setUp: () => repo.logoutError = StateError('boom'),
    build: () => cubit,
    act: (c) => c.signOut(),
    expect: () => [isA<SessionUnauthenticated>()],
    verify: (_) => expect(shown.single.type, MessageType.error),
  );

  test('messages posted with no listener replay to the first new one', () async {
    final late = FlashMessages()
      ..post(AuthKeys.signOutSuccess, MessageType.success);
    final got = <FlashMessage>[];
    late.listen(got.add);
    expect(got.single.key, AuthKeys.signOutSuccess);
    expect(late.pendingCount, 0);
  });
}
