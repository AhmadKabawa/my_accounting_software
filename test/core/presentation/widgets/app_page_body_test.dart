import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_body/app_page_body.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_header/app_page_header.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  const contentKey = Key('content');

  testWidgets('keeps content inside the maximum width and away from the edge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          body: AppPageBody(
            child: SizedBox(key: contentKey, height: 40, width: 4000),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byKey(contentKey));
    final left = tester.getTopLeft(find.byKey(contentKey)).dx;
    expect(size.width, lessThanOrEqualTo(1200));
    expect(left, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('pads content on a phone', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          body: AppPageBody(
            child: SizedBox(key: contentKey, height: 40, width: 4000),
          ),
        ),
      ),
    );

    final rect = tester.getRect(find.byKey(contentKey));
    expect(rect.left, greaterThan(0));
    expect(rect.right, lessThan(360));
    expect(tester.takeException(), isNull);
  });

  Widget listPage(int rows) => Scaffold(
    body: ListPageTemplate(
      titleKey: CatalogUiKeys.filters,
      count: rows,
      filterBar: FilterBar(
        onSearchChanged: (_) {},
        activeFilters: const [],
        onClearAll: () {},
      ),
      dataTable: AppDataTable<String>(
        columns: [
          DataTableColumn<String>(
            labelKey: CatalogUiKeys.search,
            priority: DataTableColumnPriority.primary,
            cellBuilder: (_, value) => Text(value),
          ),
        ],
        rows: [for (var i = 0; i < rows; i++) 'Item $i'],
        rowId: (value) => value,
      ),
    ),
  );

  for (final width in [360.0, 1200.0]) {
    testWidgets('the whole list page scrolls, not only the table ($width)', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          theme: AppTheme.light(),
          home: listPage(60),
        ),
      );
      expect(tester.takeException(), isNull);

      final before = tester.getTopLeft(find.byType(AppPageHeader)).dy;
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -500),
      );
      await tester.pump();
      final after = tester.getTopLeft(find.byType(AppPageHeader)).dy;

      expect(after, lessThan(before));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a bounded table still scrolls by itself', (tester) async {
    tester.view.physicalSize = const Size(1200, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppDataTable<String>(
            columns: [
              DataTableColumn<String>(
                labelKey: CatalogUiKeys.search,
                priority: DataTableColumnPriority.primary,
                cellBuilder: (_, value) => Text(value),
              ),
            ],
            rows: [for (var i = 0; i < 60; i++) 'Item $i'],
            rowId: (value) => value,
          ),
        ),
      ),
    );

    expect(find.byType(Scrollable), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
