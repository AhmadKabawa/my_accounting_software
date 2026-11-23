import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_logo_thumb/app_logo_thumb.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_grid_tile.dart';
import '../../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  for (final width in [160.0, 220.0]) {
    testWidgets('brand grid logo stays square at tile width $width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: BrandGridTile(
                  const Brand(
                    id: 1,
                    name: 'Northwind',
                    slug: 'northwind',
                    isActive: true,
                    productCount: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final logo = tester.getSize(
        find.byKey(const ValueKey('app-logo-thumb-square')),
      );
      expect(logo.width, logo.height);
      expect(logo.width, lessThan(width));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('invalid logo URL shows the fallback icon', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          body: AppLogoThumb(
            url: 'file:///tmp/brand.png',
            label: 'Northwind',
            size: AppLogoSize.large,
            fallbackIcon: AppIcons.brands,
          ),
        ),
      ),
    );

    expect(find.byType(AppIcon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('brand grid tolerates text scale 1.5', (tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          body: SizedBox(
            width: 160,
            child: BrandGridTile(
              Brand(
                id: 2,
                name: 'A very long brand name that must remain readable',
                slug: 'very-long-brand-name',
                isActive: true,
                productCount: 123,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
