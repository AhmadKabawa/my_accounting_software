import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_stats_bar.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('statistics cards select their corresponding list filter', (
    tester,
  ) async {
    BrandStatusFilter? selected;
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: BrandStatsBar(
            const BrandStats(total: 12, active: 8, inactive: 4),
            onFilterSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.byType(AppCard), findsNWidgets(3));
    await tester.tap(find.byType(AppCard).at(1));
    expect(selected, BrandStatusFilter.active);

    await tester.tap(find.byType(AppCard).at(2));
    expect(selected, BrandStatusFilter.inactive);

    await tester.tap(find.byType(AppCard).first);
    expect(selected, BrandStatusFilter.all);
  });
}
