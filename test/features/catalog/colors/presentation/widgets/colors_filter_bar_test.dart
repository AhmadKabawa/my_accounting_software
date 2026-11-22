import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/colors_filter_bar.dart';
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
        home: Scaffold(
          body: ColorsFilterBar(
            query: const ColorListQuery(),
            onSearchChanged: (value) => search = value,
            onStatusChanged: (value) => status = value,
            onClearAll: () {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'navy');
    await tester.pump();
    expect(search, 'navy');

    await tester.tap(find.byType(TextField).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inactive').last);
    await tester.pumpAndSettle();
    expect(status, ColorStatusFilter.inactive);
  });

  testWidgets('active search and status are represented as removable chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: ColorsFilterBar(
            query: const ColorListQuery(
              search: 'navy',
              status: ColorStatusFilter.active,
            ),
            onSearchChanged: (_) {},
            onStatusChanged: (_) {},
            onClearAll: () {},
          ),
        ),
      ),
    );

    expect(find.text('Search by color name or code: navy'), findsOneWidget);
    expect(find.text('Status: Active'), findsOneWidget);
    expect(find.byTooltip('Remove filter'), findsNWidgets(2));
  });
}
