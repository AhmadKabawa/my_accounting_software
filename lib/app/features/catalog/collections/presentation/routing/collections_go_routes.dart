import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/routing/collections_routes.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/pages/collections_screen.dart';

List<RouteBase> buildCollectionsGoRoutes({required AccessCubit accessCubit, required SessionGate session}) =>
    [
      GoRoute(
        path: CollectionsRoutes.collections.path,
        name: CollectionsRoutes.collections.name,
        redirect: (context, state) =>
            catalogAccessRedirect(accessCubit, session, context, state),
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CollectionsScreen()),
      ),
    ];
