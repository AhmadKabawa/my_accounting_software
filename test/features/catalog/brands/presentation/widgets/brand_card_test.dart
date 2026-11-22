import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_card.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_status_badge.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('mobile brand card keeps the existing product count badge', (
    tester,
  ) async {
    const brand = Brand(
      id: 12,
      name: 'Northwind',
      slug: 'northwind',
      isActive: true,
      productCount: 2,
    );

    await tester.pumpWidget(
      buildTestApp(home: const Scaffold(body: BrandCard(brand))),
    );

    expect(find.byType(BrandProductsBadge), findsOneWidget);
    expect(find.text('Products: 2'), findsOneWidget);
  });
}
