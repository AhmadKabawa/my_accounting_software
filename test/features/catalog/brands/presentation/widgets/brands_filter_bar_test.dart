import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brands_filter_bar.dart';
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
    var status = BrandStatusFilter.all;

    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: BrandsFilterBar(
            query: const BrandListQuery(),
            onSearchChanged: (value) => search = value,
            onStatusChanged: (value) => status = value,
            onClearAll: () {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'north');
    await tester.pump();
    expect(search, 'north');

    await tester.tap(find.byType(TextField).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inactive').last);
    await tester.pumpAndSettle();
    expect(status, BrandStatusFilter.inactive);
  });

  testWidgets('active search and status are represented as removable chips', (
    tester,
  ) async {
    var searchCleared = false;
    var statusCleared = false;
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: BrandsFilterBar(
            query: const BrandListQuery(
              search: 'north',
              status: BrandStatusFilter.active,
            ),
            onSearchChanged: (value) => searchCleared = value.isEmpty,
            onStatusChanged: (value) =>
                statusCleared = value == BrandStatusFilter.all,
            onClearAll: () {},
          ),
        ),
      ),
    );

    expect(find.text('Search by brand or slug: north'), findsOneWidget);
    expect(find.text('Status: Active'), findsOneWidget);
    expect(find.byType(AppBadge), findsNWidgets(2));
    await tester.tap(find.descendant(of: find.byType(AppBadge).first, matching: find.byType(InkWell)));
    expect(searchCleared, isTrue);
    await tester.tap(find.descendant(of: find.byType(AppBadge).last, matching: find.byType(InkWell)));
    expect(statusCleared, isTrue);
  });
}
