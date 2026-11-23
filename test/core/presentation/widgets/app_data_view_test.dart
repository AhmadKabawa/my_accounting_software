import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_pagination_bar.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/memory_storage.dart';
import '../../../helpers/test_key.dart';

const _nameColumn = TestKey('test.table.name');
const _statusColumn = TestKey('test.table.status');
const _loadFailed = TestKey('test.table.loadFailed');
const _sidebar = 256.0;

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  final columns = <DataTableColumn<String>>[
    DataTableColumn<String>(
      labelKey: _nameColumn,
      sortKey: 'name',
      priority: DataTableColumnPriority.primary,
      cellBuilder: (_, v) => Text(v),
    ),
    DataTableColumn<String>(
      labelKey: _statusColumn,
      cellBuilder: (_, v) => Text('Status: $v'),
    ),
  ];

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
    bool withSidebar = false,
    List<String> rows = const ['Alpha', 'Beta'],
    AppViewMode? mode,
    bool withGrid = false,
    bool loading = false,
    bool refreshing = false,
    bool dark = false,
    TextDirection direction = TextDirection.ltr,
    AppKey? errorKey,
    VoidCallback? onRetry,
    ValueChanged<DataTableSort>? onSort,
    ValueChanged<int>? onPageChanged,
    ValueChanged<Set<Object>>? onSelectionChanged,
    Set<Object> selectedIds = const {},
    ValueChanged<String>? onRowActivated,
    bool hasMore = false,
    VoidCallback? onLoadMore,
    int totalCount = 75,
  }) async {
    setScreenSize(tester, size);
    await tester.pumpWidget(
      buildTestApp(
        direction: direction,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: Scaffold(
          body: Row(
            children: [
              if (withSidebar) const SizedBox(width: _sidebar),
              Expanded(
                child: SingleChildScrollView(
                  child: AppDataView<String>(
                    columns: columns,
                    rows: rows,
                    rowId: (v) => v,
                    mode: mode,
                    gridItemBuilder: withGrid
                        ? (_, v) => Text('Tile $v')
                        : null,
                    loading: loading,
                    refreshing: refreshing,
                    errorKey: errorKey,
                    onRetry: onRetry,
                    onSort: onSort,
                    sortKey: 'name',
                    onPageChanged: onPageChanged,
                    selectedIds: selectedIds,
                    onSelectionChanged: onSelectionChanged,
                    onRowActivated: onRowActivated,
                    hasMore: hasMore,
                    onLoadMore: onLoadMore,
                    totalCount: totalCount,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (loading || refreshing) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  group('DataTableLayout', () {
    DataTableColumn<String> col(String id, DataTableColumnPriority p) =>
        DataTableColumn<String>(
          labelKey: TestKey(id),
          priority: p,
          cellBuilder: (_, v) => Text(v),
        );
    final primary = col('p', DataTableColumnPriority.primary);
    final s1 = col('s1', DataTableColumnPriority.secondary);
    final s2 = col('s2', DataTableColumnPriority.secondary);
    final h = col('h', DataTableColumnPriority.hiddenOnMobile);

    List<String> ids(List<DataTableColumn<String>> c) =>
        c.map((e) => e.labelKey.key).toList();

    test('keeps every column when they all fit', () {
      final r = DataTableLayout.visibleColumns(
        [primary, s1, s2, h],
        availableWidth: 1000,
        minWidth: 100,
        primaryMinWidth: 200,
      );
      expect(ids(r), ['p', 's1', 's2', 'h']);
    });

    test('drops hiddenOnMobile first, then the last secondary', () {
      final r = DataTableLayout.visibleColumns(
        [primary, s1, s2, h],
        availableWidth: 400,
        minWidth: 100,
        primaryMinWidth: 200,
      );
      expect(ids(r), ['p', 's1', 's2']);
      final r2 = DataTableLayout.visibleColumns(
        [primary, s1, s2, h],
        availableWidth: 300,
        minWidth: 100,
        primaryMinWidth: 200,
      );
      expect(ids(r2), ['p', 's1']);
    });

    test('the primary column never hides', () {
      final r = DataTableLayout.visibleColumns(
        [primary, s1, s2],
        availableWidth: 10,
        minWidth: 100,
        primaryMinWidth: 200,
      );
      expect(ids(r), ['p']);
    });

    test('with no declared primary the first column is primary', () {
      final r = DataTableLayout.visibleColumns(
        [s1, s2],
        availableWidth: 10,
        minWidth: 100,
        primaryMinWidth: 200,
      );
      expect(ids(r), ['s1']);
    });
  });

  group('paginationItems', () {
    test('few pages: all of them', () {
      expect(paginationItems(1, 5), [1, 2, 3, 4, 5]);
    });
    test('many pages: ellipsis at both ends', () {
      expect(paginationItems(10, 20), [1, null, 9, 10, 11, null, 20]);
    });
    test('near the start', () {
      expect(paginationItems(1, 20), [1, 2, null, 20]);
    });
    test('near the end', () {
      expect(paginationItems(20, 20), [1, null, 19, 20]);
    });
  });

  group('responsive matrix (one source of the screen type)', () {
    for (final width in [360.0, 600.0, 900.0, 1200.0, 1366.0]) {
      for (final dark in [false, true]) {
        for (final dir in TextDirection.values) {
          testWidgets('$width dark=$dark $dir', (tester) async {
            // The sidebar takes space on tablet+ exactly as in the shell.
            await pump(
              tester,
              size: Size(width, 900),
              withSidebar: width >= 600,
              dark: dark,
              direction: dir,
            );
            expect(tester.takeException(), isNull);
            final contentWidth = width - (width >= 600 ? _sidebar : 0);
            if (contentWidth < AppDataView.compactContentBreakpoint) {
              // Compact content (including a laptop/tablet with sidebar): cards.
              expect(find.byType(AppCard), findsNWidgets(2));
            } else {
              expect(find.byType(AppCard), findsNothing);
              expect(find.text('Status: Alpha'), findsOneWidget);
              expect(find.text('test.table.status'), findsOneWidget);
            }
          });
        }
      }
    }
  });

  group('view modes', () {
    testWidgets('an explicit mode wins over the device default', (
      tester,
    ) async {
      await pump(tester, mode: AppViewMode.cards);
      expect(find.byType(AppCard), findsNWidgets(2));
      await pump(tester, size: const Size(360, 800), mode: AppViewMode.table);
      expect(find.byType(AppCard), findsNothing);
    });

    testWidgets('grid renders only when a gridItemBuilder is given', (
      tester,
    ) async {
      await pump(tester, mode: AppViewMode.grid, withGrid: true);
      expect(find.text('Tile Alpha'), findsOneWidget);
      // Grid requested but unsupported: falls back to the device default.
      await pump(tester, mode: AppViewMode.grid);
      expect(find.text('Tile Alpha'), findsNothing);
      expect(find.text('Status: Alpha'), findsOneWidget);
    });

    testWidgets('selection and sort survive a mode switch', (tester) async {
      await pump(
        tester,
        mode: AppViewMode.table,
        selectedIds: {'Alpha'},
        onSelectionChanged: (_) {},
      );
      final tableChecked = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .where((c) => c.value == true)
          .length;
      await pump(
        tester,
        mode: AppViewMode.cards,
        selectedIds: {'Alpha'},
        onSelectionChanged: (_) {},
      );
      final cardsChecked = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .where((c) => c.value == true)
          .length;
      expect(cardsChecked, 1);
      expect(tableChecked, 1);
    });

    testWidgets('a single page still shows page 1, selected', (tester) async {
      setScreenSize(tester, const Size(1200, 900));
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: AppPaginationBar(
              page: 1,
              pageSize: 25,
              totalCount: 3,
              shownCount: 3,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ViewModeSwitcher reports the chosen mode', (tester) async {
      AppViewMode? picked;
      setScreenSize(tester, const Size(1200, 900));
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: ViewModeSwitcher(
              modes: AppViewMode.values,
              selected: AppViewMode.table,
              onChanged: (m) => picked = m,
            ),
          ),
        ),
      );
      // The button shows the current mode; the menu lists the other ones.
      await tester.tap(find.byType(ViewModeSwitcher));
      await tester.pumpAndSettle();
      expect(find.text('Table'), findsNothing);
      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();
      expect(picked, AppViewMode.grid);
    });

    test('ViewModeCubit restores and persists per screen', () async {
      final storage = MemoryStorage();
      final settings = AppSettingsManager(storage: storage);
      final cubit = ViewModeCubit(settings: settings, screenId: 'a.b');
      await cubit.restore();
      expect(cubit.state, isNull);
      await cubit.select(AppViewMode.grid);
      final other = ViewModeCubit(settings: settings, screenId: 'a.b');
      await other.restore();
      expect(other.state, AppViewMode.grid);
      final different = ViewModeCubit(settings: settings, screenId: 'x.y');
      await different.restore();
      expect(different.state, isNull);
      await cubit.close();
      await other.close();
      await different.close();
    });
  });

  group('states and callbacks', () {
    testWidgets('sorting and paging are delegated to the data source', (
      tester,
    ) async {
      DataTableSort? sort;
      var page = 0;
      await pump(
        tester,
        onSort: (s) => sort = s,
        onPageChanged: (p) => page = p,
      );
      await tester.tap(find.text('test.table.name').first);
      expect(sort?.key, 'name');
      expect(sort?.ascending, isFalse); // already sorted ascending: flips
      await tester.tap(find.byTooltip('Next'));
      expect(page, 2);
    });

    testWidgets('footer shows "Showing X of Y" and the current page', (
      tester,
    ) async {
      await pump(tester, onPageChanged: (_) {});
      expect(find.text('Showing 2 of 75'), findsOneWidget);
      expect(find.textContaining('{'), findsNothing);
      expect(find.byTooltip('Page 1'), findsOneWidget);
    });

    testWidgets('phone with load-more shows the button', (tester) async {
      var loaded = false;
      await pump(
        tester,
        size: const Size(360, 800),
        hasMore: true,
        onLoadMore: () => loaded = true,
      );
      await tester.tap(find.text('Load more'));
      expect(loaded, isTrue);
    });


    testWidgets(
      'narrow content uses compact pagination on a large screen',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        var loaded = false;
        await tester.pumpWidget(buildTestApp(home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: AppDataView<String>(
                columns: columns,
                rows: const ['Alpha', 'Beta'],
                rowId: (value) => value,
                hasMore: true,
                onLoadMore: () => loaded = true,
              ),
            ),
          ),
        )));
        expect(find.text('Load more'), findsOneWidget);
        await tester.tap(find.text('Load more'));
        expect(loaded, isTrue);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Enter activates and Space selects a table row', (
      tester,
    ) async {
      String? activated;
      Set<Object>? selected;
      await pump(
        tester,
        mode: AppViewMode.table,
        onRowActivated: (v) => activated = v,
        onSelectionChanged: (v) => selected = v,
      );
      Focus.of(tester.element(find.text('Alpha'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(activated, 'Alpha');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(selected, contains('Alpha'));
    });

    testWidgets('loading respects the mode', (tester) async {
      await pump(tester, loading: true, mode: AppViewMode.table);
      expect(find.byType(AppSkeleton), findsWidgets);
      await pump(tester, loading: true, mode: AppViewMode.cards);
      expect(find.byType(AppSkeleton), findsWidgets);
    });

    testWidgets('refreshing keeps rows visible', (tester) async {
      await pump(tester, refreshing: true);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('error replaces rows and retry is delegated', (tester) async {
      var retries = 0;
      await pump(tester, errorKey: _loadFailed, onRetry: () => retries++);
      expect(find.text('test.table.loadFailed'), findsOneWidget);
      expect(find.text('Alpha'), findsNothing);
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    });

    testWidgets('empty state shows the default message', (tester) async {
      await pump(tester, rows: const [], dark: true);
      expect(find.text('No data'), findsOneWidget);
    });
  });
}
