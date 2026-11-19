import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
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
    AppKey? errorKey,
    bool enabled = true,
    bool dark = false,
    double textScale = 1,
    TextDirection direction = TextDirection.rtl,
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
                errorKey: errorKey,
                enabled: enabled,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('supports picker breakpoints, directions, themes and large text', (
    tester,
  ) async {
    const sizes = [
      Size(360, 800),
      Size(600, 900),
      Size(900, 900),
      Size(1200, 900),
    ];
    for (var index = 0; index < sizes.length; index++) {
      await pumpPicker(
        tester,
        size: sizes[index],
        dark: index.isOdd,
        direction: index.isOdd ? TextDirection.ltr : TextDirection.rtl,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    }
  });

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

  testWidgets('same-content options refresh without losing query or focus', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var options = <String>['Alpha', 'Beta'];
    await tester.pumpWidget(
      buildTestApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SearchableDropdown<String>(
              options: options,
              labelKey: CatalogUiKeys.chooseOption,
              optionLabel: (value) => value,
              value: null,
              filterLocally: false,
              onChanged: (_) {},
              onQueryChanged: (_) => setState(() {
                options = List<String>.of(options);
              }),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Al');
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.controller?.text, 'Al');
    expect(field.focusNode?.hasFocus, isTrue);
    expect(find.text('Alpha'), findsOneWidget);
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

  testWidgets('desktop picker refreshes remote results without losing query', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var options = <String>['Initial'];
    String? selected;
    await tester.pumpWidget(
      buildTestApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SizedBox(
              width: 900,
              child: SearchableDropdown<String>(
                options: options,
                labelKey: CatalogUiKeys.chooseOption,
                optionLabel: (value) => value,
                value: null,
                filterLocally: false,
                onChanged: (value) => selected = value,
                onQueryChanged: (_) => setState(() {
                  options = ['Remote result'];
                }),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'remote');
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
    expect(find.text('Remote result'), findsOneWidget);
    await tester.tap(find.text('Remote result'));
    await tester.pumpAndSettle();
    expect(selected, 'Remote result');
  });

  testWidgets('mobile picker receives updated remote results while open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var options = <String>['Initial'];
    String? selected;
    await tester.pumpWidget(
      buildTestApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SearchableDropdown<String>(
              options: options,
              labelKey: CatalogUiKeys.chooseOption,
              optionLabel: (value) => value,
              value: null,
              onChanged: (value) => selected = value,
              filterLocally: false,
              onQueryChanged: (_) => setState(() {
                options = ['Remote result'];
              }),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'remote');
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
    expect(find.text('Remote result'), findsOneWidget);
    await tester.tap(find.text('Remote result'));
    await tester.pumpAndSettle();
    expect(selected, 'Remote result');
  });

  testWidgets('shows the supplied error state', (tester) async {
    await pumpPicker(tester, errorKey: CatalogUiKeys.retry);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('disabled picker does not open the option sheet', (tester) async {
    await pumpPicker(tester, size: const Size(390, 844), enabled: false);
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });
}
