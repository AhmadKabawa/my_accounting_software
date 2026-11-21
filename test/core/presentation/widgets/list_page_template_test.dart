import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
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
        dataTable: AppDataTable<String>(
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
}
