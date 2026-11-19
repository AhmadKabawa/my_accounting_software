import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import '../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('confirming discard exits and shows the guard only once', (
    tester,
  ) async {
    var discarded = 0;

    await tester.pumpWidget(
      buildTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: FormPageTemplate(
                        titleKey: TemplateKeys.save,
                        child: const Text('Form'),
                        dirty: true,
                        onDiscard: () => discarded++,
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    await Navigator.of(
      tester.element(find.byType(FormPageTemplate)),
    ).maybePop();
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmDialogContent), findsOneWidget);

    await tester.tap(find.text(CommonKeys.confirm.en));
    await tester.pumpAndSettle();

    expect(find.text('Open form'), findsOneWidget);
    expect(find.byType(ConfirmDialogContent), findsNothing);
    expect(discarded, 1);
  });

  testWidgets(
    'uses the registered default message for an error without a key',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: FormPageTemplate(
              titleKey: TemplateKeys.save,
              child: const Text('Form'),
              state: AppPageState.error,
            ),
          ),
        ),
      );

      expect(find.text(TemplateKeys.defaultError.en), findsOneWidget);
    },
  );

  testWidgets('uses a ListView child without nesting another scroll view', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FormPageTemplate(
            titleKey: TemplateKeys.save,
            child: ListView(children: const [Text('Scrollable form row')]),
          ),
        ),
      ),
    );

    expect(find.text('Scrollable form row'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving disables the single save action and shows progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FormPageTemplate(
            titleKey: TemplateKeys.save,
            child: const Text('Form'),
            onSave: () {},
            saving: true,
          ),
        ),
      ),
    );

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.isLoading, isTrue);
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
