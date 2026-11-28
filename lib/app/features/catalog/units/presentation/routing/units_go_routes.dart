import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/routing/units_routes.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/pages/units_screen.dart';

List<RouteBase> buildUnitsGoRoutes({
  required AccessCubit accessCubit,
  required SessionGate session,
}) => [
  GoRoute(
    path: UnitsRoutes.units.path,
    name: UnitsRoutes.units.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, session, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: UnitsScreen()),
  ),
];
