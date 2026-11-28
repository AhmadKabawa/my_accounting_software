import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/routing/not_found_screen.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/pages/size_systems_screen.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/pages/size_groups_screen.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/pages/sizes_screen.dart';

List<RouteBase> buildSizeSystemsGoRoutes({required AccessCubit accessCubit}) =>
    [
      GoRoute(
        path: SizeSystemsRoutes.sizeSystems.path,
        name: SizeSystemsRoutes.sizeSystems.name,
        redirect: (context, state) =>
            catalogAccessRedirect(accessCubit, context, state),
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SizeSystemsScreen()),
      ),
      GoRoute(
        path: SizeSystemsRoutes.groupsPath,
        name: SizeSystemsRoutes.groupsName,
        redirect: (context, state) =>
            catalogAccessRedirect(accessCubit, context, state),
        pageBuilder: (context, state) {
          final systemId = int.tryParse(state.pathParameters['systemId'] ?? '');
          final extra = state.extra;
          return NoTransitionPage(
            child: systemId == null
                ? NotFoundScreen(location: state.uri.toString())
                : SizeGroupsScreen(
                    systemId: systemId,
                    labels: extra is SizeRouteContext ? extra : null,
                  ),
          );
        },
      ),
      GoRoute(
        path: SizeSystemsRoutes.sizesPath,
        name: SizeSystemsRoutes.sizesName,
        redirect: (context, state) =>
            catalogAccessRedirect(accessCubit, context, state),
        pageBuilder: (context, state) {
          final systemId = int.tryParse(state.pathParameters['systemId'] ?? '');
          final groupId = int.tryParse(state.pathParameters['groupId'] ?? '');
          final extra = state.extra;
          return NoTransitionPage(
            child: systemId == null || groupId == null
                ? NotFoundScreen(location: state.uri.toString())
                : SizesScreen(
                    systemId: systemId,
                    groupId: groupId,
                    labels: extra is SizeRouteContext ? extra : null,
                  ),
          );
        },
      ),
    ];
