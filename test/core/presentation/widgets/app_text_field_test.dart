import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  Future<TextField> pumpField(
    WidgetTester tester, {
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
  }) async {
    final controller = TextEditingController(text: 'Alpha');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            labelKey: CatalogUiKeys.search,
            enabled: enabled,
            readOnly: readOnly,
            onTap: onTap,
          ),
        ),
      ),
    );
    return tester.widget<TextField>(find.byType(TextField));
  }

  testWidgets('defaults stay editable and enabled', (tester) async {
    final field = await pumpField(tester);
    expect(field.enabled, isTrue);
    expect(field.readOnly, isFalse);
  });

  testWidgets('read-only keeps the enabled look and reports taps', (
    tester,
  ) async {
    var taps = 0;
    final field = await pumpField(tester, readOnly: true, onTap: () => taps++);

    expect(field.enabled, isTrue);
    expect(field.readOnly, isTrue);
    await tester.tap(find.byType(TextField));
    expect(taps, 1);
  });

  testWidgets('disabled is a different state from read-only', (tester) async {
    final field = await pumpField(tester, enabled: false);
    expect(field.enabled, isFalse);
  });
}
