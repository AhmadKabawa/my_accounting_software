import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_rail/app_navigation_rail.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/shell/destinations.dart';

/// The frame of the main app: picks the navigation by **device**
/// (`Rh.builder`): bottom bar on phones, rail on tablets, sidebar on desktops.
///
/// Destinations are filtered by permission, and every tap is mapped to its
/// `branchIndex`, so hiding a destination never shifts the others' branches.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  /// Injectable so tests can pass a set that differs from the router.
  final List<AppDestination> destinations;

  const AppShell({
    super.key,
    required this.navigationShell,
    this.destinations = appDestinations,
  });

  void _select(List<AppDestination> visible, int index) {
    final branch = visible[index].branchIndex;
    navigationShell.goBranch(
      branch,

      /// إذا ضغط على نفس التبويب
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(
      destinations.length == navigationShell.route.branches.length,
      'AppShell: ${destinations.length} destinations but the shell route has '
      '${navigationShell.route.branches.length} branches',
    );

    final access = context.watch<AccessCubit>();
    final visible = [
      for (final d in destinations)
        if (d.permission == null || access.can(d.permission!)) d,
    ];
    final current = visible.indexWhere(
      (d) => d.branchIndex == navigationShell.currentIndex,
    );

    // The role changed and the selected tab is now hidden: move to the first
    // visible one instead of leaving the user on a page the bar doesn't show.
    if (current == -1 && visible.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        navigationShell.goBranch(visible.first.branchIndex);
      });
    }

    final items = [for (final d in visible) d.item];
    void onSelect(int index) => _select(visible, index);

    Widget withSideNav(Widget nav) => Scaffold(
      body: Row(
        children: [
          nav,
          Expanded(child: navigationShell),
        ],
      ),
    );

    return Rh.builder(
      context: context,
      mobile: (_) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: items.isEmpty
            ? null
            : AppNavigationBar(
                items: items,
                activeIndex: current,
                onIndexChanged: onSelect,
                elevation: 2,
                showLabelsAlways: false,
              ),
      ),
      tablet: (_) => withSideNav(
        AppNavigationRail(
          items: items,
          activeIndex: current,
          onIndexChanged: onSelect,
        ),
      ),
      desktop: (_) => withSideNav(
        AppSidebar(
          items: items,
          activeIndex: current,
          onIndexChanged: onSelect,
        ),
      ),
    );
  }
}
