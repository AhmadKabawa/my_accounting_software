import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/presentation/access_status_gate.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_rail/app_navigation_rail.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_scope_selector/scope_selector.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_shell/app_shell_top_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/shell/destinations.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<AppDestination> destinations;
  final List<AppMenuEntry> userMenuEntries;
  final List<AppBreadcrumbItem> breadcrumbs;
  final Future<bool> Function(ScopeOption)? beforeBranchChange;
  final AppKey? cashierSessionKey;

  const AppShell({
    super.key,
    required this.navigationShell,
    this.destinations = appDestinations,
    this.userMenuEntries = const [],
    this.breadcrumbs = const [],
    this.beforeBranchChange,
    this.cashierSessionKey,
  });

  void _select(List<AppDestination> visible, int index) {
    final branch = visible[index].branchIndex;
    navigationShell.goBranch(
      branch,
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
      for (final destination in destinations)
        if (destination.permission == null || access.can(destination.permission!))
          destination,
    ];
    final current = visible.indexWhere(
      (destination) => destination.branchIndex == navigationShell.currentIndex,
    );

    if (current == -1 && visible.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        navigationShell.goBranch(visible.first.branchIndex);
      });
    }

    final items = [for (final destination in visible) destination.item];
    void onSelect(int index) => _select(visible, index);
    final snapshot = access.state.snapshot;
    final titleKey = current >= 0 ? visible[current].item.label : visible.isNotEmpty ? visible.first.item.label : null;

    PreferredSizeWidget? topBar;
    if (snapshot != null && titleKey != null) {
      topBar = AppShellTopBar(
        titleKey: titleKey,
        snapshot: snapshot,
        selectedBranchId: access.state.selectedBranchId,
        onBranchChanged: access.selectBranch,
        beforeBranchChange: beforeBranchChange,
        breadcrumbs: breadcrumbs,
        cashierSessionKey: cashierSessionKey,
        userMenuEntries: userMenuEntries,
      );
    }

    Widget withSideNav(Widget nav) => Scaffold(
      appBar: topBar,
      body: Row(children: [nav, Expanded(child: navigationShell)]),
    );

    return AccessStatusGate(
      child: FlashMessageListener(
        child: Rh.builder(
          context: context,
          mobile: (_) => Scaffold(
            appBar: topBar,
            body: navigationShell,
            bottomNavigationBar: items.isEmpty
                ? null
                : AppNavigationBar(
                    items: items,
                    activeIndex: current < 0 ? 0 : current,
                    onIndexChanged: onSelect,
                    showLabelsAlways: false,
                  ),
          ),
          tablet: (_) => withSideNav(
            AppNavigationRail(
              items: items,
              activeIndex: current < 0 ? 0 : current,
              onIndexChanged: onSelect,
            ),
          ),
          desktop: (_) => withSideNav(
            AppSidebar(
              items: items,
              activeIndex: current < 0 ? 0 : current,
              onIndexChanged: onSelect,
            ),
          ),
        ),
      ),
    );
  }
}
