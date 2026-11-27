import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/localization/units_keys.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';

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
    item: NavBarItem.icons(
      icon: AppIcons.home,
      activeIcon: AppIcons.homeActive,
      label: NavKeys.home,
    ),
    branchIndex: 0,
  ),
  AppDestination(
    item: NavBarItem.icons(
      icon: AppIcons.catalog,
      activeIcon: AppIcons.catalog,
      label: NavKeys.catalog,
      // Sidebar-only sub-entries; the hub itself is the parent item.
      children: [
        NavBarChild(
          label: BrandsKeys.title,
          icon: AppIcons.brands,
          path: '/catalog/brands',
        ),
        NavBarChild(
          label: UnitsKeys.title,
          icon: AppIcons.catalog,
          path: '/catalog/units',
        ),
        NavBarChild(
          label: OptionSetsKeys.title,
          icon: AppIcons.catalog,
          path: '/catalog/option-sets',
        ),
        NavBarChild(
          label: AttributesKeys.title,
          icon: AppIcons.catalog,
          path: '/catalog/attributes',
        ),
        NavBarChild(
          label: ColorsKeys.title,
          icon: AppIcons.colors,
          path: '/catalog/colors',
        ),
        NavBarChild(
          label: CategoriesKeys.title,
          icon: AppIcons.catalog,
          path: '/catalog/categories',
        ),
        NavBarChild(
          label: ProductTypesKeys.title,
          icon: AppIcons.catalog,
          path: '/catalog/product-types',
        ),
        NavBarChild(
          label: TagsKeys.title,
          icon: AppIcons.tags,
          path: '/catalog/tags',
        ),
        NavBarChild(
          label: SportsKeys.title,
          icon: AppIcons.sports,
          path: '/catalog/sports',
        ),
      ],
    ),
    branchIndex: 1,
  ),
  AppDestination(
    item: NavBarItem.icons(
      icon: AppIcons.profile,
      activeIcon: AppIcons.profileActive,
      label: NavKeys.person,
    ),
    branchIndex: 2,
  ),
];

/// Filters shell destinations using the server-authoritative permission check.
List<AppDestination> filterDestinations(
  List<AppDestination> destinations,
  bool Function(Permission permission) can,
) => [
  for (final destination in destinations)
    if (destination.permission == null || can(destination.permission!))
      destination,
];
