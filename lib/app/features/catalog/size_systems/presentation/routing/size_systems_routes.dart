import 'package:accounting_software/app/core/routing/route_item.dart';

/// Optional parent labels handed through `GoRouterState.extra` so the child
/// screens can show the parent names. A deep link has no extra: the names are
/// simply omitted and the screen works from the ids in the path.
class SizeRouteContext {
  const SizeRouteContext({this.systemName, this.groupName});

  final String? systemName;
  final String? groupName;
}

abstract final class SizeSystemsRoutes {
  static const sizeSystems = RouteItem(
    '/catalog/size-systems',
    'catalog.sizeSystems',
  );

  // Dynamic routes are registered in GoRouter directly and included in the
  // route catalogue so they receive the same protected classification.
  static const groupsPath = '/catalog/size-systems/:systemId';
  static const groupsName = 'catalog.sizeSystemGroups';
  static const sizesPath = '/catalog/size-systems/:systemId/groups/:groupId';
  static const sizesName = 'catalog.sizeGroupSizes';

  static String groups(int systemId) => '/catalog/size-systems/$systemId';

  static String sizes(int systemId, int groupId) =>
      '/catalog/size-systems/$systemId/groups/$groupId';

  static const List<RouteItem> all = [sizeSystems];
}
