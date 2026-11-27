import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class GendersRoutes {
  static const genders = RouteItem('/catalog/genders', 'catalog.genders');
  static const List<RouteItem> all = [genders];
}
