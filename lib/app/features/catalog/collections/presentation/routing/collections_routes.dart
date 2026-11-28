import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class CollectionsRoutes {
  static const collections = RouteItem(
    '/catalog/collections',
    'catalog.collections',
  );
  static const List<RouteItem> all = [collections];
}
