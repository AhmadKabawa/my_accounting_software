import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class AgeGroupsRoutes {
  static const ageGroups = RouteItem(
    '/catalog/age-groups',
    'catalog.ageGroups',
  );
  static const List<RouteItem> all = [ageGroups];
}
