import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_grid.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/equal_height_row.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import '../../../helpers/localized_app.dart';

Future<void> _pump(
  WidgetTester tester, {
  Size size = const Size(1280, 800),
  double contentWidth = double.infinity,
  Set<Object>? selected,
}) async {
  setScreenSize(tester, size);
  await tester.pumpWidget(
    buildTestApp(
      direction: TextDirection.ltr,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: contentWidth,
            child: AppDataGrid<String>(
              rows: const [
                'short',
                'a very long record name\nwith\nthree\nlines',
              ],
              rowId: (row) => row,
              gridItemBuilder: (_, row) => Text(row),
              selectedIds: selected ?? const {},
              onSelectionChanged: selected == null ? null : (_) {},
              rowActionsBuilder: (_, _) => const AppRowActions(
                primary: [
                  AppRowAction(
                    icon: AppIcons.edit,
                    labelKey: CatalogUiKeys.select,
                    onPressed: _noop,
                  ),
                ],
                overflow: [
                  AppRowAction(
                    icon: AppIcons.delete,
                    labelKey: CatalogUiKeys.removeSort,
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void _noop() {}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('tiles in one row share the tallest tile height', (tester) async {
    await _pump(tester);

    final cards = find.byType(AppCard);
    expect(cards, findsNWidgets(2));
    expect(
      tester.getSize(cards.at(0)).height,
      tester.getSize(cards.at(1)).height,
    );
  });

  testWidgets('selection mode keeps equal and unchanged heights', (
    tester,
  ) async {
    await _pump(tester);
    final cards = find.byType(AppCard);
    final before = [
      tester.getSize(cards.at(0)).height,
      tester.getSize(cards.at(1)).height,
    ];

    await _pump(tester, selected: {'short'});

    final selectedCards = find.byType(AppCard);
    expect(tester.getSize(selectedCards.at(0)).height, before[0]);
    expect(tester.getSize(selectedCards.at(1)).height, before[1]);
    expect(
      tester.getSize(selectedCards.at(0)).height,
      tester.getSize(selectedCards.at(1)).height,
    );
  });

  testWidgets('checkbox and actions do not overlap on a narrow tile', (
    tester,
  ) async {
    await _pump(
      tester,
      size: const Size(280, 800),
      contentWidth: 160,
      selected: {},
    );

    final checkbox = tester.getRect(find.byType(Checkbox).first);
    final actions = tester.getRect(find.byType(AppRowActions).first);
    final gap = actions.left - checkbox.right;
    expect(
      gap,
      greaterThanOrEqualTo(0),
      reason: 'checkbox=$checkbox actions=$actions gap=$gap',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('EqualHeightRow lays out equal cells in mirrored RTL order', (
    tester,
  ) async {
    const rowKey = ValueKey('equal-height-row');
    const shortKey = ValueKey('short');
    const tallKey = ValueKey('tall');
    const mediumKey = ValueKey('medium');
    const emptyKey = ValueKey('empty');

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 330,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: EqualHeightRow(
                  key: rowKey,
                  gap: 10,
                  children: const [
                    SizedBox(key: shortKey, height: 20),
                    SizedBox(key: tallKey, height: 40),
                    SizedBox(key: mediumKey, height: 30),
                    SizedBox.shrink(key: emptyKey),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final short = tester.getRect(find.byKey(shortKey));
    final tall = tester.getRect(find.byKey(tallKey));
    final medium = tester.getRect(find.byKey(mediumKey));
    final empty = tester.getRect(find.byKey(emptyKey));
    expect(short.height, 40);
    expect(tall.height, 40);
    expect(medium.height, 40);
    expect(empty.height, 40);
    expect(short.left, greaterThan(tall.left));
    expect(tall.left, greaterThan(medium.left));
    expect(medium.left, greaterThan(empty.left));
    expect(tester.takeException(), isNull);
  });
}
