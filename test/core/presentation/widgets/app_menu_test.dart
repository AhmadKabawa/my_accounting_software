import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/shell_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';
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
  testWidgets('hit target is sufficient and tooltip label is not duplicated', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          body: AppMenu(
            entries: [
              AppMenuEntry(label: TemplateKeys.save, onSelected: _noop),
            ],
            tooltipKey: ShellKeys.userMenu,
          ),
        ),
      ),
    );
    final target = find
        .descendant(
          of: find.byType(AppMenu),
          matching: find.byType(ConstrainedBox),
        )
        .first;
    final size = tester.getSize(target);
    final minimum = AppComponentSize.hitArea.of(tester.element(target));
    expect(size.width, greaterThanOrEqualTo(minimum));
    expect(size.height, greaterThanOrEqualTo(minimum));
    final root =
        tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!;
    final occurrences = _labels(root).fold<int>(
      0,
      (total, label) => total + 'User menu'.allMatches(label).length,
    );
    expect(occurrences, 1);
    handle.dispose();
  });

  testWidgets('selecting an entry invokes its callback', (tester) async {
    var selected = false;
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppMenu(
            entries: [
              AppMenuEntry(
                label: TemplateKeys.save,
                onSelected: () => selected = true,
              ),
            ],
            tooltipKey: ShellKeys.userMenu,
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip(ShellKeys.userMenu.en));
    await tester.pumpAndSettle();
    await tester.tap(find.text(TemplateKeys.save.en));
    await tester.pumpAndSettle();
    expect(selected, isTrue);
  });
}

void _noop() {}
