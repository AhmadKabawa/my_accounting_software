import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
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
                        dirty: true,
                        onDiscard: () => discarded++,
                        child: const Text('Form'),
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
              state: AppPageState.error,
              child: const Text('Form'),
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
            onSave: () {},
            saving: true,
            child: const Text('Form'),
          ),
        ),
      ),
    );

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.isLoading, isTrue);
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  testWidgets('loading stays inside the scroll viewport without Expanded', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FormPageTemplate(
            titleKey: TemplateKeys.save,
            state: AppPageState.loading,
            child: const Text('Form'),
          ),
        ),
      ),
    );
    final scroll = find.byType(SingleChildScrollView);
    expect(scroll, findsOneWidget);
    expect(
      find.descendant(of: scroll, matching: find.byType(Expanded)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state is vertically centered in the scroll viewport', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FormPageTemplate(
            titleKey: TemplateKeys.save,
            state: AppPageState.empty,
            child: const Text('Form'),
          ),
        ),
      ),
    );
    expect(find.byType(AppEmptyState), findsOneWidget);
    final emptyCenter = tester.getCenter(find.byType(AppEmptyState));
    final viewportCenter = tester.getCenter(find.byType(SingleChildScrollView));
    expect((emptyCenter.dy - viewportCenter.dy).abs(), lessThan(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling discard keeps the form and does not discard', (
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
                        dirty: true,
                        onDiscard: () => discarded++,
                        child: const Text('Form'),
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
    await tester.tap(find.text(CommonKeys.cancel.en));
    await tester.pumpAndSettle();
    expect(find.text('Form'), findsOneWidget);
    expect(find.byType(ConfirmDialogContent), findsNothing);
    expect(discarded, 0);
  });
}
