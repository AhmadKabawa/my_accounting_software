import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_routes.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/pages/brands_screen.dart';

List<RouteBase> buildBrandsGoRoutes({required AccessCubit accessCubit}) => [
GoRoute(
    path: BrandsRoutes.brands.path,
    name: BrandsRoutes.brands.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, context, state),
    pageBuilder: (context, state) =>
        NoTransitionPage(child: const BrandsScreen()),
  )
];
