import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class CareInstructionsRoutes {
  static const careInstructions = RouteItem('/catalog/care-instructions', 'catalog.careInstructions');
  static const List<RouteItem> all = [careInstructions];
}
