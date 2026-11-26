import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class TagsRoutes {
  static const tags = RouteItem('/catalog/tags', 'catalog.tags');
  static const List<RouteItem> all = [tags];
}
