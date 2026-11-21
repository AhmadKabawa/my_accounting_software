import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_key.dart';

// Dedicated keys: columns and errors must not borrow unrelated catalog texts
// (e.g. "Search"), which would make finders match the wrong widget.
const _nameColumn = TestKey('test.table.name');
const _statusColumn = TestKey('test.table.status');
const _loadFailed = TestKey('test.table.loadFailed');

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  final columns = <DataTableColumn<String>>[
    DataTableColumn<String>(
      labelKey: _nameColumn,
      sortKey: 'name',
      priority: DataTableColumnPriority.primary,
      cellBuilder: (_, value) => Text(value),
    ),
    DataTableColumn<String>(
      labelKey: _statusColumn,
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
    bool refreshing = false,
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
            refreshing: refreshing,
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
    // Phone: one AppCard per row; a secondary column is a labelled field on
    // each card, and the primary column has no label row.
    await pumpTable(tester, size: const Size(360, 800));
    expect(find.byType(AppCard), findsNWidgets(2));
    expect(find.text('test.table.status'), findsNWidgets(2));
    expect(find.text('test.table.name'), findsNothing);

    // Tablet: a table without cards that drops secondary columns.
    await pumpTable(tester, size: const Size(900, 900));
    expect(find.byType(AppCard), findsNothing);
    expect(find.text('test.table.name'), findsOneWidget);
    expect(find.text('test.table.status'), findsNothing);
    expect(find.text('Status: Alpha'), findsNothing);

    // Desktop: the full table, including the secondary column header.
    await pumpTable(tester, size: const Size(1200, 900));
    expect(find.byType(AppCard), findsNothing);
    expect(find.text('test.table.status'), findsOneWidget);
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
        rows: const [
          'A very long catalog item description that must wrap without overflow',
          'Beta',
        ],
        dark: index.isOdd,
        direction: index.isOdd ? TextDirection.ltr : TextDirection.rtl,
        textScale: 2,
      );
      // The long row must actually be on screen, not merely overflow-free.
      expect(
        find.text(
          'A very long catalog item description that must wrap without overflow',
        ),
        findsOneWidget,
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

    await tester.tap(find.text('test.table.name').first);
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

  testWidgets('the table sits in a rounded, bordered surface', (tester) async {
    await pumpTable(tester);
    final clip = find.ancestor(
      of: find.byType(ListView).first,
      matching: find.byType(ClipRRect),
    );
    expect(clip, findsWidgets);
  });

  testWidgets('pagination label shows real numbers, not placeholders', (
    tester,
  ) async {
    await pumpTable(tester, onPageChanged: (_) {});
    expect(find.textContaining('@'), findsNothing);
    expect(find.textContaining('{'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            RegExp(r'Page \d+ of \d+').hasMatch(w.text.toPlainText()),
      ),
      findsOneWidget,
    );
  });

  testWidgets('mobile sorting is available from a bottom sheet', (
    tester,
  ) async {
    DataTableSort? requestedSort;
    await pumpTable(
      tester,
      size: const Size(360, 800),
      onSort: (value) => requestedSort = value,
    );

    await tester.tap(find.text('Sort by'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.text('test.table.name').last);
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
    final alphaCell = find.text('Alpha');
    Focus.of(tester.element(alphaCell)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(activated, 'Alpha');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(selected, contains('Alpha'));
  });

  testWidgets('supports selection and loading skeletons', (tester) async {
    Set<Object>? selected;
    await pumpTable(tester, onSelectionChanged: (value) => selected = value);
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

  testWidgets('refresh indicator keeps the existing rows visible', (
    tester,
  ) async {
    await pumpTable(tester, refreshing: true);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders error and delegates retry', (tester) async {
    var retries = 0;
    await pumpTable(tester, errorKey: _loadFailed, onRetry: () => retries++);
    // The error replaces the rows; the banner text and the retry action
    // are two distinct widgets.
    expect(find.text('test.table.loadFailed'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
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
