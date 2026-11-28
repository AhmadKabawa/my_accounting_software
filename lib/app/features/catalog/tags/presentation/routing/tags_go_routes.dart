import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/routing/tags_routes.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/pages/tags_screen.dart';

List<RouteBase> buildTagsGoRoutes({
  required AccessCubit accessCubit,
  required bool Function() isAuthenticated,
}) => [
  GoRoute(
    path: TagsRoutes.tags.path,
    name: TagsRoutes.tags.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, isAuthenticated, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: TagsScreen()),
  ),
];
