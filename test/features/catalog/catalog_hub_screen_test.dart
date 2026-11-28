import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_routes.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/catalog_hub_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/catalog_hub_screen.dart';
import '../../helpers/localized_app.dart';
import '../../helpers/screen_matrix.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets(
    'hub groups catalog areas and fits a narrow RTL viewport',
    (
    tester,
  ) async {
    await pumpScreenMatrix(
      tester,
      width: 280,
      direction: TextDirection.rtl,
      dark: false,
      textScale: 1.5,
      home: const Scaffold(body: CatalogHubScreen()),
    );

    expect(
      find.text(CatalogHubKeys.groupProductDefinition.en),
      findsOneWidget,
    );
    expect(
      find.text(CatalogHubKeys.groupProperties.en),
      findsOneWidget,
    );
    expect(
      find.text(CatalogHubKeys.groupClassification.en),
      findsOneWidget,
    );
    expect(find.byType(AppCard), findsNWidgets(13));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'catalog hub area opens its configured route',
    (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const CatalogHubScreen(),
        ),
        GoRoute(
          path: BrandsRoutes.brands.path,
          builder: (context, state) => const Scaffold(
            body: Text('brands-destination'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(buildTestApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text(BrandsKeys.title.en).last);
    await tester.pumpAndSettle();

    expect(find.text('brands-destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
