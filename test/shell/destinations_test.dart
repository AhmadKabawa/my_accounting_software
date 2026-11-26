import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/shell/destinations.dart';

void main() {
  const destinations = [
    AppDestination(
      item: NavBarItem.icons(icon: AppIcons.home, label: NavKeys.home),
      branchIndex: 0,
      permission: Permission('sales.view'),
    ),
    AppDestination(
      item: NavBarItem.icons(icon: AppIcons.home, label: NavKeys.home),
      branchIndex: 1,
      permission: Permission('purchasing.view'),
    ),
    AppDestination(
      item: NavBarItem.icons(icon: AppIcons.home, label: NavKeys.home),
      branchIndex: 2,
      permission: Permission('inventory.view'),
    ),
    AppDestination(
      item: NavBarItem.icons(icon: AppIcons.home, label: NavKeys.home),
      branchIndex: 3,
      permission: Permission('catalog.manage'),
    ),
    AppDestination(
      item: NavBarItem.icons(icon: AppIcons.home, label: NavKeys.home),
      branchIndex: 4,
      permission: Permission('finance.view'),
    ),
    AppDestination(
      item: NavBarItem.icons(icon: AppIcons.home, label: NavKeys.home),
      branchIndex: 5,
      permission: Permission('accounting.view'),
    ),
    AppDestination(
      item: NavBarItem.icons(icon: AppIcons.home, label: NavKeys.home),
      branchIndex: 6,
      permission: Permission('reports.view'),
    ),
    AppDestination(
      item: NavBarItem.icons(icon: AppIcons.home, label: NavKeys.home),
      branchIndex: 7,
      permission: Permission('audit.view'),
    ),
    AppDestination(
      item: NavBarItem.icons(icon: AppIcons.home, label: NavKeys.home),
      branchIndex: 8,
      permission: Permission('users.manage'),
    ),
  ];

  const rolePermissions = <String, Set<Permission>>{
    'SUPER_ADMIN': {
      Permission('sales.view'),
      Permission('purchasing.view'),
      Permission('inventory.view'),
      Permission('catalog.manage'),
      Permission('finance.view'),
      Permission('accounting.view'),
      Permission('reports.view'),
      Permission('audit.view'),
      Permission('users.manage'),
    },
    'MANAGER': {
      Permission('sales.view'),
      Permission('purchasing.view'),
      Permission('inventory.view'),
      Permission('catalog.manage'),
      Permission('finance.view'),
      Permission('accounting.view'),
      Permission('reports.view'),
      Permission('audit.view'),
    },
    'CASHIER': {Permission('sales.view'), Permission('inventory.view')},
    'WAREHOUSE': {
      Permission('purchasing.view'),
      Permission('inventory.view'),
      Permission('catalog.manage'),
    },
    'ACCOUNTANT': {
      Permission('sales.view'),
      Permission('purchasing.view'),
      Permission('inventory.view'),
      Permission('finance.view'),
      Permission('accounting.view'),
      Permission('reports.view'),
      Permission('audit.view'),
    },
    'PURCHASER': {
      Permission('purchasing.view'),
      Permission('inventory.view'),
      Permission('catalog.manage'),
      Permission('reports.view'),
    },
    'AUDITOR': {
      Permission('sales.view'),
      Permission('purchasing.view'),
      Permission('inventory.view'),
      Permission('finance.view'),
      Permission('accounting.view'),
      Permission('reports.view'),
      Permission('audit.view'),
    },
  };

  test('catalog sidebar exposes Units immediately after Brands', () {
    final children = appDestinations[1].item.children;
    final brandIndex = children.indexWhere((item) => item.path == '/catalog/brands');
    final unitsIndex = children.indexWhere((item) => item.path == '/catalog/units');
    expect(unitsIndex, isNonNegative);
    expect(unitsIndex, brandIndex + 1);
  });

  test('filters destinations for each documented system role', () {
    expect(rolePermissions.keys, {
      'SUPER_ADMIN',
      'MANAGER',
      'CASHIER',
      'WAREHOUSE',
      'ACCOUNTANT',
      'PURCHASER',
      'AUDITOR',
    });
    for (final entry in rolePermissions.entries) {
      final visible = filterDestinations(destinations, entry.value.contains);
      expect(
        visible.map((destination) => destination.permission).toSet(),
        entry.value,
        reason: entry.key,
      );
    }
  });
}
