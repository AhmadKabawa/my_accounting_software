import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/colors_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('search and status callbacks stay connected to the query', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var search = '';
    var status = ColorStatusFilter.all;

    await tester.pumpWidget(
      buildTestApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: ColorsFilterBar(
              query: ColorListQuery(search: search, status: status),
              onSearchChanged: (value) => setState(() => search = value),
              onStatusChanged: (value) => setState(() => status = value),
              onClearAll: () {},
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'navy');
    await tester.pump();
    expect(search, 'navy');

    // The labelled filter row opens from the Filters button.
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inactive').last);
    await tester.pumpAndSettle();
    expect(status, ColorStatusFilter.inactive);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      'Inactive',
    );

    // Reopen without clearing the selected label and choose another status.
    await tester.tap(find.byType(TextField).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Active').last);
    await tester.pumpAndSettle();
    expect(status, ColorStatusFilter.active);
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      'Active',
    );

    final dropdown = tester.widget<SearchableDropdown<ColorStatusFilter>>(
      find.byType(SearchableDropdown<ColorStatusFilter>),
    );
    expect(dropdown.mode, SearchableDropdownMode.panel);
    expect(dropdown.allOptionLabel, ColorsKeys.allStatuses);
  });

  testWidgets('active search and status are represented as removable chips', (
    tester,
  ) async {
    var searchCleared = false;
    var statusCleared = false;
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: ColorsFilterBar(
            query: const ColorListQuery(
              search: 'navy',
              status: ColorStatusFilter.active,
            ),
            onSearchChanged: (value) => searchCleared = value.isEmpty,
            onStatusChanged: (value) =>
                statusCleared = value == ColorStatusFilter.all,
            onClearAll: () {},
          ),
        ),
      ),
    );

    expect(
      find.text('Search by color name, abbreviation or HEX: navy'),
      findsOneWidget,
    );
    expect(find.text('Status: Active'), findsOneWidget);
    expect(find.byType(AppBadge), findsNWidgets(2));
    await tester.tap(
      find.descendant(
        of: find.byType(AppBadge).first,
        matching: find.byType(InkWell),
      ),
    );
    expect(searchCleared, isTrue);
    await tester.tap(
      find.descendant(
        of: find.byType(AppBadge).last,
        matching: find.byType(InkWell),
      ),
    );
    expect(statusCleared, isTrue);
  });
}
