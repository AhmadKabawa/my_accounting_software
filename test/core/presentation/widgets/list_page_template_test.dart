import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
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
          rows: const ['Alpha', 'Beta'],
          rowId: (value) => value,
          errorKey: state == AppPageState.error ? CatalogUiKeys.retry : null,
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
}
