import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class ProductTypesRoutes {
  static const productTypes = RouteItem(
    '/catalog/product-types',
    'catalog.productTypes',
  );

  // Dynamic detail routes are registered in GoRouter directly. The registry
  // exposes only the stable list destination for home-route discovery.
  static const detailsPath = '/catalog/product-types/:id';

  static String details(int id) => '/catalog/product-types/$id';

  static const List<RouteItem> all = [productTypes];
}
