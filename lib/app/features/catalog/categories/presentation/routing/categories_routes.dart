import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class CategoriesRoutes {
  static const categories = RouteItem(
    '/catalog/categories',
    'catalog.categories',
  );

  static const List<RouteItem> all = [categories];
}
