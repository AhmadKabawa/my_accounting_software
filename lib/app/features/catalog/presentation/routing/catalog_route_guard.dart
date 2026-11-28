import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/routing/route_guards.dart';
import 'package:accounting_software/app/features/access/presentation/routing/access_routes.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';

/// Waits for the authenticated user's server access snapshot before deciding.
/// A pending session is left to the app-level session redirect; an authenticated
/// session with a missing/failed access snapshot is denied (fail closed).
Future<String?> catalogAccessRedirect(
  AccessCubit accessCubit,
  SessionGate session,
  BuildContext context,
  GoRouterState state,
) async {
  if (session.current is! SessionAuthenticated) return null;

  if (accessCubit.state.status == AccessStatus.initial) {
    await accessCubit.load();
  } else if (accessCubit.state.status == AccessStatus.loading) {
    await accessCubit.stream.firstWhere(
      (state) =>
          state.status != AccessStatus.initial &&
          state.status != AccessStatus.loading,
    );
  }

  if (!context.mounted) return null;

  return AccessRoutingLogic.require(
    const Permission('catalog.manage'),
    can: accessCubit.can,
    fallback: AccessRoutes.denied,
  )(context, state);
}
