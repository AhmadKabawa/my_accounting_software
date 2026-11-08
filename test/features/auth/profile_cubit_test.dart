import 'dart:async';

import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_cached_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/update_profile_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/profile/profile_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/profile/presentation/localization/profile_keys.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_auth_repository.dart';

void main() {
  late StreamController<void> cleared;
  late FakeAuthRepository repo;
  late FlashMessages flash;
  late SessionCubit session;
  late ProfileCubit cubit;
  late List<FlashMessage> shown;

  setUp(() {
    cleared = StreamController<void>.broadcast(sync: true);
    repo = FakeAuthRepository();
    flash = FlashMessages();
    shown = [];
    flash.listen(shown.add);
    session = SessionCubit(
      getCurrentUser: GetCurrentUserUseCase(repository: repo),
      logout: LogoutUseCase(repository: repo),
      sessionCleared: cleared.stream,
      flash: flash,
    );
    cubit = ProfileCubit(
      updateProfile: UpdateProfileUseCase(repository: repo),
      changePassword: ChangePasswordUseCase(repository: repo),
      session: session,
      flash: flash,
    );
  });

  const updated = UserEntity(id: 'u1', email: 'a@b.c', fullName: 'New');

  tearDown(() async {
    await cubit.close();
    await session.close();
    await cleared.close();
  });

  const loadingThenIdle = [ProfileStatus.loading, ProfileStatus.idle];

  blocTest<ProfileCubit, ProfileStatus>(
    'loading is local: the session is never put in loading',
    setUp: () {
      session.onAuthenticated(testUser);
      repo.profile = Completer();
    },
    build: () => cubit,
    act: (c) async {
      final pending = c.updateProfile(fullName: 'x');

      expect(c.state, ProfileStatus.loading);
      expect(session.state, isA<SessionAuthenticated>());

      repo.profile!.complete(
        const Right(UserEntity(id: 'u1', email: 'a@b.c', fullName: 'x')),
      );
      await pending;
    },
    expect: () => loadingThenIdle,
  );

  blocTest<ProfileCubit, ProfileStatus>(
    'a successful update refreshes the session user and says so',
    setUp: () {
      session.onAuthenticated(testUser);
      repo.profileResult = const Right(updated);
    },
    build: () => cubit,
    act: (c) => c.updateProfile(fullName: 'New'),
    expect: () => loadingThenIdle,
    verify: (_) {
      expect((session.state as SessionAuthenticated).user, updated);
      expect(shown.single.key, ProfileKeys.profileUpdated);
      expect(shown.single.type, MessageType.success);
    },
  );

  blocTest<ProfileCubit, ProfileStatus>(
    'a failed update keeps the user and shows the error',
    setUp: () {
      session.onAuthenticated(testUser);
      repo.profileResult = Left(NetworkFailure());
    },
    build: () => cubit,
    act: (c) => c.updateProfile(fullName: 'New'),
    expect: () => loadingThenIdle,
    verify: (_) {
      expect((session.state as SessionAuthenticated).user, testUser);
      expect(shown.single.type, MessageType.error);
    },
  );

  blocTest<ProfileCubit, ProfileStatus>(
    'updating while signed out is refused without calling the server',
    build: () => cubit,
    act: (c) => c.updateProfile(fullName: 'x'),
    expect: () => <ProfileStatus>[],
    verify: (_) {
      expect(repo.calls, isEmpty);
      expect(shown.single.type, MessageType.error);
    },
  );

  blocTest<ProfileCubit, ProfileStatus>(
    'change password reports success',
    setUp: () => session.onAuthenticated(testUser),
    build: () => cubit,
    act: (c) => c.changePassword(currentPassword: 'a', newPassword: 'b'),
    expect: () => loadingThenIdle,
    verify: (_) {
      expect(repo.calls, ['changePassword']);
      expect(shown.single.key, ProfileKeys.passwordChanged);
    },
  );

  blocTest<ProfileCubit, ProfileStatus>(
    'a session cleared during the update is not overwritten',
    setUp: () {
      session.onAuthenticated(testUser);
      repo.profile = Completer();
    },
    build: () => cubit,
    act: (c) async {
      final pending = c.updateProfile(fullName: 'x');

      cleared.add(null);
      repo.profile!.complete(
        const Right(UserEntity(id: 'u1', email: 'a@b.c')),
      );
      await pending;
    },
    expect: () => loadingThenIdle,
    verify: (_) => expect(session.state, isA<SessionUnauthenticated>()),
  );
}
