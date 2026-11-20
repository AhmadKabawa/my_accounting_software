import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class CatalogRoutes {
  /// The Catalog hub: the shell tab opens here and lists the catalog areas
  /// (Brands now, more later).
  static const hub = RouteItem('/catalog', 'catalog');

  /// Legacy CAT-07 alias, kept so old links keep working; it opens the hub.
  static const masterData = RouteItem(
    '/catalog/master-data',
    'catalog.master-data',
  );

  static const List<RouteItem> all = [hub, masterData];
}

/// Where the legacy master-data alias goes.
String catalogMasterDataRedirect() => CatalogRoutes.hub.path;
