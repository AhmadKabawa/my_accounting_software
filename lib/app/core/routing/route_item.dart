/// A named route: the [path] GoRouter matches and the [name] used to navigate
/// (`context.goNamed(item.name)`).
///
/// Core owns only this tool. Each feature declares its own routes in
/// `features/<feature>/presentation/routing/<feature>_routes.dart`, and
/// `lib/app/routing/route_registry.dart` gathers them.
class RouteItem {
  final String path;
  final String name;

  const RouteItem(this.path, this.name);
}
