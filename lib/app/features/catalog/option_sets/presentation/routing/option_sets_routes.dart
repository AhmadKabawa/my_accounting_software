import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class OptionSetsRoutes {
  static const optionSets = RouteItem(
    '/catalog/option-sets',
    'catalog.option-sets',
  );
  static const List<RouteItem> all = [optionSets];
}
