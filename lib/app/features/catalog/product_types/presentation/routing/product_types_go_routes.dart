import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/routing/not_found_screen.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/routing/product_types_routes.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/pages/product_types_screen.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/pages/product_type_details_screen.dart';

List<RouteBase> buildProductTypesGoRoutes({
  required AccessCubit accessCubit,
  required bool Function() isAuthenticated,
}) => [
  GoRoute(
    path: ProductTypesRoutes.productTypes.path,
    name: ProductTypesRoutes.productTypes.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, isAuthenticated, context, state),
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: ProductTypesScreen()),
  ),
  GoRoute(
    path: ProductTypesRoutes.detailsPath,
    name: ProductTypesRoutes.productTypeDetails.name,
    redirect: (context, state) =>
        catalogAccessRedirect(accessCubit, session, context, state),
    pageBuilder: (context, state) {
      final id = int.tryParse(state.pathParameters['id'] ?? '');
      return NoTransitionPage(
        child: id == null
            ? NotFoundScreen(location: state.uri.toString())
            : ProductTypeDetailsScreen(productTypeId: id),
      );
    },
  ),
];
