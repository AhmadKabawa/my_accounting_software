import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/routing/route_transitions.dart';
import 'package:accounting_software/app/features/access/presentation/pages/access_denied_screen.dart';
import 'package:accounting_software/app/features/access/presentation/routing/access_routes.dart';

List<RouteBase> buildAccessGoRoutes() => [
  GoRoute(
    path: AccessRoutes.denied.path,
    name: AccessRoutes.denied.name,
    pageBuilder: (context, state) =>
        RouteTransitions.fade(context, state, const AccessDeniedScreen()),
  ),
];
