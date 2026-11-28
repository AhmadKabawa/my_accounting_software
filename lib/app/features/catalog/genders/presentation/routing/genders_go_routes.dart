import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/routing/genders_routes.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/pages/genders_screen.dart';

List<RouteBase> buildGendersGoRoutes({required AccessCubit accessCubit}) => [
GoRoute(
    path: GendersRoutes.genders.path,
    name: GendersRoutes.genders.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: GendersScreen()),
  )
];
