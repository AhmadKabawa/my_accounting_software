import 'dart:async';

import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/dialog_keys.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_key.dart';

const _title = TestKey('test.confirm.title');
const _message = TestKey('test.confirm.message');
const _impact = TestKey('test.confirm.impact');

const _desktop = Size(1280, 800);
const _mobile = Size(360, 800);

/// What the last dialog completed with; null while it is still open.
bool? _result;

Future<void> _open(
  WidgetTester tester, {
  Size size = _desktop,
  ConfirmDialogSeverity severity = ConfirmDialogSeverity.normal,
  List<TestKey> impactKeys = const [],
  String? targetName,
  bool requireTypedName = false,
  ConfirmAction? onConfirm,
}) async {
  _result = null;
  setScreenSize(tester, size);
  await tester.pumpWidget(
    buildTestApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              _result = await showConfirmDialog(
                context,
                titleKey: _title,
                messageKey: _message,
                severity: severity,
                impactKeys: impactKeys,
                targetName: targetName,
                requireTypedName: requireTypedName,
                onConfirm: onConfirm,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Finder _button(Object labelKey) => find.byWidgetPredicate(
  (w) => w is AppButton && w.labelKey == labelKey,
);

AppButton _appButton(WidgetTester tester, Object labelKey) =>
    tester.widget<AppButton>(_button(labelKey));

void main() {
  setUp(() => useTranslations(const Locale('ar')));

  group('placement', () {
    testWidgets('normal on mobile is a bottom sheet', (tester) async {
      await _open(tester, size: _mobile);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('normal on desktop is a centered dialog', (tester) async {
      await _open(tester);

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('critical on mobile is a centered dialog, not a sheet', (
      tester,
    ) async {
      await _open(
        tester,
        size: _mobile,
        severity: ConfirmDialogSeverity.critical,
      );

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });
  });

  group('normal', () {
    testWidgets('confirm closes with true', (tester) async {
      await _open(tester);

      await tester.tap(_button(CommonKeys.confirm));
      await tester.pumpAndSettle();

      expect(_result, isTrue);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('cancel closes with false', (tester) async {
      await _open(tester);

      await tester.tap(_button(CommonKeys.cancel));
      await tester.pumpAndSettle();

      expect(_result, isFalse);
    });
  });

  group('warning', () {
    testWidgets('lists what will change', (tester) async {
      await _open(
        tester,
        severity: ConfirmDialogSeverity.warning,
        impactKeys: const [_impact],
      );

      expect(find.text(DialogKeys.impactTitle.ar), findsOneWidget);
      expect(find.text('test.confirm.impact'), findsOneWidget);
    });
  });

  group('critical', () {
    testWidgets('focus starts on cancel, not on confirm', (tester) async {
      await _open(tester, severity: ConfirmDialogSeverity.critical);

      expect(_appButton(tester, CommonKeys.cancel).autofocus, isTrue);
      expect(_appButton(tester, CommonKeys.confirm).autofocus, isFalse);
    });

    testWidgets('shows the target name', (tester) async {
      await _open(
        tester,
        severity: ConfirmDialogSeverity.critical,
        targetName: 'Main branch',
      );

      expect(find.text('Main branch'), findsOneWidget);
    });

    testWidgets('Esc cancels', (tester) async {
      await _open(tester, severity: ConfirmDialogSeverity.critical);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(_result, isFalse);
    });

    testWidgets('a tap outside does not dismiss it', (tester) async {
      await _open(tester, severity: ConfirmDialogSeverity.critical);

      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();

      expect(_result, isNull);
      expect(find.byType(Dialog), findsOneWidget);
    });
  });

  group('typed name (irreversible actions only)', () {
    Future<void> openTyped(WidgetTester tester) => _open(
      tester,
      severity: ConfirmDialogSeverity.critical,
      targetName: 'Main branch',
      requireTypedName: true,
    );

    testWidgets('confirm stays disabled until the exact name is typed', (
      tester,
    ) async {
      await openTyped(tester);
      expect(_appButton(tester, CommonKeys.confirm).onPressed, isNull);

      await tester.enterText(find.byType(TextFormField), 'Main');
      await tester.pump();
      expect(_appButton(tester, CommonKeys.confirm).onPressed, isNull);

      await tester.enterText(find.byType(TextFormField), 'Main branch');
      await tester.pump();
      expect(_appButton(tester, CommonKeys.confirm).onPressed, isNotNull);
    });

    testWidgets('the match is case sensitive', (tester) async {
      await openTyped(tester);

      await tester.enterText(find.byType(TextFormField), 'main branch');
      await tester.pump();

      expect(_appButton(tester, CommonKeys.confirm).onPressed, isNull);
    });

    testWidgets('surrounding spaces are ignored', (tester) async {
      await openTyped(tester);

      await tester.enterText(find.byType(TextFormField), '  Main branch ');
      await tester.pump();

      expect(_appButton(tester, CommonKeys.confirm).onPressed, isNotNull);
    });

    testWidgets('no typed-name field unless it is required', (tester) async {
      await _open(
        tester,
        severity: ConfirmDialogSeverity.critical,
        targetName: 'Main branch',
      );

      expect(find.byType(TextFormField), findsNothing);
      expect(_appButton(tester, CommonKeys.confirm).onPressed, isNotNull);
    });
  });

  group('async confirm', () {
    testWidgets('a double tap runs the action once and shows loading', (
      tester,
    ) async {
      final gate = Completer<void>();
      var calls = 0;
      await _open(
        tester,
        onConfirm: () async {
          calls++;
          await gate.future;
          return null;
        },
      );

      await tester.tap(_button(CommonKeys.confirm));
      await tester.pump();
      await tester.tap(_button(CommonKeys.confirm), warnIfMissed: false);
      await tester.pump();

      expect(calls, 1);
      expect(_appButton(tester, CommonKeys.confirm).isLoading, isTrue);
      expect(_result, isNull);

      gate.complete();
      await tester.pumpAndSettle();
      expect(_result, isTrue);
    });

    testWidgets('cancel is disabled while the action runs', (tester) async {
      final gate = Completer<void>();
      await _open(
        tester,
        onConfirm: () async {
          await gate.future;
          return null;
        },
      );

      await tester.tap(_button(CommonKeys.confirm));
      await tester.pump();

      expect(_appButton(tester, CommonKeys.cancel).onPressed, isNull);

      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('a refusal shows inside the dialog and keeps it open', (
      tester,
    ) async {
      await _open(tester, onConfirm: () async => ErrorKeys.validation);

      await tester.tap(_button(CommonKeys.confirm));
      await tester.pumpAndSettle();

      expect(find.byType(InlineBanner), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
      expect(_result, isNull);
      // Back to idle: the user can retry or cancel.
      expect(_appButton(tester, CommonKeys.confirm).isLoading, isFalse);
      expect(_appButton(tester, CommonKeys.cancel).onPressed, isNotNull);
    });

    testWidgets('an exception is shown as the unknown error', (tester) async {
      await _open(tester, onConfirm: () async => throw StateError('boom'));

      await tester.tap(_button(CommonKeys.confirm));
      await tester.pumpAndSettle();

      expect(find.byType(InlineBanner), findsOneWidget);
      expect(find.text(CommonKeys.unknownError.ar), findsOneWidget);
      expect(_result, isNull);
    });

    testWidgets('a retry after a refusal can succeed', (tester) async {
      var attempt = 0;
      await _open(
        tester,
        onConfirm: () async => ++attempt == 1 ? ErrorKeys.validation : null,
      );

      await tester.tap(_button(CommonKeys.confirm));
      await tester.pumpAndSettle();
      await tester.tap(_button(CommonKeys.confirm));
      await tester.pumpAndSettle();

      expect(attempt, 2);
      expect(_result, isTrue);
    });
  });
}
