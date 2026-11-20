import 'package:accounting_software/app/core/routing/route_item.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/brands_routes.dart';

abstract final class CatalogRoutes {
  static const masterData = RouteItem(
    '/catalog/master-data',
    'catalog.master-data',
  );

  static const List<RouteItem> all = [masterData];
}

/// The CAT-07 entry is a route alias until a second master-data page exists.
String catalogMasterDataRedirect() => BrandsRoutes.brands.path;
