import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/routing/route_guards.dart';
import 'package:accounting_software/app/features/access/presentation/routing/access_routes.dart';

String? catalogAccessRedirect(
  AccessCubit accessCubit,
  BuildContext context,
  GoRouterState state,
) => AccessRoutingLogic.require(
  const Permission('catalog.manage'),
  can: accessCubit.can,
  isResolved: () =>
      accessCubit.state.status != AccessStatus.initial &&
      accessCubit.state.status != AccessStatus.loading,
  fallback: AccessRoutes.denied,
)(context, state);
