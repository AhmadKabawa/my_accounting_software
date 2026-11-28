import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class ProductTypesRoutes {
  static const productTypes = RouteItem(
    '/catalog/product-types',
    'catalog.productTypes',
  );

  // Dynamic detail routes are registered in GoRouter directly and added to
  // the complete route registry in app/routing/route_registry.dart.
  static const detailsPath = '/catalog/product-types/:id';
  static const productTypeDetailsName = 'catalog.productTypeDetails';

  static String details(int id) => '/catalog/product-types/$id';

  static const List<RouteItem> all = [productTypes];
}
