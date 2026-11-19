import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/field_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_authenticator.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/confirm_new_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/login_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/register_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/send_reset_code_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/signin_with_google_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/login/login_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/localized_app.dart';
import 'support/fake_auth_repository.dart';

class _MockSession extends Mock implements SessionAuthenticator {}

void main() {
  setUpAll(() {
    registerFallbackValue(testUser);
    useTranslations(const Locale('en'));
  });

  late FakeAuthRepository repo;
  late _MockSession session;
  late AuthFlowCubit cubit;

  setUp(() {
    repo = FakeAuthRepository();
    session = _MockSession();
    cubit = AuthFlowCubit(
      login: LoginUseCase(repository: repo, emailDomain: 'store.local'),
      register: RegisterUseCase(repository: repo),
      googleSignIn: SignInWithGoogleUseCase(repository: repo),
      sendResetCode: SendResetCodeUseCase(repository: repo),
      confirmNewPassword: ConfirmNewPasswordUseCase(repository: repo),
      session: session,
      flash: FlashMessages(),
    );
    addTearDown(cubit.close);
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    setScreenSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      buildTestApp(
        home: BlocProvider<AuthFlowCubit>.value(
          value: cubit,
          child: const LoginScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the wordmark, username and password only', (tester) async {
    await pumpLogin(tester);

    expect(find.text('vaude'), findsOneWidget);
    expect(find.text(FieldKeys.username.en), findsWidgets);
    expect(find.text(FieldKeys.password.en), findsWidgets);
    // Decision 65: no e-mail field, Google, sign-up or recovery link.
    expect(find.text(FieldKeys.email.en), findsNothing);
    expect(find.textContaining('Google'), findsNothing);
    expect(find.textContaining('Create'), findsNothing);
    expect(find.text('Forgot password?'), findsNothing);
    // Recovery is the administrator's job.
    expect(find.textContaining('Contact your system administrator'),
        findsOneWidget);
  });

  testWidgets('empty fields are rejected without calling the server', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(repo.calls, isEmpty);
  });

  testWidgets('submits the typed username and password', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Admin');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(repo.calls, ['login']);
    expect(repo.lastLoginEmail, 'admin@store.local');
  });

  testWidgets('a rejection appears in an inline banner, and can be closed', (
    tester,
  ) async {
    repo.authResult = Left(UnauthorizedFailure());
    await pumpLogin(tester);
    expect(find.byType(InlineBanner), findsNothing);

    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    final banner = find.byType(InlineBanner);
    expect(banner, findsOneWidget);
    expect(
      tester.widget<InlineBanner>(banner).messageKey,
      UnauthorizedFailure().messageKey,
    );

    // Closing it by hand removes it.
    await tester.tap(
      find.descendant(of: banner, matching: find.byType(AppIconButton)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InlineBanner), findsNothing);
  });
}
