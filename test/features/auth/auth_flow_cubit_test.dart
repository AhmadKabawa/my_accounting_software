import 'dart:async';

import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_authenticator.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/confirm_new_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/login_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/register_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/send_reset_code_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/signin_with_google_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_effect.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'support/fake_auth_repository.dart';

class _MockSession extends Mock implements SessionAuthenticator {}

void main() {
  late FakeAuthRepository repo;
  late FlashMessages flash;
  late _MockSession session;
  late AuthFlowCubit cubit;
  late List<FlashMessage> shown;
  late List<AuthFlowEffect> effects;

  // mocktail needs a sample value to match `any()` on a UserEntity.
  setUpAll(() => registerFallbackValue(testUser));

  setUp(() {
    repo = FakeAuthRepository();
    flash = FlashMessages();
    shown = [];
    flash.listen(shown.add);
    session = _MockSession();
    cubit = AuthFlowCubit(
      login: LoginUseCase(repository: repo),
      register: RegisterUseCase(repository: repo),
      googleSignIn: SignInWithGoogleUseCase(repository: repo),
      sendResetCode: SendResetCodeUseCase(repository: repo),
      confirmNewPassword: ConfirmNewPasswordUseCase(repository: repo),
      session: session,
      flash: flash,
    );
    // One-time effects are not part of the state: collect them from the stream.
    effects = [];
    cubit.effectStream.listen(effects.add);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  const loadingThenIdle = [AuthFlowStatus.loading, AuthFlowStatus.idle];

  group('sign in', () {
    blocTest<AuthFlowCubit, AuthFlowStatus>(
      'success authenticates the session and says so',
      build: () => cubit,
      act: (c) => c.signInWithEmail(email: 'a@b.c', password: 'x'),
      expect: () => loadingThenIdle,
      verify: (_) {
        verify(() => session.onAuthenticated(testUser)).called(1);
        expect(shown.single.key, AuthKeys.signInSuccess);
        expect(shown.single.type, MessageType.success);
      },
    );

    blocTest<AuthFlowCubit, AuthFlowStatus>(
      'failure does not authenticate the session and shows the error',
      setUp: () => repo.authResult = Left(UnauthorizedFailure()),
      build: () => cubit,
      act: (c) => c.signInWithEmail(email: 'a@b.c', password: 'bad'),
      expect: () => loadingThenIdle,
      verify: (_) {
        verifyNever(() => session.onAuthenticated(any()));
        expect(shown.single.type, MessageType.error);
      },
    );

    blocTest<AuthFlowCubit, AuthFlowStatus>(
      'a second call while loading is ignored',
      build: () => cubit,
      act: (c) => Future.wait([
        c.signInWithEmail(email: 'a@b.c', password: 'x'),
        c.signInWithEmail(email: 'a@b.c', password: 'x'),
      ]),
      expect: () => loadingThenIdle,
      verify: (_) =>
          expect(repo.calls.where((c) => c == 'login'), hasLength(1)),
    );

    blocTest<AuthFlowCubit, AuthFlowStatus>(
      'google sign-in authenticates the session',
      build: () => cubit,
      act: (c) => c.signInWithGoogle(),
      expect: () => loadingThenIdle,
      verify: (_) {
        verify(() => session.onAuthenticated(testUser)).called(1);
        expect(repo.calls, ['google']);
      },
    );
  });

  group('register', () {
    blocTest<AuthFlowCubit, AuthFlowStatus>(
      'success authenticates and reports sign-up',
      build: () => cubit,
      act: (c) =>
          c.signUpWithEmail(email: 'a@b.c', password: 'x', fullName: 'Ann'),
      expect: () => loadingThenIdle,
      verify: (_) {
        verify(() => session.onAuthenticated(testUser)).called(1);
        expect(shown.single.key, AuthKeys.signUpSuccess);
      },
    );

    blocTest<AuthFlowCubit, AuthFlowStatus>(
      'failure shows the error only',
      setUp: () => repo.authResult = Left(ValidationFailure()),
      build: () => cubit,
      act: (c) =>
          c.signUpWithEmail(email: 'a@b.c', password: 'x', fullName: 'A'),
      expect: () => loadingThenIdle,
      verify: (_) {
        verifyNever(() => session.onAuthenticated(any()));
        expect(shown.single.type, MessageType.error);
      },
    );
  });

  group('password recovery', () {
    blocTest<AuthFlowCubit, AuthFlowStatus>(
      'sending the code emits an effect carrying the e-mail',
      build: () => cubit,
      act: (c) async {
        await c.sendResetCode(email: 'a@b.c');
        await settle();
      },
      expect: () => loadingThenIdle,
      verify: (_) {
        expect(effects.single, isA<ResetCodeSentEffect>());
        expect((effects.single as ResetCodeSentEffect).email, 'a@b.c');
        expect(shown.single.key, AuthKeys.emailSent);
      },
    );

    blocTest<AuthFlowCubit, AuthFlowStatus>(
      'a failed send emits no navigation effect',
      setUp: () => repo.unitResult = Left(NetworkFailure()),
      build: () => cubit,
      act: (c) async {
        await c.sendResetCode(email: 'a@b.c');
        await settle();
      },
      expect: () => loadingThenIdle,
      verify: (_) {
        expect(effects, isEmpty);
        expect(shown.single.type, MessageType.error);
      },
    );

    blocTest<AuthFlowCubit, AuthFlowStatus>(
      'confirming the new password signals the page to leave',
      build: () => cubit,
      act: (c) async {
        await c.confirmNewPassword(
          email: 'a@b.c',
          code: '123456',
          newPassword: 'Secret123',
        );
        await settle();
      },
      expect: () => loadingThenIdle,
      verify: (_) {
        expect(effects.single, isA<PasswordResetEffect>());
        expect(shown.single.key, AuthKeys.passwordResetSuccess);
        // Recovery never signs the user in.
        verifyNever(() => session.onAuthenticated(any()));
      },
    );
  });
}
