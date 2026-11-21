import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_key.dart';

const _title = TestKey('test.formDialog.title');
const _subtitle = TestKey('test.formDialog.subtitle');
const _error = TestKey('test.formDialog.error');
const _desktop = Size(1280, 800);
const _mobile = Size(360, 800);

bool? _result;

Finder _button(Object key) => find.byWidgetPredicate(
  (widget) => widget is AppButton && widget.labelKey == key,
);

AppButton _appButton(WidgetTester tester, Object key) =>
    tester.widget<AppButton>(_button(key));

Future<void> _open(
  WidgetTester tester, {
  Size size = _desktop,
  bool busy = false,
  bool dirty = false,
  AppKey? errorKey,
}) async {
  _result = null;
  setScreenSize(tester, size);
  await tester.pumpWidget(
    buildTestApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              _result = await showAppFormDialog<bool>(
                context,
                (_) => AppFormDialog(
                  titleKey: _title,
                  subtitleKey: _subtitle,
                  errorKey: errorKey,
                  dirty: dirty,
                  busy: busy,
                  onSave: () async {},
                  child: const SizedBox(height: 160),
                ),
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

void main() {
  setUp(() => useTranslations(const Locale('en')));

  testWidgets('busy blocks Escape, system back and cancel', (tester) async {
    await _open(tester, busy: true);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(_appButton(tester, CommonKeys.cancel).onPressed, isNull);
    expect(_appButton(tester, CommonKeys.save).isLoading, isTrue);
    expect(find.byType(Dialog), findsOneWidget);
    expect(_result, isNull);
  });

  testWidgets('dirty close asks for confirmation', (tester) async {
    await _open(tester, dirty: true);

    await tester.tap(_button(CommonKeys.cancel));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNWidgets(2));
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppButton && widget.labelKey == CommonKeys.confirm,
      ),
    );
    await tester.pumpAndSettle();

    expect(_result, isFalse);
  });

  testWidgets('clean close closes without confirmation', (tester) async {
    await _open(tester);

    await tester.tap(_button(CommonKeys.cancel));
    await tester.pumpAndSettle();

    expect(_result, isFalse);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('barrier tap does not dismiss the form', (tester) async {
    await _open(tester);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(_result, isNull);
  });

  testWidgets(
    'mobile uses a full-height sheet without overflow',
    (tester) async {
    await _open(tester, size: _mobile, errorKey: _error);

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clean Escape closes the form', (tester) async {
    await _open(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(_result, isFalse);
  });

  testWidgets(
    'dirty Escape uses the shared unsaved changes prompt',
    (tester) async {
    await _open(tester, dirty: true);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text(TemplateKeys.unsavedChanges.en), findsOneWidget);
  });
}
