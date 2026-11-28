import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/routing/option_sets_routes.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/pages/option_sets_screen.dart';

List<RouteBase> buildOptionSetsGoRoutes({required AccessCubit accessCubit}) => [
GoRoute(
    path: OptionSetsRoutes.optionSets.path,
    name: OptionSetsRoutes.optionSets.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: OptionSetsScreen()),
  )
];
