import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  final columns = <DataTableColumn<String>>[
    DataTableColumn<String>(
      labelKey: CatalogUiKeys.search,
      sortKey: 'name',
      priority: DataTableColumnPriority.primary,
      cellBuilder: (_, value) => Text(value),
    ),
    DataTableColumn<String>(
      labelKey: CatalogUiKeys.filters,
      sortKey: 'status',
      priority: DataTableColumnPriority.secondary,
      cellBuilder: (_, value) => Text('Status: $value'),
    ),
  ];

  Future<void> pumpTable(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
    List<String> rows = const ['Alpha', 'Beta'],
    bool loading = false,
    bool dark = false,
    TextDirection direction = TextDirection.rtl,
    ValueChanged<DataTableSort>? onSort,
    ValueChanged<int>? onPageChanged,
    ValueChanged<int>? onPageSizeChanged,
    ValueChanged<Set<Object>>? onSelectionChanged,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(
        direction: direction,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: Scaffold(
          body: AppDataTable<String>(
            columns: columns,
            rows: rows,
            rowId: (value) => value,
            loading: loading,
            onSort: onSort,
            onPageChanged: onPageChanged,
            onPageSizeChanged: onPageSizeChanged,
            totalCount: 75,
            onSelectionChanged: onSelectionChanged,
          ),
        ),
      ),
    );
  }

  testWidgets('uses cards on phones and compact/full table on wider widths', (
    tester,
  ) async {
    await pumpTable(tester, size: const Size(360, 800));
    expect(find.byType(Card), findsNWidgets(2));

    await pumpTable(tester, size: const Size(900, 900));
    expect(find.byType(Card), findsNothing);
    expect(find.text('Status: Alpha'), findsNothing);

    await pumpTable(tester, size: const Size(1200, 900));
    expect(find.text('Status: Alpha'), findsOneWidget);
  });

  testWidgets('sorting and pagination are delegated to the data source', (
    tester,
  ) async {
    DataTableSort? requestedSort;
    var requestedPage = 0;
    var requestedSize = 0;
    await pumpTable(
      tester,
      onSort: (value) => requestedSort = value,
      onPageChanged: (value) => requestedPage = value,
      onPageSizeChanged: (value) => requestedSize = value,
    );

    await tester.tap(find.text('Search').first);
    expect(requestedSort?.key, 'name');
    expect(requestedSort?.ascending, isTrue);

    await tester.tap(find.text('Next').first);
    expect(requestedPage, 2);
    expect(requestedSize, 0);
  });

  testWidgets('supports selection and loading skeletons', (tester) async {
    Set<Object>? selected;
    await pumpTable(
      tester,
      onSelectionChanged: (value) => selected = value,
    );
    await tester.tap(find.byType(Checkbox).at(1));
    expect(selected, contains('Alpha'));

    await pumpTable(tester, loading: true);
    expect(find.byType(AppSkeleton), findsWidgets);
  });

  testWidgets('renders empty data safely in dark LTR at tablet width', (
    tester,
  ) async {
    await pumpTable(
      tester,
      size: const Size(600, 900),
      rows: const [],
      dark: true,
      direction: TextDirection.ltr,
    );
    expect(find.text('No data'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
