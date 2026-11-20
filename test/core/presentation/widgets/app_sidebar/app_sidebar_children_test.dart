import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../helpers/localized_app.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/brands_routes.dart';
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
}) async {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    buildTestApp(
      home: Scaffold(
        body: AppSidebar(
          items: _items,
          activeIndex: activeIndex,
          onIndexChanged: (_) {},
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

  test('the catalog destination child points at the real Brands route', () {
    final catalog = appDestinations[1].item;
    expect(catalog.children.single.path, BrandsRoutes.brands.path);
  });
}
