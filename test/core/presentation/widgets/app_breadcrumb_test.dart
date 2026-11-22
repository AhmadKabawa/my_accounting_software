import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
    testWidgets('separator follows $direction', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          direction: direction,
          home: const Scaffold(
            body: AppBreadcrumb(
              items: [
                AppBreadcrumbItem(label: TemplateKeys.defaultError),
                AppBreadcrumbItem(label: TemplateKeys.save),
              ],
            ),
          ),
        ),
      );
      expect(
        find.text(direction == TextDirection.rtl ? '‹' : '›'),
        findsOneWidget,
      );
    });
  }

  testWidgets('link hit target is sufficient and current label is unique', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          body: AppBreadcrumb(
            items: [
              AppBreadcrumbItem(label: TemplateKeys.defaultError, onTap: _noop),
              AppBreadcrumbItem(label: TemplateKeys.save),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final link = find.byType(TextButton);
    final size = tester.getSize(link);
    final minimum = AppComponentSize.hitArea.of(tester.element(link));
    expect(size.width, greaterThanOrEqualTo(minimum));
    expect(size.height, greaterThanOrEqualTo(minimum));
    expect(find.bySemanticsLabel('Save'), findsOneWidget);
    handle.dispose();
  });
}

void _noop() {}
