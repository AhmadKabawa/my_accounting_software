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

  tearDown(() async {
    await cubit.close();
    await session.close();
    await cleared.close();
  });

  test('loading is local: the session is never put in loading', () async {
    session.onAuthenticated(testUser);
    repo.profile = Completer();
    final pending = cubit.updateProfile(fullName: 'x');

    expect(cubit.state, ProfileStatus.loading);
    expect(session.state, isA<SessionAuthenticated>());

    repo.profile!.complete(const Right(UserEntity(id: 'u1', email: 'a@b.c', fullName: 'x')));
    await pending;
    expect(cubit.state, ProfileStatus.idle);
  });

  test('a successful update refreshes the session user and says so', () async {
    session.onAuthenticated(testUser);
    const updated = UserEntity(id: 'u1', email: 'a@b.c', fullName: 'New');
    repo.profileResult = const Right(updated);

    await cubit.updateProfile(fullName: 'New');

    expect((session.state as SessionAuthenticated).user, updated);
    expect(shown.single.key, ProfileKeys.profileUpdated);
    expect(shown.single.type, MessageType.success);
  });

  test('a failed update keeps the user and shows the error', () async {
    session.onAuthenticated(testUser);
    repo.profileResult = Left(NetworkFailure());

    await cubit.updateProfile(fullName: 'New');

    expect((session.state as SessionAuthenticated).user, testUser);
    expect(shown.single.type, MessageType.error);
  });

  test('updating while signed out is refused without calling the server', () async {
    await cubit.updateProfile(fullName: 'x');
    expect(repo.calls, isEmpty);
    expect(shown.single.type, MessageType.error);
  });

  test('change password reports success', () async {
    session.onAuthenticated(testUser);
    await cubit.changePassword(currentPassword: 'a', newPassword: 'b');
    expect(repo.calls, ['changePassword']);
    expect(shown.single.key, ProfileKeys.passwordChanged);
  });

  test('a session cleared during the update is not overwritten', () async {
    session.onAuthenticated(testUser);
    repo.profile = Completer();
    final pending = cubit.updateProfile(fullName: 'x');

    cleared.add(null);
    repo.profile!.complete(const Right(UserEntity(id: 'u1', email: 'a@b.c')));
    await pending;

    expect(session.state, isA<SessionUnauthenticated>());
  });
}
