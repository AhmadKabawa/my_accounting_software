import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/localized_app.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_routes.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/routing/units_routes.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/routing/option_sets_routes.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/routing/attributes_routes.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/routing/colors_routes.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/routing/categories_routes.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/routing/genders_routes.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/routing/age_groups_routes.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/routing/sports_routes.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/routing/tags_routes.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/routing/materials_routes.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/routing/fabric_types_routes.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/routing/care_instructions_routes.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/localization/seasons_keys.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/routing/seasons_routes.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/localization/collections_keys.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/routing/collections_routes.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/catalog_hub_keys.dart';
import 'package:accounting_software/app/shell/destinations.dart';

final _items = [
  const NavBarItem.icons(icon: AppIcons.home, label: NavKeys.home),
  const NavBarItem.icons(
    icon: AppIcons.catalog,
    label: NavKeys.catalog,
    children: [
      NavBarChild(
        label: BrandsKeys.title,
        icon: AppIcons.brands,
        path: '/catalog/brands',
      ),
    ],
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  required int activeIndex,
  String? activePath,
  ValueChanged<String>? onChild,
  bool collapsed = false,
  ValueChanged<int>? onIndex,
  List<NavBarItem>? items,
  double height = 900,
}) async {
  tester.view.physicalSize = Size(1400, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    buildTestApp(
      home: Scaffold(
        body: AppSidebar(
          items: items ?? _items,
          activeIndex: activeIndex,
          onIndexChanged: onIndex ?? (_) {},
          activePath: activePath,
          onChildSelected: onChild,
          collapsed: collapsed,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('children show only under the selected item', (tester) async {
    await _pump(tester, activeIndex: 0);
    expect(find.text('Brands'), findsNothing);

    await _pump(tester, activeIndex: 1);
    expect(find.text('Brands'), findsOneWidget);
  });

  testWidgets('catalog sidebar shows all linked catalog features', (
    tester,
  ) async {
    await _pump(
      tester,
      activeIndex: 1,
      items: [for (final destination in appDestinations) destination.item],
      height: 1600,
    );
    await tester.pumpAndSettle();
    expect(find.text(CatalogHubKeys.materialsTitle.en), findsOneWidget);
    expect(find.text(CatalogHubKeys.fabricTypesTitle.en), findsOneWidget);
    expect(find.text(CatalogHubKeys.careInstructionsTitle.en), findsOneWidget);
    expect(find.text(SeasonsKeys.title.en), findsOneWidget);
    expect(find.text(CollectionsKeys.title.en), findsOneWidget);
  });

  testWidgets('a collapsed sidebar hides children', (tester) async {
    await _pump(tester, activeIndex: 1, collapsed: true);
    expect(find.text('Brands'), findsNothing);
  });

  testWidgets('tapping a child reports its path', (tester) async {
    String? opened;
    await _pump(tester, activeIndex: 1, onChild: (p) => opened = p);
    await tester.tap(find.text('Brands'));
    expect(opened, '/catalog/brands');
  });

  testWidgets('one tap opens or closes the list and never navigates', (
    tester,
  ) async {
    final taps = <int>[];
    await _pump(tester, activeIndex: 0, onIndex: taps.add);
    await tester.tap(find.text('Catalog'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(taps, isEmpty);
    expect(find.text('Brands'), findsOneWidget);
    await tester.tap(find.text('Catalog'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(taps, isEmpty);
    expect(find.text('Brands'), findsNothing);
  });

  testWidgets('a double tap on a parent opens its own page', (tester) async {
    final taps = <int>[];
    await _pump(tester, activeIndex: 0, onIndex: taps.add);
    await tester.tap(find.text('Catalog'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Catalog'));
    await tester.pumpAndSettle();
    expect(taps, [1]);
  });

  testWidgets('only one list is open: choosing another page closes it', (
    tester,
  ) async {
    int active = 1;
    late StateSetter update;
    await tester.pumpWidget(
      buildTestApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Scaffold(
              body: AppSidebar(
                items: _items,
                activeIndex: active,
                onIndexChanged: (i) => setState(() => active = i),
                activePath: active == 1 ? '/catalog/brands' : '/',
              ),
            );
          },
        ),
      ),
    );
    expect(find.text('Brands'), findsOneWidget);
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    expect(find.text('Brands'), findsNothing);
    update(() {});
  });

  testWidgets('icon-only mode shows the children as icons under the parent', (
    tester,
  ) async {
    await _pump(tester, activeIndex: 1, collapsed: true);
    expect(
      find.byIcon((AppIcons.brands as MaterialIconData).data),
      findsOneWidget,
    );
    expect(find.text('Brands'), findsNothing);
  });

  test('the catalog destination children point at the real routes', () {
    final catalog = appDestinations[1].item;
    expect(catalog.children.map((child) => child.path), [
      BrandsRoutes.brands.path,
      UnitsRoutes.units.path,
      OptionSetsRoutes.optionSets.path,
      AttributesRoutes.attributes.path,
      ColorsRoutes.colors.path,
      CategoriesRoutes.categories.path,
      GendersRoutes.genders.path,
      AgeGroupsRoutes.ageGroups.path,
      ProductTypesRoutes.productTypes.path,
      TagsRoutes.tags.path,
      CareInstructionsRoutes.careInstructions.path,
      SeasonsRoutes.seasons.path,
      CollectionsRoutes.collections.path,
      MaterialsRoutes.materials.path,
      FabricTypesRoutes.fabricTypes.path,
      SportsRoutes.sports.path,
    ]);
  });
}
