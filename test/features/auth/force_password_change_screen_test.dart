import 'dart:async';

import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/force_change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_cached_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_must_change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/force_password/force_password_change_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/change_password/force_password_change_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/localized_app.dart';
import 'support/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late StreamController<void> cleared;
  late SessionCubit session;
  late ForcePasswordChangeCubit cubit;

  setUp(() async {
    useTranslations(const Locale('en'));
    repository = FakeAuthRepository();
    cleared = StreamController<void>.broadcast(sync: true);
    session = SessionCubit(
      getCurrentUser: GetCurrentUserUseCase(repository: repository),
      getMustChangePassword: GetMustChangePasswordUseCase(repository),
      logout: LogoutUseCase(repository: repository),
      sessionCleared: cleared.stream,
      flash: FlashMessages(),
    );
    session.onAuthenticated(testUser);
    await Future<void>.delayed(Duration.zero);
    cubit = ForcePasswordChangeCubit(
      changePassword: ForceChangePasswordUseCase(repository),
      session: session,
    );
  });

  tearDown(() async {
    await cubit.close();
    await session.close();
    await cleared.close();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    Size size = const Size(360, 800),
    TextDirection direction = TextDirection.rtl,
  }) async {
    setScreenSize(tester, size);
    await tester.pumpWidget(
      buildTestApp(
        direction: direction,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SessionCubit>.value(value: session),
            BlocProvider<ForcePasswordChangeCubit>.value(value: cubit),
          ],
          child: const ForcePasswordChangeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enterValidPassword(
    WidgetTester tester, {
    String confirm = 'Password1!',
  }) async {
    await tester.enterText(find.byType(TextField).at(0), 'Password1!');
    await tester.enterText(find.byType(TextField).at(1), confirm);
  }

  testWidgets('renders two obscured fields and a visible sign-out action', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).obscureText,
      isTrue,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
      isTrue,
    );
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('rejects passwords below the minimum length', (tester) async {
    await pumpScreen(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Short1!');
    await tester.enterText(find.byType(TextField).at(1), 'Short1!');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.calls, isEmpty);
  });

  testWidgets('rejects confirmation that does not match', (tester) async {
    await pumpScreen(tester);
    await enterValidPassword(tester, confirm: 'Password2!');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.calls, isEmpty);
  });

  testWidgets('shows saving state until the server operation completes', (
    tester,
  ) async {
    final pending = Completer<Either<Failure, Unit>>();
    repository.forcedPassword = pending;
    await pumpScreen(tester);
    await enterValidPassword(tester);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(cubit.state.status, ForcePasswordChangeStatus.saving);
    expect(
      tester.widget<AppButton>(find.byType(AppButton).last).isLoading,
      isTrue,
    );

    pending.complete(const Right(unit));
    await tester.pumpAndSettle();
    expect(cubit.state.status, ForcePasswordChangeStatus.completed);
    expect(
      (session.current as SessionAuthenticated).mustChangePassword,
      isFalse,
    );
  });

  testWidgets(
    'shows a translated inline error when the server rejects the save',
    (tester) async {
      repository.unitResult = Left(NetworkFailure());
      await pumpScreen(tester);
      await enterValidPassword(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.byType(InlineBanner), findsOneWidget);
      expect(
        tester.widget<InlineBanner>(find.byType(InlineBanner)).messageKey,
        NetworkFailure().messageKey,
      );
    },
  );

  testWidgets('fits phone and desktop widths in both text directions', (
    tester,
  ) async {
    for (final size in [const Size(360, 800), const Size(1200, 900)]) {
      for (final direction in [TextDirection.rtl, TextDirection.ltr]) {
        await pumpScreen(tester, size: size, direction: direction);
        expect(tester.takeException(), isNull);
        expect(find.byType(ForcePasswordChangeScreen), findsOneWidget);
      }
    }
  });

  testWidgets('sign-out remains available while password change is required', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(session.current, isA<SessionUnauthenticated>());
  });
}
