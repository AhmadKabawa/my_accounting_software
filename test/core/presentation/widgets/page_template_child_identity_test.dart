import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets(
    'FormPageTemplate retains its field when an error banner appears',
    (tester) async {
    var showError = false;
    late StateSetter update;

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return FormPageTemplate(
                titleKey: CatalogUiKeys.filters,
                state: showError ? AppPageState.error : AppPageState.content,
                errorKey: TemplateKeys.defaultError,
                child: const TextField(),
              );
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'form value survives');
    update(() => showError = true);
    await tester.pumpAndSettle();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'form value survives',
    );
  });

  testWidgets('DashboardTemplate retains its card field when error appears', (
    tester,
  ) async {
    var showError = false;
    late StateSetter update;

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return DashboardTemplate(
                titleKey: CatalogUiKeys.filters,
                state: showError ? AppPageState.error : AppPageState.content,
                errorKey: TemplateKeys.defaultError,
                cards: const [TextField()],
              );
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'dashboard value survives');
    update(() => showError = true);
    await tester.pumpAndSettle();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'dashboard value survives',
    );
  });
}
