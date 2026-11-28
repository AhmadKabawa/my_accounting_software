import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/routing/age_groups_routes.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/pages/age_groups_screen.dart';

List<RouteBase> buildAgeGroupsGoRoutes({required AccessCubit accessCubit}) => [
  GoRoute(
    path: AgeGroupsRoutes.ageGroups.path,
    name: AgeGroupsRoutes.ageGroups.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: AgeGroupsScreen()),
  ),
];
