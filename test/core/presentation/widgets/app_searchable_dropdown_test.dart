import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_key.dart';

const _loadFailed = TestKey('test.dropdown.loadFailed');
const _allOptions = TestKey('All options');

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  Future<void> pumpPicker(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
    List<String> options = const ['Alpha', 'Beta'],
    String? value,
    ValueChanged<String?>? onChanged,
    ValueChanged<String>? onQueryChanged,
    bool loading = false,
    AppKey? errorKey,
    bool enabled = true,
    bool readOnly = false,
    bool clearable = true,
    WidgetBuilder? onAddNew,
    AppKey? allOptionLabel,
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
                optionLabel: (option) => option,
                value: value,
                onChanged: onChanged ?? (_) {},
                onQueryChanged: onQueryChanged,
                loading: loading,
                errorKey: errorKey,
                enabled: enabled,
                readOnly: readOnly,
                clearable: clearable,
                onAddNew: onAddNew,
                allOptionLabel: allOptionLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'supports picker breakpoints, directions, themes and large text',
    (tester) async {
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
          options: const [
            'A very long option label that should wrap safely in the picker',
            'Beta',
          ],
          dark: index.isOdd,
          direction: index.isOdd ? TextDirection.ltr : TextDirection.rtl,
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

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

  testWidgets('nullable all option emits null and exposes selected semantics', (
    tester,
  ) async {
    final changes = <String?>[];
    await pumpPicker(
      tester,
      value: 'Alpha',
      allOptionLabel: _allOptions,
      onChanged: changes.add,
    );
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    final allOption = find.text('All options');
    expect(allOption, findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(allOption);
    await tester.pumpAndSettle();
    expect(changes, [null]);
  });

  testWidgets('keyboard arrows and enter select an autocomplete option', (
    tester,
  ) async {
    String? selected;
    await pumpPicker(tester, onChanged: (value) => selected = value);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, 'Alpha');
  });

  testWidgets('shows the no-results message once', (tester) async {
    await pumpPicker(tester);
    await tester.enterText(find.byType(TextField), 'no-match');
    await tester.pumpAndSettle();

    expect(find.text('No matching options'), findsOneWidget);
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
    await pumpPicker(tester, errorKey: _loadFailed);
    expect(find.text('test.dropdown.loadFailed'), findsOneWidget);
    // No options are offered while the error is shown.
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('disabled picker does not open the option sheet', (tester) async {
    await pumpPicker(tester, size: const Size(390, 844), enabled: false);
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  group('text and selected value stay in sync (desktop)', () {
    testWidgets('typed text that is not chosen reverts on focus loss', (
      tester,
    ) async {
      final queries = <String>[];
      await pumpPicker(tester, value: 'Alpha', onQueryChanged: queries.add);
      TextEditingController? controller() =>
          tester.widget<TextField>(find.byType(TextField)).controller;

      expect(controller()?.text, 'Alpha');
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump(const Duration(milliseconds: 301));
      expect(controller()?.text, 'zzz');
      expect(queries, ['zzz']);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(controller()?.text, 'Alpha');
      // The remote query is released too, so results are not left filtered
      // by text the user can no longer see.
      expect(queries, ['zzz', '']);
    });

    testWidgets('clear button empties the field and reports null', (
      tester,
    ) async {
      final changes = <String?>[];
      await pumpPicker(tester, value: 'Alpha', onChanged: changes.add);

      await tester.tap(find.byTooltip('Clear selection'));
      await tester.pumpAndSettle();

      expect(changes, [null]);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '',
      );
    });

    testWidgets('clear button is absent with nothing to clear', (tester) async {
      await pumpPicker(tester);
      expect(find.byTooltip('Clear selection'), findsNothing);
    });

    testWidgets('clear button is absent when clearable is false', (
      tester,
    ) async {
      await pumpPicker(tester, value: 'Alpha', clearable: false);
      expect(find.byTooltip('Clear selection'), findsNothing);
    });
  });

  testWidgets('"add new" stays reachable when nothing matches', (tester) async {
    await pumpPicker(tester, onAddNew: (_) => const Text('Add new'));
    expect(find.text('Add new'), findsNothing);

    await tester.enterText(find.byType(TextField), 'no-match');
    await tester.pumpAndSettle();

    expect(find.text('No matching options'), findsOneWidget);
    expect(find.text('Add new'), findsOneWidget);
  });

  group('read-only and disabled look different', () {
    testWidgets('read-only stays enabled but not editable', (tester) async {
      await pumpPicker(tester, value: 'Alpha', readOnly: true);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isTrue);
      expect(field.readOnly, isTrue);
      expect(field.controller?.text, 'Alpha');
    });

    testWidgets('disabled is rendered as disabled', (tester) async {
      await pumpPicker(tester, value: 'Alpha', enabled: false);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });

    testWidgets('read-only does not open the sheet on mobile', (tester) async {
      await pumpPicker(
        tester,
        size: const Size(390, 844),
        value: 'Alpha',
        readOnly: true,
      );
      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    });
  });

  group('mobile trigger', () {
    testWidgets('looks enabled and is announced once as a button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpPicker(tester, size: const Size(390, 844), value: 'Alpha');

      // Enabled look: the trigger is not rendered with enabled: false.
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);

      // One node carries the label, the current value and the tap action;
      // the inner text field adds no second announcement.
      final labelled = find.bySemanticsLabel('Choose an option');
      expect(labelled, findsOneWidget);
      final node = tester.getSemantics(labelled);
      expect(node.value, 'Alpha');
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('closing the sheet releases the remote query', (tester) async {
      final queries = <String>[];
      await pumpPicker(
        tester,
        size: const Size(390, 844),
        onQueryChanged: queries.add,
      );
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'be');
      await tester.pump(const Duration(milliseconds: 301));
      await tester.pumpAndSettle();
      expect(queries, ['be']);

      await tester.tap(find.text('Beta').last);
      await tester.pumpAndSettle();

      expect(queries, ['be', '']);
    });
  });

  group('re-opening after a choice (desktop)', () {
    testWidgets('lists every option, not only the chosen one', (tester) async {
      await pumpPicker(tester, value: 'Alpha');

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // 'Beta' is not the field text, so it can only come from the panel.
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('selects another value after reopening without clearing', (
      tester,
    ) async {
      String? selected;
      await pumpPicker(tester, onChanged: (v) => selected = v);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(selected, 'Alpha');

      await pumpPicker(tester, value: 'Alpha', onChanged: (v) => selected = v);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('Beta'), findsOneWidget);
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(selected, 'Beta');
    });

    testWidgets('a non-clearable field still has an x for typed text', (
      tester,
    ) async {
      await pumpPicker(tester, value: 'Alpha', clearable: false);
      TextEditingController? controller() =>
          tester.widget<TextField>(find.byType(TextField)).controller;

      await tester.enterText(find.byType(TextField), 'zz');
      await tester.pump();
      expect(find.byTooltip('Clear selection'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear selection'));
      await tester.pumpAndSettle();

      expect(controller()?.text, 'Alpha');
    });
  });
}
