import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/catalog/presentation/routing/catalog_routes.dart';
import 'package:accounting_software/app/features/catalog/catalog/presentation/pages/catalog_hub_screen.dart';

List<RouteBase> buildCatalogFeatureGoRoutes({required AccessCubit accessCubit}) => [
GoRoute(
    path: CatalogRoutes.hub.path,
    name: CatalogRoutes.hub.name,
    redirect: (context, state) => catalogAccessRedirect(accessCubit, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: CatalogHubScreen()),
  ),
GoRoute(
    path: CatalogRoutes.masterData.path,
    name: CatalogRoutes.masterData.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, context, state) ??
        catalogMasterDataRedirect(),
  )
];
