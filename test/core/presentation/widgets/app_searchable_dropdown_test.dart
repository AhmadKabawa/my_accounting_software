import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  Future<void> pumpPicker(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
    List<String> options = const ['Alpha', 'Beta'],
    ValueChanged<String?>? onChanged,
    ValueChanged<String>? onQueryChanged,
    bool loading = false,
    bool enabled = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: size.width,
              child: SearchableDropdown<String>(
                options: options,
                labelKey: CatalogUiKeys.chooseOption,
                optionLabel: (value) => value,
                value: null,
                onChanged: onChanged ?? (_) {},
                onQueryChanged: onQueryChanged,
                loading: loading,
                enabled: enabled,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('desktop search filters options and selects one', (tester) async {
    String? selected;
    await pumpPicker(tester, onChanged: (value) => selected = value);
    await tester.enterText(find.byType(TextField), 'Al');
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsNothing);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(selected, 'Alpha');
  });

  testWidgets('remote search callback is debounced', (tester) async {
    final queries = <String>[];
    await pumpPicker(tester, onQueryChanged: queries.add);
    await tester.enterText(find.byType(TextField), 'vendor');
    await tester.pump(const Duration(milliseconds: 299));
    expect(queries, isEmpty);
    await tester.pump(const Duration(milliseconds: 2));
    expect(queries, ['vendor']);
  });

  testWidgets('mobile opens a bottom sheet and selects an option', (
    tester,
  ) async {
    String? selected;
    await pumpPicker(
      tester,
      size: const Size(390, 844),
      onChanged: (value) => selected = value,
    );
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();
    expect(selected, 'Beta');
  });

  testWidgets('disabled picker does not open the option sheet', (tester) async {
    await pumpPicker(tester, size: const Size(390, 844), enabled: false);
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });
}
