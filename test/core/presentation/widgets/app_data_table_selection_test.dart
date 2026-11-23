import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  testWidgets('table header checkbox exposes a mixed tri-state for the page', (
    tester,
  ) async {
    Set<Object> selected = {1};
    await tester.pumpWidget(
      buildTestApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: AppDataTable<int>(
              columns: [
                DataTableColumn<int>(
                  labelKey: CatalogUiKeys.search,
                  priority: DataTableColumnPriority.primary,
                  cellBuilder: (_, row) => Text(row.toString()),
                ),
              ],
              rows: const [1, 2],
              rowId: (row) => row,
              selectedIds: selected,
              onSelectionChanged: (next) => setState(() => selected = next),
            ),
          ),
        ),
      ),
    );
    final header = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(header.tristate, isTrue);
    expect(header.value, isNull);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(selected, {1, 2});
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);
  });
}
