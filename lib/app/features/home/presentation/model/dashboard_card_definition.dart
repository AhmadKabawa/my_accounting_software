import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_data.dart';
import 'package:accounting_software/app/core/routing/route_item.dart';

/// A dashboard destination is shown only when its permission is granted and
/// its route is part of the application's registered route catalogue.
class DashboardCardDefinition {
  const DashboardCardDefinition({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.permission,
    required this.destination,
  });

  final String id;
  final AppKey titleKey;
  final AppKey descriptionKey;
  final AppIconData icon;
  final Permission permission;
  final RouteItem destination;
}

/// No AUTH-04 targets are registered yet. Add a definition alongside the
/// feature route when its target screen is implemented.
const dashboardCardDefinitions = <DashboardCardDefinition>[];

List<DashboardCardDefinition> availableDashboardCards({
  required Iterable<DashboardCardDefinition> definitions,
  required Iterable<RouteItem> registeredRoutes,
  required bool Function(Permission permission) can,
}) {
  final routes = {
    for (final route in registeredRoutes) '${route.name}|${route.path}',
  };

  return [
    for (final definition in definitions)
      if (routes.contains(
            '${definition.destination.name}|${definition.destination.path}',
          ) &&
          can(definition.permission))
        definition,
  ];
}
