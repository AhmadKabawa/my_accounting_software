import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/sort_criterion_row.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/sort_field_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/sort_panel.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('search is delegated immediately and removes an active filter', (
    tester,
  ) async {
    var query = '';
    var removed = 0;
    var cleared = 0;
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FilterBar(
            onSearchChanged: (value) => query = value,
            activeFilters: [
              FilterBarFilter(
                id: 'status',
                label: CatalogUiKeys.filters,
                value: 'Active',
                onRemove: () => removed++,
              ),
            ],
            onClearAll: () => cleared++,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'brand');
    await tester.pump();
    expect(query, 'brand');

    expect(find.byType(AppBadge), findsOneWidget);
    final activeBadge = tester.widget<AppBadge>(find.byType(AppBadge));
    expect(activeBadge.label, CatalogUiKeys.activeFilterLabel);
    expect(activeBadge.labelArgs, {
      'label': CatalogUiKeys.filters.en,
      'value': 'Active',
    });
    expect(removed, 0);
    await tester.tap(
      find.descendant(
        of: find.byType(AppBadge).first,
        matching: find.byType(InkWell),
      ),
    );
    expect(removed, 1);

    await tester.tap(find.text('Clear all'));
    expect(cleared, 1);
  });

  testWidgets('supports breakpoints, directions, themes and large text', (
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
          home: Scaffold(
            body: FilterBar(
              onSearchChanged: (_) {},
              activeFilters: [
                FilterBarFilter(
                  id: 'long',
                  label: CatalogUiKeys.filters,
                  value: 'A very long filter value that must wrap safely',
                  onRemove: () {},
                ),
              ],
              onClearAll: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.reset);
  });

  testWidgets(
    'search fits the available content width from 280 to 1400 with a large screen',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final width in [280.0, 360.0, 480.0, 700.0, 1000.0, 1400.0]) {
        var searched = '';
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: FilterBar(
                    key: ValueKey(width),
                    onSearchChanged: (value) => searched = value,
                    activeFilters: const [],
                    onClearAll: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget, reason: 'width=$width');
        await tester.enterText(find.byType(TextField), 'brand');
        await tester.pump();
        expect(searched, 'brand', reason: 'width=$width');
        expect(tester.takeException(), isNull, reason: 'width=$width');
      }
    },
  );

  testWidgets(
    'search fits with both leading and suffix at narrow and wide content widths',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final width in [280.0, 360.0, 480.0, 700.0, 1000.0, 1400.0]) {
        var searched = '';
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: FilterBar(
                    key: ValueKey(width),
                    onSearchChanged: (value) => searched = value,
                    activeFilters: const [],
                    onClearAll: () {},
                    leading: const SizedBox(width: 40, height: 40),
                    searchSuffix: const SizedBox(width: 40, height: 40),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget, reason: 'width=$width');
        await tester.enterText(find.byType(TextField), 'color');
        await tester.pump();
        expect(searched, 'color', reason: 'width=$width');
        expect(tester.takeException(), isNull, reason: 'width=$width');
      }
    },
  );

  testWidgets('wide layout reveals the caller filter editor inline', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FilterBar(
            onSearchChanged: (_) {},
            activeFilters: const [],
            onClearAll: () {},
            filterPanelBuilder: (_, apply) => TextButton(
              onPressed: apply,
              child: const Text('Custom filters'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Custom filters'), findsOneWidget);
    await tester.tap(find.text('Custom filters'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('mobile sheet can host filter controls without a builder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FilterBar(
            onSearchChanged: (_) {},
            activeFilters: const [],
            onClearAll: () {},
            filterControls: [
              TextButton(onPressed: () {}, child: const Text('Status control')),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Status control'), findsOneWidget);
  });

  testWidgets('mobile opens filter editor in a bottom sheet', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FilterBar(
            onSearchChanged: (_) {},
            activeFilters: const [],
            onClearAll: () {},
            filterPanelBuilder: (_, apply) => TextButton(
              onPressed: apply,
              child: const Text('Apply selection'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.text('Apply selection'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('the x button empties the search and searches at once', (
    tester,
  ) async {
    var query = 'unset';
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FilterBar(
            onSearchChanged: (value) => query = value,
            activeFilters: const [],
            onClearAll: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.close), findsNothing);
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(query, '');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('removing the search chip or clearing all empties the field', (
    tester,
  ) async {
    var removed = 0;
    var cleared = 0;
    Future<void> pumpBar() => tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FilterBar(
            onSearchChanged: (_) {},
            activeFilters: [
              FilterBarFilter(
                id: FilterBar.searchFilterId,
                label: CatalogUiKeys.search,
                value: 'abc',
                onRemove: () => removed++,
              ),
            ],
            onClearAll: () => cleared++,
          ),
        ),
      ),
    );

    String fieldText() =>
        tester.widget<TextField>(find.byType(TextField)).controller!.text;

    await pumpBar();
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(AppBadge).first,
        matching: find.byType(InkWell),
      ),
    );
    await tester.pump();
    expect(removed, 1);
    expect(fieldText(), '');

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump();
    await tester.tap(find.text('Clear all'));
    await tester.pump();
    expect(cleared, 1);
    expect(fieldText(), '');
  });

  testWidgets('the active filter chip shows real values, not placeholders', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FilterBar(
            onSearchChanged: (_) {},
            activeFilters: [
              FilterBarFilter(
                id: 'status',
                label: CatalogUiKeys.filters,
                value: 'Active',
                onRemove: () {},
              ),
            ],
            onClearAll: () {},
          ),
        ),
      ),
    );

    expect(find.text('Filters: Active'), findsOneWidget);
    expect(find.textContaining('{'), findsNothing);
  });

  group('toolbar slots, sort and a single apply button', () {
    Future<void> pumpBar(
      WidgetTester tester, {
      Size size = const Size(1200, 900),
      Widget? leading,
      Widget? trailing,
      List<FilterBarSortOption> sortOptions = const [],
      void Function(String, bool)? onSort,
      int? resultCount,
      List<Widget> filterControls = const [],
      VoidCallback? onApply,
      TextDirection direction = TextDirection.ltr,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTestApp(
          direction: direction,
          home: Scaffold(
            body: FilterBar(
              onSearchChanged: (_) {},
              activeFilters: const [],
              onClearAll: () {},
              leading: leading,
              trailing: trailing,
              sortOptions: sortOptions,
              sortKey: 'name',
              onSort: onSort,
              resultCount: resultCount,
              filterControls: filterControls,
              onApply: onApply,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    const options = [
      FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
      FilterBarSortOption(key: 'is_active', label: CatalogUiKeys.filters),
    ];

    testWidgets('wide order: leading, search, then trailing at the end', (
      tester,
    ) async {
      await pumpBar(
        tester,
        leading: const Text('LEAD'),
        trailing: const Text('TRAIL'),
        direction: TextDirection.ltr,
      );
      final lead = tester.getTopLeft(find.text('LEAD')).dx;
      final search = tester.getTopLeft(find.byType(TextField)).dx;
      final trail = tester.getTopLeft(find.text('TRAIL')).dx;
      expect(lead, lessThan(search));
      expect(search, lessThan(trail));
    });

    testWidgets('no sort button without options or callback', (tester) async {
      await pumpBar(tester);
      expect(find.text('Sort by'), findsNothing);
    });

    testWidgets('the sort button reports key and direction', (tester) async {
      String? key;
      bool? ascending;
      await pumpBar(
        tester,
        size: const Size(360, 800),
        sortOptions: options,
        onSort: (k, a) {
          key = k;
          ascending = a;
        },
      );
      await tester.tap(find.text('Sort by'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      await tester.tap(find.text('Descending'));
      await tester.pump();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(key, 'name');
      expect(ascending, isFalse);
    });

    testWidgets('wide: sort is a menu; the active field flips its direction', (
      tester,
    ) async {
      String? key;
      bool? ascending;
      await pumpBar(
        tester,
        sortOptions: options,
        onSort: (k, a) {
          key = k;
          ascending = a;
        },
      );
      await tester.tap(find.text('Sort by'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      // The active field carries the direction arrow.
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      // 'name' is the active field (ascending): choosing it flips to descending.
      await tester.tap(find.text('Search').last);
      await tester.pumpAndSettle();
      expect(key, 'name');
      expect(ascending, isFalse);
    });

    testWidgets(
    'wide multi-sort separates direction and field targets and closes only the nested menu',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var current = const [FilterBarSort('name', true)];
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: FilterBar(
              onSearchChanged: (_) {},
              activeFilters: const [],
              onClearAll: () {},
              sortOptions: const [
                FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                FilterBarSortOption(
                  key: 'status',
                  label: CatalogUiKeys.filters,
                ),
              ],
              sorts: current,
              onSortsChanged: (next) => current = next,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sort by'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Then by'), findsOneWidget);

      // The direction target changes the value without opening the field menu.
      await tester.tap(find.byTooltip('Ascending'));
      await tester.pumpAndSettle();
      expect(current, [const FilterBarSort('name', false)]);
      expect(find.byTooltip('Then by'), findsOneWidget);
      expect(find.byType(MenuItemButton).hitTestable(), findsNothing);

      // The field target opens the nested menu; selecting a field closes only it.
      await tester.tap(find.text('Search').last);
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton).hitTestable(), findsNWidgets(2));
      await tester.tap(find.text('Filters').last);
      await tester.pumpAndSettle();

      expect(current, [const FilterBarSort('status', false)]);
      expect(find.byTooltip('Then by'), findsOneWidget);
      expect(find.byType(MenuItemButton).hitTestable(), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('result count is optional text', (tester) async {
      await pumpBar(tester);
      expect(find.textContaining('results'), findsNothing);
      await pumpBar(tester, resultCount: 12);
      expect(find.text('12 results'), findsOneWidget);
    });

    testWidgets('wide filter controls open under the bar with no apply', (
      tester,
    ) async {
      await pumpBar(tester, filterControls: [const Text('Status control')]);
      expect(find.text('Status control'), findsNothing);
      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Status control'), findsOneWidget);
      expect(find.text('Apply'), findsNothing);
    });

    testWidgets('phone sheet has exactly one apply button', (tester) async {
      var applied = 0;
      await pumpBar(
        tester,
        size: const Size(390, 844),
        filterControls: [const Text('Status control')],
        onApply: () => applied++,
      );
      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Apply'), findsOneWidget);
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(applied, 1);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('phone: search comes first, then sort and filters', (
      tester,
    ) async {
      await pumpBar(
        tester,
        size: const Size(390, 844),
        sortOptions: options,
        onSort: (_, _) {},
        filterControls: [const Text('x')],
      );
      final search = tester.getTopLeft(find.byType(TextField)).dy;
      final sort = tester.getTopLeft(find.text('Sort by')).dy;
      expect(search, lessThan(sort));
      expect(tester.takeException(), isNull);
    });
  });
  testWidgets('uses available content width instead of the device width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final width in [280.0, 360.0, 480.0, 700.0, 1000.0, 1400.0]) {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(
                width: width,
                child: FilterBar(
                  key: ValueKey(width),
                  onSearchChanged: (_) {},
                  activeFilters: const [],
                  onClearAll: () {},
                  leading: const SizedBox(width: 44, height: 40),
                  searchSuffix: const SizedBox(width: 44, height: 40),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'content width $width');
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'brand');
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'brand',
      );
    }
  });

  test(
    'toggleSort changes direction, adds a second field and never drops silently',
    () {
      const first = FilterBarSort('name', true);
      const second = FilterBarSort('status', false);
      final reversed = toggleSort([first], 'name', false);
      expect(reversed, [const FilterBarSort('name', false)]);
      final two = toggleSort(reversed, 'status', false);
      expect(two, [const FilterBarSort('name', false), second]);
      expect(toggleSort(two, 'updated', true), [
        ...two,
        const FilterBarSort('updated', true),
      ]);
      expect(toggleSort(two, 'name', true), [
        const FilterBarSort('name', true),
        second,
      ]);
      final overLimit = [...two, const FilterBarSort('third', true)];
      expect(toggleSort(overLimit, 'fourth', true), [
        ...overLimit,
        const FilterBarSort('fourth', true),
      ]);
    },
  );

  testWidgets('multi-sort panel updates each criterion with one callback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var calls = 0;
    List<FilterBarSort> current = const [FilterBarSort('name', true)];
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: FilterBar(
            onSearchChanged: (_) {},
            activeFilters: const [],
            onClearAll: () {},
            sortOptions: const [
              FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
              FilterBarSortOption(key: 'status', label: CatalogUiKeys.filters),
            ],
            sorts: current,
            onSortsChanged: (next) {
              calls++;
              current = next;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Sort by'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.byTooltip('Ascending'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(current.single.ascending, isFalse);
    expect(find.byTooltip('Descending'), findsOneWidget);
    await tester.tap(find.byTooltip('Then by'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filters').last);
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(current.map((sort) => sort.key), ['name', 'status']);
  });

  testWidgets(
    'multi-sort selects the primary field and toggles its direction',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var calls = 0;
      List<FilterBarSort> current = const [];
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: FilterBar(
              onSearchChanged: (_) {},
              activeFilters: const [],
              onClearAll: () {},
              sortOptions: const [
                FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                FilterBarSortOption(
                  key: 'status',
                  label: CatalogUiKeys.filters,
                ),
              ],
              sorts: current,
              onSortsChanged: (next) {
                calls++;
                current = next;
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Sort by'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose an option'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Filters').last);
      await tester.pumpAndSettle();
      expect(current, [const FilterBarSort('status', true)]);
      expect(calls, 1);

      await tester.tap(find.byTooltip('Ascending'));
      await tester.pumpAndSettle();
      expect(current, [const FilterBarSort('status', false)]);
      expect(calls, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('external sort changes rebuild an already-open phone sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var sorts = const [FilterBarSort('name', true)];
    Widget app() => buildTestApp(
      home: Scaffold(
        body: FilterBar(
          onSearchChanged: (_) {},
          activeFilters: const [],
          onClearAll: () {},
          sortOptions: const [
            FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
            FilterBarSortOption(key: 'status', label: CatalogUiKeys.filters),
          ],
          sorts: sorts,
          onSortsChanged: (_) {},
        ),
      ),
    );
    await tester.pumpWidget(app());
    await tester.tap(find.text('Sort by'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);

    sorts = const [FilterBarSort('status', false)];
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsOneWidget);
    expect(find.byTooltip('Descending'), findsOneWidget);
  });

  testWidgets(
    'a field already used by another criterion is disabled and keeps both sorts',
    (tester) async {
      tester.view.physicalSize = const Size(280, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      const initial = [
        FilterBarSort('name', true),
        FilterBarSort('status', false),
      ];
      var changed = initial;
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              child: SortPanel(
                options: const [
                  FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                  FilterBarSortOption(
                    key: 'status',
                    label: CatalogUiKeys.filters,
                  ),
                  FilterBarSortOption(
                    key: 'updated',
                    label: CatalogUiKeys.refresh,
                  ),
                ],
                sorts: initial,
                onChanged: (next) => changed = next,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(
        find.text(CatalogUiKeys.sortFieldAlreadySelected.en),
        findsNothing,
      );
      final menuItems = tester.widgetList<MenuItemButton>(
        find.byType(MenuItemButton),
      );
      expect(menuItems, hasLength(3));
      expect(menuItems.elementAt(1).onPressed, isNull);
      expect(changed, initial);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('changing a field preserves that criterion direction', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var changed = const [FilterBarSort('name', false)];
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: SortPanel(
              options: const [
                FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                FilterBarSortOption(
                  key: 'status',
                  label: CatalogUiKeys.filters,
                ),
              ],
              sorts: changed,
              onChanged: (next) => changed = next,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filters').last);
    await tester.pumpAndSettle();
    expect(changed, [const FilterBarSort('status', false)]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('can add every available sort field in priority order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(280, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    var changed = const [FilterBarSort('name', true)];
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: SortPanel(
              options: const [
                FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                FilterBarSortOption(
                  key: 'status',
                  label: CatalogUiKeys.filters,
                ),
                FilterBarSortOption(
                  key: 'updated',
                  label: CatalogUiKeys.refresh,
                ),
                FilterBarSortOption(key: 'created', label: CatalogUiKeys.retry),
              ],
              sorts: changed,
              onChanged: (next) => changed = next,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['Filters', 'Refresh data', 'Retry']) {
      await tester.tap(find.byTooltip('Then by'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              child: SortPanel(
                options: const [
                  FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                  FilterBarSortOption(
                    key: 'status',
                    label: CatalogUiKeys.filters,
                  ),
                  FilterBarSortOption(
                    key: 'updated',
                    label: CatalogUiKeys.refresh,
                  ),
                  FilterBarSortOption(
                    key: 'created',
                    label: CatalogUiKeys.retry,
                  ),
                ],
                sorts: changed,
                onChanged: (next) => changed = next,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    expect(changed.map((sort) => sort.key), [
      'name',
      'status',
      'updated',
      'created',
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'move up is in the field menu and keeps the desktop sort panel open',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const initial = [
        FilterBarSort('name', true),
        FilterBarSort('status', false),
        FilterBarSort('updated', true),
      ];
      var changed = initial;
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: FilterBar(
              onSearchChanged: (_) {},
              activeFilters: const [],
              onClearAll: () {},
              sortOptions: const [
                FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                FilterBarSortOption(key: 'status', label: CatalogUiKeys.filters),
                FilterBarSortOption(key: 'updated', label: CatalogUiKeys.refresh),
              ],
              sorts: initial,
              onSortsChanged: (next) => changed = next,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Sort by'));
      await tester.pumpAndSettle();
      expect(find.text('Move sort up'), findsNothing);

      await tester.tap(find.text('Filters').last);
      await tester.pumpAndSettle();
      expect(find.text('Move sort up'), findsOneWidget);
      await tester.tap(find.text('Move sort up'));
      await tester.pumpAndSettle();

      expect(changed, [
        const FilterBarSort('status', false),
        const FilterBarSort('name', true),
        const FilterBarSort('updated', true),
      ]);
      expect(find.byTooltip('Then by'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'wide multi-sort menu remains open and lays out without exceptions',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var changed = const [FilterBarSort('name', true)];
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: FilterBar(
              onSearchChanged: (_) {},
              activeFilters: const [],
              onClearAll: () {},
              sortOptions: const [
                FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                FilterBarSortOption(
                  key: 'status',
                  label: CatalogUiKeys.filters,
                ),
                FilterBarSortOption(
                  key: 'updated',
                  label: CatalogUiKeys.refresh,
                ),
              ],
              sorts: changed,
              onSortsChanged: (next) => changed = next,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Sort by'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Ascending'), findsOneWidget);
      expect(find.byTooltip('Then by'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Then by'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Filters').last);
      await tester.pumpAndSettle();
      expect(changed, [
        const FilterBarSort('name', true),
        const FilterBarSort('status', true),
      ]);
      expect(find.byTooltip('Ascending'), findsNWidgets(2));
      expect(find.text('Move sort up'), findsNothing);
      await tester.tap(find.text('Filters').last);
      await tester.pumpAndSettle();
      expect(find.text('Move sort up'), findsOneWidget);
      expect(find.byTooltip('Then by'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  group('multi-sort menu layout', () {
    Future<void> pumpMulti(
      WidgetTester tester, {
      required Size size,
      double textScale = 1,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTestApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
            ),
            child: Scaffold(
              body: FilterBar(
                onSearchChanged: (_) {},
                activeFilters: const [],
                onClearAll: () {},
                sortOptions: const [
                  FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                  FilterBarSortOption(
                    key: 'status',
                    label: CatalogUiKeys.filters,
                  ),
                ],
                sorts: const [
                  FilterBarSort('name', true),
                  FilterBarSort('status', false),
                ],
                onSortsChanged: (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('opens on desktop without a layout exception', (tester) async {
      await pumpMulti(tester, size: const Size(1280, 800));
      await tester.tap(find.text('Sort by'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Ascending'), findsWidgets);
    });

    testWidgets('opens on a 280px phone at 1.5x text without overflow', (
      tester,
    ) async {
      await pumpMulti(tester, size: const Size(280, 700), textScale: 1.5);
      await tester.tap(find.text('Sort by'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  testWidgets(
    'two sort criteria keep the field readable on a 280px RTL phone at 1.5x text',
    (tester) async {
      tester.view.physicalSize = const Size(280, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        buildTestApp(
          direction: TextDirection.rtl,
          home: Scaffold(
            body: SizedBox(
              width: 280,
              child: SortPanel(
                options: const [
                  FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                  FilterBarSortOption(
                    key: 'status',
                    label: CatalogUiKeys.filters,
                  ),
                ],
                sorts: const [
                  FilterBarSort('name', true),
                  FilterBarSort('status', false),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final row = find.byType(SortCriterionRow).first;
      final field = find.byType(SortFieldButton).first;
      final rowWidth = tester.getSize(row).width;
      final fieldWidth = tester.getSize(field).width;

      expect(fieldWidth, greaterThanOrEqualTo(rowWidth * 0.6));
      expect(find.text('Search'), findsOneWidget);
      expect(tester.getSize(find.text('Search')).width, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'three sort criteria fit the desktop panel without exceptions',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: SortPanel(
              options: const [
                FilterBarSortOption(key: 'name', label: CatalogUiKeys.search),
                FilterBarSortOption(key: 'status', label: CatalogUiKeys.filters),
                FilterBarSortOption(key: 'updated', label: CatalogUiKeys.refresh),
              ],
              sorts: const [
                FilterBarSort('name', true),
                FilterBarSort('status', false),
                FilterBarSort('updated', true),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SortCriterionRow), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'sort arrow toggles without opening the field menu and field selection preserves direction',
    (tester) async {
      tester.view.physicalSize = const Size(280, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      var current = const [
        FilterBarSort('name', true),
        FilterBarSort('status', false),
      ];
      await tester.pumpWidget(
        buildTestApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: SizedBox(
                width: 280,
                child: SortPanel(
                  options: const [
                    FilterBarSortOption(
                      key: 'name',
                      label: CatalogUiKeys.search,
                    ),
                    FilterBarSortOption(
                      key: 'status',
                      label: CatalogUiKeys.filters,
                    ),
                    FilterBarSortOption(
                      key: 'updated',
                      label: CatalogUiKeys.refresh,
                    ),
                  ],
                  sorts: current,
                  onChanged: (next) => setState(() => current = next),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Ascending').first);
      await tester.pumpAndSettle();
      expect(current.first.ascending, isFalse);
      expect(find.byType(MenuItemButton), findsNothing);

      await tester.tap(find.text('Search').first);
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsWidgets);
      await tester.tap(find.text('Refresh data').last);
      await tester.pumpAndSettle();
      expect(current.first, const FilterBarSort('updated', false));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'add criterion is icon-only and the first criterion has no move or remove actions',
    (tester) async {
      tester.view.physicalSize = const Size(280, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      var current = const [FilterBarSort('name', true)];
      await tester.pumpWidget(
        buildTestApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: SizedBox(
                width: 280,
                child: SortPanel(
                  options: const [
                    FilterBarSortOption(
                      key: 'name',
                      label: CatalogUiKeys.search,
                    ),
                    FilterBarSortOption(
                      key: 'status',
                      label: CatalogUiKeys.filters,
                    ),
                  ],
                  sorts: current,
                  onChanged: (next) => setState(() => current = next),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byTooltip('Then by'), findsOneWidget);
      expect(find.text('Then by'), findsNothing);
      expect(find.text('Move sort up'), findsNothing);
      expect(find.byTooltip('Move sort down'), findsNothing);
      expect(find.byTooltip('Remove sort criterion'), findsNothing);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Move sort up'), findsNothing);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Then by'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Filters').last);
      await tester.pumpAndSettle();
      expect(current, [
        const FilterBarSort('name', true),
        const FilterBarSort('status', true),
      ]);
      expect(find.byTooltip('Remove sort criterion'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SortCriterionRow).first,
          matching: find.byTooltip('Remove sort criterion'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(SortCriterionRow).at(1),
          matching: find.byTooltip('Remove sort criterion'),
        ),
        findsOneWidget,
      );
      expect(find.text('Move sort up'), findsNothing);
      await tester.tap(find.text('Filters').last);
      await tester.pumpAndSettle();
      expect(find.text('Move sort up'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
