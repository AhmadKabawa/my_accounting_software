import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/state_management/list_selection_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/bulk_action_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  testWidgets('shows selected count and clears selection without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var cleared = false;
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: BulkActionBar(
            selectedCount: 12,
            actions: const [],
            onClear: () => cleared = true,
          ),
        ),
      ),
    );
    expect(find.text('12 selected'), findsOneWidget);
    expect(find.byType(AppIconButton), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
    await tester.tap(find.byTooltip(CatalogUiKeys.finishSelection.en));
    expect(cleared, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows page selection controls with zero selected rows', (
    tester,
  ) async {
    var selectedPage = false;
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: BulkActionBar(
            selectedCount: 0,
            actions: const [],
            onClear: () {},
            pageSelectionState: PageSelectionState.none,
            onSelectPage: (value) => selectedPage = value,
          ),
        ),
      ),
    );

    expect(find.text('0 selected'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    expect(selectedPage, isTrue);
  });
}
