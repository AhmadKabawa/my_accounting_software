import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/routing/attributes_routes.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/pages/attributes_screen.dart';

List<RouteBase> buildAttributesGoRoutes({required AccessCubit accessCubit, required SessionGate session}) => [
  GoRoute(
    path: AttributesRoutes.attributes.path,
    name: AttributesRoutes.attributes.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, session, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: AttributesScreen()),
  ),
];
