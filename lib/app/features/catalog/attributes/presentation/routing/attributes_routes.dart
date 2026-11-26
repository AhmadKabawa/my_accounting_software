import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class AttributesRoutes {
  static const attributes = RouteItem(
    '/catalog/attributes',
    'catalog.attributes',
  );
  static const List<RouteItem> all = [attributes];
}
