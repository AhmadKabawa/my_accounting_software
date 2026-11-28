import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/routing/seasons_routes.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/pages/seasons_screen.dart';

List<RouteBase> buildSeasonsGoRoutes({required AccessCubit accessCubit}) => [
  GoRoute(
    path: SeasonsRoutes.seasons.path,
    name: SeasonsRoutes.seasons.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: SeasonsScreen()),
  ),
];
