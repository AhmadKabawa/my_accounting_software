import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/routing/categories_routes.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/categories_list_page.dart';

List<RouteBase> buildCategoriesGoRoutes({
  required AccessCubit accessCubit,
  required bool Function() isAuthenticated,
}) => [
  GoRoute(
    path: CategoriesRoutes.categories.path,
    name: CategoriesRoutes.categories.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, isAuthenticated, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: CategoriesListPage()),
  ),
];
