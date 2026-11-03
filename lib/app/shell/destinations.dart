import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';

/// One place the shell can go to: what to show ([item], the model shared by
/// the bottom bar, the rail and the sidebar), which `StatefulShellBranch` it
/// opens ([branchIndex]) and, optionally, the permission needed to see it.
class AppDestination {
  final NavBarItem item;

  /// Index of the branch in `StatefulShellRoute` (`app_go_router.dart`).
  /// Navigation uses this, never the position in the filtered list.
  final int branchIndex;

  /// null = visible to everyone.
  final Permission? permission;

  const AppDestination({
    required this.item,
    required this.branchIndex,
    this.permission,
  });
}

/// The shell's destinations, defined once. Keep it equal to the branches of
/// the shell route (`AppShell` asserts this in debug). A new module is one
/// line here plus its branch in the router.
const appDestinations = [
  AppDestination(
    item: NavBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: AppKeys.home,
    ),
    branchIndex: 0,
  ),
  AppDestination(
    item: NavBarItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: AppKeys.favorite,
    ),
    branchIndex: 1,
  ),
  AppDestination(
    item: NavBarItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: AppKeys.person,
    ),
    branchIndex: 2,
  ),
];
