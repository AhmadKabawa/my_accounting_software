import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('debounces search and removes an active filter', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 301));
    expect(query, 'brand');

    expect(find.byType(AppBadge), findsOneWidget);
    expect(find.text('Filters: Active'), findsOneWidget);
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
}
