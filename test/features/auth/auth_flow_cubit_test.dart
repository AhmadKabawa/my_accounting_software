import 'dart:async';

import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_authenticator.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/confirm_new_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/login_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/register_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/send_reset_code_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/signin_with_google_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_effect.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_auth_repository.dart';

/// Records who the flow reported as signed in.
class _FakeSession implements SessionAuthenticator {
  final authenticated = <UserEntity>[];

  @override
  void onAuthenticated(UserEntity user) => authenticated.add(user);
}

void main() {
  late FakeAuthRepository repo;
  late FlashMessages flash;
  late _FakeSession session;
  late AuthFlowCubit cubit;
  late List<FlashMessage> shown;
  late List<AuthFlowEffect> effects;
  late List<AuthFlowStatus> states;

  setUp(() {
    repo = FakeAuthRepository();
    flash = FlashMessages();
    shown = [];
    flash.listen(shown.add);
    session = _FakeSession();
    cubit = AuthFlowCubit(
      login: LoginUseCase(repository: repo),
      register: RegisterUseCase(repository: repo),
      googleSignIn: SignInWithGoogleUseCase(repository: repo),
      sendResetCode: SendResetCodeUseCase(repository: repo),
      confirmNewPassword: ConfirmNewPasswordUseCase(repository: repo),
      session: session,
      flash: flash,
    );
    effects = [];
    states = [];
    cubit.effectStream.listen(effects.add);
    cubit.stream.listen(states.add);
  });

  tearDown(() async {
    await cubit.close();
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('sign in', () {
    test('success authenticates the session and says so', () async {
      await cubit.signInWithEmail(email: 'a@b.c', password: 'x');
      await settle();

      expect(states, [AuthFlowStatus.loading, AuthFlowStatus.idle]);
      expect(session.authenticated, [testUser]);
      expect(shown.single.key, AuthKeys.signInSuccess);
      expect(shown.single.type, MessageType.success);
    });

    test('failure does not authenticate the session and shows the error', () async {
      repo.authResult = Left(UnauthorizedFailure());
      await cubit.signInWithEmail(email: 'a@b.c', password: 'bad');

      expect(session.authenticated, isEmpty);
      expect(shown.single.type, MessageType.error);
      expect(cubit.state, AuthFlowStatus.idle);
    });

    test('a second call while loading is ignored', () async {
      await Future.wait([
        cubit.signInWithEmail(email: 'a@b.c', password: 'x'),
        cubit.signInWithEmail(email: 'a@b.c', password: 'x'),
      ]);
      expect(repo.calls.where((c) => c == 'login'), hasLength(1));
    });

    test('google sign-in authenticates the session', () async {
      await cubit.signInWithGoogle();
      expect(session.authenticated, [testUser]);
      expect(repo.calls, ['google']);
    });
  });

  group('register', () {
    test('success authenticates and reports sign-up', () async {
      await cubit.signUpWithEmail(
        email: 'a@b.c',
        password: 'x',
        fullName: 'Ann',
      );
      expect(session.authenticated, [testUser]);
      expect(shown.single.key, AuthKeys.signUpSuccess);
    });

    test('failure shows the error only', () async {
      repo.authResult = Left(ValidationFailure());
      await cubit.signUpWithEmail(email: 'a@b.c', password: 'x', fullName: 'A');
      expect(session.authenticated, isEmpty);
      expect(shown.single.type, MessageType.error);
    });
  });

  group('password recovery', () {
    test('sending the code emits an effect carrying the e-mail', () async {
      await cubit.sendResetCode(email: 'a@b.c');
      await settle();

      expect(effects.single, isA<ResetCodeSentEffect>());
      expect((effects.single as ResetCodeSentEffect).email, 'a@b.c');
      expect(shown.single.key, AuthKeys.emailSent);
    });

    test('a failed send emits no navigation effect', () async {
      repo.unitResult = Left(NetworkFailure());
      await cubit.sendResetCode(email: 'a@b.c');
      await settle();

      expect(effects, isEmpty);
      expect(shown.single.type, MessageType.error);
    });

    test('confirming the new password signals the page to leave', () async {
      await cubit.confirmNewPassword(
        email: 'a@b.c',
        code: '123456',
        newPassword: 'Secret123',
      );
      await settle();

      expect(effects.single, isA<PasswordResetEffect>());
      expect(shown.single.key, AuthKeys.passwordResetSuccess);
      // Recovery never signs the user in.
      expect(session.authenticated, isEmpty);
    });
  });
}
