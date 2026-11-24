import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_toolbar_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  Widget buildListPage(AppPageState state, {VoidCallback? onRetry}) {
    return Scaffold(
      body: ListPageTemplate(
        titleKey: CatalogUiKeys.filters,
        count: 2,
        filterBar: FilterBar(
          onSearchChanged: (_) {},
          activeFilters: const [],
          onClearAll: () {},
        ),
        dataTable: AppDataView<String>(
          columns: [
            DataTableColumn<String>(
              labelKey: CatalogUiKeys.search,
              priority: DataTableColumnPriority.primary,
              cellBuilder: (_, value) => Text(value),
            ),
          ],
          rows: const [
            'Alpha',
            'A very long catalog item description that must wrap safely',
          ],
          rowId: (value) => value,
          errorKey: state == AppPageState.error
              ? CatalogUiKeys.emptyDescription
              : null,
          onRetry: onRetry,
        ),
        state: state,
        primaryAction: const Text('Add item'),
      ),
    );
  }

  testWidgets('composes PageHeader, FilterBar and DataTable', (tester) async {
    await tester.pumpWidget(
      buildTestApp(home: buildListPage(AppPageState.content)),
    );
    expect(find.text('Filters'), findsWidgets);
    expect(find.text('Add item'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports responsive widths, RTL/LTR, themes and large text', (
    tester,
  ) async {
    const sizes = [
      Size(360, 800),
      Size(600, 900),
      Size(900, 900),
      Size(1200, 900),
    ];
    for (var index = 0; index < sizes.length; index++) {
      tester.view.physicalSize = sizes[index];
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        buildTestApp(
          direction: index.isOdd ? TextDirection.ltr : TextDirection.rtl,
          theme: index.isOdd ? AppTheme.dark() : AppTheme.light(),
          textScale: 2,
          home: buildListPage(AppPageState.content),
        ),
      );
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.reset);
  });

  testWidgets('uses skeleton, empty and error page states', (tester) async {
    await tester.pumpWidget(
      buildTestApp(home: buildListPage(AppPageState.loading)),
    );
    expect(find.byType(AppSkeleton), findsWidgets);

    await tester.pumpWidget(
      buildTestApp(home: buildListPage(AppPageState.empty)),
    );
    expect(find.text('No data'), findsOneWidget);

    var retries = 0;
    await tester.pumpWidget(
      buildTestApp(
        home: buildListPage(AppPageState.error, onRetry: () => retries++),
      ),
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
    await tester.tap(find.text('Retry').first);
    expect(retries, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('retains search text when actions become visible', (
    tester,
  ) async {
    var showActions = false;
    late StateSetter update;

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return ListPageTemplate(
                titleKey: CatalogUiKeys.filters,
                filterBar: FilterBar(
                  onSearchChanged: (_) {},
                  activeFilters: const [],
                  onClearAll: () {},
                ),
                actions: showActions ? const Text('Actions') : null,
                dataTable: const SizedBox(height: 100),
              );
            },
          ),
        ),
      ),
    );

    final search = find.byType(TextFormField).first;
    await tester.enterText(search, 'search survives');
    await tester.pump();
    update(() => showActions = true);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'search survives',
    );
  });

  group('single surface, optional slots and one error contract', () {
    Widget page({
      AppPageState state = AppPageState.content,
      Widget? filterBar,
      Widget? stats,
      Widget? activeFilters,
      Widget? viewModeSwitcher,
      AppKey? errorKey,
      AppKey? refreshErrorKey,
      VoidCallback? onRetry,
      AppViewMode? loadingViewMode,
    }) => Scaffold(
      body: ListPageTemplate(
        titleKey: CatalogUiKeys.filters,
        filterBar: filterBar,
        stats: stats,
        activeFilters: activeFilters,
        viewModeSwitcher: viewModeSwitcher,
        state: state,
        errorKey: errorKey,
        refreshErrorKey: refreshErrorKey,
        onRetry: onRetry,
        loadingViewMode: loadingViewMode,
        dataTable: const Text('DATA'),
      ),
    );

    testWidgets('filterBar is optional', (tester) async {
      await tester.pumpWidget(buildTestApp(home: page()));
      expect(find.text('DATA'), findsOneWidget);
      expect(find.byType(FilterBar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('toolbar, filters and data share one AppCard', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: page(
            filterBar: FilterBar(
              onSearchChanged: (_) {},
              activeFilters: const [],
              onClearAll: () {},
            ),
            stats: const Text('STATS'),
          ),
        ),
      );
      expect(find.byType(AppCard), findsOneWidget);
      final card = find.byType(AppCard);
      expect(
        find.descendant(of: card, matching: find.byType(FilterBar)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('DATA')),
        findsOneWidget,
      );
      // Stats sit outside the card, on the canvas.
      expect(
        find.descendant(of: card, matching: find.text('STATS')),
        findsNothing,
      );
      expect(find.text('STATS'), findsOneWidget);
    });

    testWidgets('errorKey: banner and retry replace the data', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        buildTestApp(
          home: page(
            state: AppPageState.error,
            errorKey: CatalogUiKeys.emptyDescription,
            onRetry: () => retries++,
          ),
        ),
      );
      expect(find.text('DATA'), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    });

    testWidgets('refreshErrorKey keeps the data and shows the banner', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          home: page(
            refreshErrorKey: CatalogUiKeys.emptyDescription,
            onRetry: () {},
          ),
        ),
      );
      expect(find.text('DATA'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('loading placeholders follow the view mode', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTestApp(home: page(state: AppPageState.loading)),
      );
      final rows = tester
          .widgetList<AppSkeleton>(find.byType(AppSkeleton))
          .where((s) => s.variant == AppSkeletonVariant.tableRow)
          .length;
      expect(rows, greaterThan(0));
      await tester.pumpWidget(
        buildTestApp(
          home: page(
            state: AppPageState.loading,
            loadingViewMode: AppViewMode.cards,
          ),
        ),
      );
      final cards = tester
          .widgetList<AppSkeleton>(find.byType(AppSkeleton))
          .where((s) => s.variant == AppSkeletonVariant.card)
          .length;
      expect(cards, greaterThan(0));
    });

    testWidgets('unspecified loading mode follows narrow content width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(
                width: 360,
                child: ListPageTemplate(
                  titleKey: CatalogUiKeys.filters,
                  state: AppPageState.loading,
                  dataTable: const Text('DATA'),
                ),
              ),
            ),
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppSkeleton &&
              widget.variant == AppSkeletonVariant.card,
        ),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppSkeleton &&
              widget.variant == AppSkeletonVariant.tableRow,
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('search text survives slots appearing', (tester) async {
      var showStats = false;
      late StateSetter update;
      await tester.pumpWidget(
        buildTestApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return page(
                stats: showStats ? const Text('STATS') : null,
                filterBar: FilterBar(
                  onSearchChanged: (_) {},
                  activeFilters: const [],
                  onClearAll: () {},
                ),
              );
            },
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'kept');
      update(() => showStats = true);
      await tester.pumpAndSettle();
      expect(find.text('kept'), findsOneWidget);
    });
  });

  group('the template builds the toolbar from a config', () {
    Future<void> pump(
      WidgetTester tester,
      ListToolbarConfig config, {
      Size size = const Size(1200, 900),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: ListPageTemplate(
              titleKey: CatalogUiKeys.filters,
              toolbar: config,
              primaryAction: const Text('ADD'),
              dataTable: const Text('DATA'),
            ),
          ),
        ),
      );
    }

    testWidgets('refresh and view menu come from the config', (tester) async {
      var refreshed = 0;
      AppViewMode? picked;
      await pump(
        tester,
        ListToolbarConfig(
          onSearchChanged: (_) {},
          onClearAll: () {},
          onRefresh: () => refreshed++,
          viewModes: AppViewMode.values,
          onViewModeChanged: (m) => picked = m,
        ),
      );
      expect(find.byType(ViewModeSwitcher), findsOneWidget);
      await tester.tap(find.byTooltip('Refresh data'));
      expect(refreshed, 1);
      await tester.tap(find.byType(ViewModeSwitcher));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();
      expect(picked, AppViewMode.cards);
      // The primary action sits in the page header, not in the toolbar.
      expect(find.text('ADD'), findsOneWidget);
    });

    testWidgets('default extra actions do not add a search suffix', (
      tester,
    ) async {
      final config = ListToolbarConfig(
        onSearchChanged: (_) {},
        onClearAll: () {},
      );
      expect(config.extraActions, isEmpty);

      await pump(tester, config);

      expect(
        tester.widget<FilterBar>(find.byType(FilterBar)).searchSuffix,
        isNull,
      );
      expect(find.byTooltip('Refresh data'), findsNothing);
      expect(find.byType(ViewModeSwitcher), findsNothing);
    });

    testWidgets('extra toolbar actions follow the selection control', (
      tester,
    ) async {
      await pump(
        tester,
        ListToolbarConfig(
          onSearchChanged: (_) {},
          onClearAll: () {},
          selectionModeActive: true,
          onSelectionModeToggle: () {},
          extraActions: [
            TextButton(
              onPressed: () {},
              child: const Text('EXTRA TOOLBAR ACTION'),
            ),
          ],
        ),
      );

      expect(find.text('EXTRA TOOLBAR ACTION'), findsOneWidget);
      final suffix = tester
          .widget<FilterBar>(find.byType(FilterBar))
          .searchSuffix;
      expect(suffix, isA<Row>());
      final children = (suffix! as Row).children;
      expect(children, hasLength(2));
      expect(children.first, isA<Semantics>());
      expect(children.last, isA<TextButton>());
      expect(tester.takeException(), isNull);
    });
  });
}
