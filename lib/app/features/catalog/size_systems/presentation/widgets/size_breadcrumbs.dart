import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';

/// Catalog > Size systems.
Widget systemsBreadcrumb(BuildContext context) => AppBreadcrumb(
  items: [
    AppBreadcrumbItem(
      label: NavKeys.catalog,
      onTap: () => context.go(CatalogRoutes.hub.path),
    ),
    const AppBreadcrumbItem(label: SizeSystemsKeys.systemsTitle),
  ],
);

/// Catalog > Size systems > Groups.
Widget groupsBreadcrumb(BuildContext context) => AppBreadcrumb(
  items: [
    AppBreadcrumbItem(
      label: NavKeys.catalog,
      onTap: () => context.go(CatalogRoutes.hub.path),
    ),
    AppBreadcrumbItem(
      label: SizeSystemsKeys.systemsTitle,
      onTap: () => context.go(SizeSystemsRoutes.sizeSystems.path),
    ),
    const AppBreadcrumbItem(label: SizeSystemsKeys.groupsTitle),
  ],
);

/// Catalog > Size systems > Groups > Sizes.
Widget sizesBreadcrumb(
  BuildContext context, {
  required int systemId,
  SizeRouteContext? labels,
}) => AppBreadcrumb(
  items: [
    AppBreadcrumbItem(
      label: NavKeys.catalog,
      onTap: () => context.go(CatalogRoutes.hub.path),
    ),
    AppBreadcrumbItem(
      label: SizeSystemsKeys.systemsTitle,
      onTap: () => context.go(SizeSystemsRoutes.sizeSystems.path),
    ),
    AppBreadcrumbItem(
      label: SizeSystemsKeys.groupsTitle,
      onTap: () => context.go(
        SizeSystemsRoutes.groups(systemId),
        extra: labels == null
            ? null
            : SizeRouteContext(systemName: labels.systemName),
      ),
    ),
    const AppBreadcrumbItem(label: SizeSystemsKeys.sizesTitle),
  ],
);

/// The parent names (system, group) shown above a child list when known.
List<Widget> parentHeader(SizeRouteContext? labels) {
  final names = [
    if (labels?.systemName != null) labels!.systemName!,
    if (labels?.groupName != null) labels!.groupName!,
  ];
  if (names.isEmpty) return const [];
  return [AppText.raw(names.join('  ›  '), type: AppTextType.titleSmall)];
}
