import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class ProductTypesRoutes {
  static const productTypes = RouteItem(
    '/catalog/product-types',
    'catalog.productTypes',
  );

  // Dynamic detail routes are registered in GoRouter directly and included
  // in the route catalogue so they receive the same protected classification.
  static const detailsPath = '/catalog/product-types/:id';
  static const productTypeDetails = RouteItem(
    detailsPath,
    'catalog.productTypeDetails',
  );

  static String details(int id) => '/catalog/product-types/$id';

  static const List<RouteItem> all = [productTypes, productTypeDetails];
}
