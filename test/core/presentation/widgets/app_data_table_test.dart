import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
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
    double textScale = 1,
    TextDirection direction = TextDirection.rtl,
    ValueChanged<DataTableSort>? onSort,
    ValueChanged<int>? onPageChanged,
    ValueChanged<int>? onPageSizeChanged,
    ValueChanged<Set<Object>>? onSelectionChanged,
    bool hasMore = false,
    VoidCallback? onLoadMore,
    AppKey? errorKey,
    VoidCallback? onRetry,
    ValueChanged<String>? onRowActivated,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(
        direction: direction,
        textScale: textScale,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: Scaffold(
          body: AppDataTable<String>(
            columns: columns,
            rows: rows,
            rowId: (value) => value,
            loading: loading,
            errorKey: errorKey,
            onRetry: onRetry,
            onRowActivated: onRowActivated,
            onSort: onSort,
            onPageChanged: onPageChanged,
            onPageSizeChanged: onPageSizeChanged,
            totalCount: 75,
            hasMore: hasMore,
            onLoadMore: onLoadMore,
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
    expect(find.byType(AppCard), findsNWidgets(2));

    await pumpTable(tester, size: const Size(900, 900));
    expect(find.byType(Card), findsNothing);
    expect(find.text('Status: Alpha'), findsNothing);

    await pumpTable(tester, size: const Size(1200, 900));
    expect(find.text('Status: Alpha'), findsOneWidget);
  });

  testWidgets('supports breakpoints, both directions, themes and large text', (
    tester,
  ) async {
    const sizes = [
      Size(360, 800),
      Size(600, 900),
      Size(900, 900),
      Size(1200, 900),
    ];
    for (var index = 0; index < sizes.length; index++) {
      await pumpTable(
        tester,
        size: sizes[index],
        dark: index.isOdd,
        direction: index.isOdd ? TextDirection.ltr : TextDirection.rtl,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    }
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

    await tester.enterText(find.byType(TextField).first, '50');
    await tester.pumpAndSettle();
    await tester.tap(find.text('50').last);
    expect(requestedSize, 50);
  });

  testWidgets('mobile sorting is available from a bottom sheet', (tester) async {
    DataTableSort? requestedSort;
    await pumpTable(
      tester,
      size: const Size(360, 800),
      onSort: (value) => requestedSort = value,
    );

    await tester.tap(find.text('Sort by'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.text('Search').last);
    await tester.pumpAndSettle();

    expect(requestedSort?.key, 'name');
    expect(requestedSort?.ascending, isTrue);
  });

  testWidgets('desktop rows support Enter activation and Space selection', (
    tester,
  ) async {
    String? activated;
    Set<Object>? selected;
    await pumpTable(
      tester,
      onRowActivated: (value) => activated = value,
      onSelectionChanged: (value) => selected = value,
    );
    final rowFocus = find.byType(Focus).first;
    Focus.of(tester.element(rowFocus)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(activated, 'Alpha');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(selected, contains('Alpha'));
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

  testWidgets('mobile cards expose a load-more callback', (tester) async {
    var loaded = false;
    await pumpTable(
      tester,
      size: const Size(360, 800),
      hasMore: true,
      onLoadMore: () => loaded = true,
    );
    await tester.tap(find.text('Load more'));
    expect(loaded, isTrue);
  });

  testWidgets('renders error and delegates retry', (tester) async {
    var retries = 0;
    await pumpTable(
      tester,
      errorKey: CatalogUiKeys.retry,
      onRetry: () => retries++,
    );
    await tester.tap(find.text('Retry').last);
    expect(retries, 1);
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
