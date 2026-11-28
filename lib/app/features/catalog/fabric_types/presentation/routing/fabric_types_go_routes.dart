import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/routing/fabric_types_routes.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/pages/fabric_types_screen.dart';

List<RouteBase> buildFabricTypesGoRoutes({
  required AccessCubit accessCubit,
  required SessionGate session,
}) => [
  GoRoute(
    path: FabricTypesRoutes.fabricTypes.path,
    name: FabricTypesRoutes.fabricTypes.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, session, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: FabricTypesScreen()),
  ),
];
