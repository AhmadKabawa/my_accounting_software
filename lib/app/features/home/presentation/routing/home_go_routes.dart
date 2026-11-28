import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/features/home/presentation/pages/home_screen.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/core/routing/route_item.dart';

List<RouteBase> buildHomeGoRoutes({
  required List<RouteItem> registeredRoutes,
}) => [
  GoRoute(
    path: HomeRoutes.home.path,
    name: HomeRoutes.home.name,
    pageBuilder: (context, state) =>
        NoTransitionPage(child: HomeScreen(registeredRoutes: registeredRoutes)),
  ),
];
