import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import '../../../helpers/localized_app.dart';

List<String> _labels(SemanticsNode root) {
  final labels = <String>[];
  void visit(SemanticsNode node) {
    final label = node.getSemanticsData().label;
    if (label.isNotEmpty) labels.add(label);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(root);
  return labels;
}

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
    final link = find.byType(TextButton);
    final size = tester.getSize(link);
    final minimum = AppComponentSize.hitArea.of(tester.element(link));
    expect(size.width, greaterThanOrEqualTo(minimum));
    expect(size.height, greaterThanOrEqualTo(minimum));
    final root =
        tester.binding.rootPipelineOwner.semanticsOwner!.rootSemanticsNode!;
    final occurrences = _labels(
      root,
    ).fold<int>(0, (total, label) => total + 'Save'.allMatches(label).length);
    expect(occurrences, 1);
    handle.dispose();
  });
}

void _noop() {}
