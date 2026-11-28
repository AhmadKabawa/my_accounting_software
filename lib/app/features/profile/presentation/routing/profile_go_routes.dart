import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_routes.dart';

List<RouteBase> buildProfileGoRoutes({
  required Widget Function() buildPage,
}) => [
  GoRoute(
    path: ProfileRoutes.profile.path,
    name: ProfileRoutes.profile.name,
    pageBuilder: (context, state) =>
        NoTransitionPage(child: buildPage()),
  ),
];
