import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/routing/unsaved_changes_guard.dart';
import 'package:accounting_software/app/core/access/presentation/access_status_gate.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/shell_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_rail/app_navigation_rail.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_scope_selector/scope_selector.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_shell/app_shell_top_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/shell/destinations.dart';

const _mobileDestinationOverflowThreshold = 5;
const _mobileVisibleDestinationsWhenOverflow = 4;

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<AppDestination> destinations;
  final List<AppMenuEntry> userMenuEntries;
  final List<AppBreadcrumbItem> breadcrumbs;
  final List<AppBreadcrumbItem> Function(GoRouterState state)? breadcrumbBuilder;
  final Future<bool> Function(ScopeOption)? beforeBranchChange;
  final AppKey? cashierSessionKey;
  final bool supportsCollapsibleSidebar;
  final AppSettingsManager? settingsManager;
  final UnsavedChangesGuard? unsavedChangesGuard;
  final Future<bool> Function(int destinationBranch)? beforeDestinationChange;

  const AppShell({
    super.key,
    required this.navigationShell,
    this.destinations = appDestinations,
    this.userMenuEntries = const [],
    this.breadcrumbs = const [],
    this.breadcrumbBuilder,
    this.beforeBranchChange,
    this.cashierSessionKey,
    this.supportsCollapsibleSidebar = false,
    this.settingsManager,
    this.unsavedChangesGuard,
    this.beforeDestinationChange,
  });

  Future<void> _showMore(
    BuildContext context,
    List<AppDestination> overflow,
  ) async {
    final selectedBranch = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => ListView(
        padding: EdgeInsets.all(AppSpacing.md.of(sheetContext)),
        shrinkWrap: true,
        children: [
          for (final destination in overflow)
            ListTile(
              leading: AppIcon(destination.item.icon),
              title: AppText(destination.item.label),
              onTap: () =>
                  Navigator.of(sheetContext).pop(destination.branchIndex),
            ),
        ],
      ),
    );
    if (selectedBranch == null || !context.mounted) return;
    if (!await _canNavigateTo(context, selectedBranch) || !context.mounted) {
      return;
    }
    navigationShell.goBranch(selectedBranch);
  }

  Future<bool> _canNavigateTo(
    BuildContext context,
    int destinationBranch,
  ) async {
    final beforeChange = beforeDestinationChange;
    if (beforeChange != null) {
      final allowed = await beforeChange(destinationBranch);
      if (!allowed || !context.mounted) return false;
    }
    final guard = unsavedChangesGuard;
    if (guard == null) return true;
    final allowed = await guard.confirmBranch(navigationShell.currentIndex);
    return allowed && context.mounted;
  }

  Future<void> _select(
    BuildContext context,
    List<AppDestination> visible,
    int index,
  ) async {
    final branch = visible[index].branchIndex;
    if (!await _canNavigateTo(context, branch) || !context.mounted) return;
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  Future<bool> _confirmActiveBranch() async {
    final guard = unsavedChangesGuard;
    if (guard == null) return true;
    return guard.confirmBranch(navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      destinations.length == navigationShell.route.branches.length,
      'AppShell: ${destinations.length} destinations but the shell route has '
      '${navigationShell.route.branches.length} branches',
    );

    final access = context.watch<AccessCubit>();
    final visible = filterDestinations(destinations, access.can);
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
    Future<void> onSelect(int index) => _select(context, visible, index);
    Future<bool> confirmBranchChange(ScopeOption option) async {
      if (!await _confirmActiveBranch() || !context.mounted) return false;
      final allowed = await beforeBranchChange?.call(option) ?? true;
      return allowed && context.mounted;
    }

    final guardedUserMenuEntries = [
      for (final entry in userMenuEntries)
        AppMenuEntry(
          label: entry.label,
          icon: entry.icon,
          enabled: entry.enabled,
          requiresUnsavedChangesCheck: entry.requiresUnsavedChangesCheck,
          onSelected: () async {
            if (entry.requiresUnsavedChangesCheck) {
              if (!await _confirmActiveBranch() || !context.mounted) return;
            }
            entry.onSelected();
          },
        ),
    ];
    final shellContent = unsavedChangesGuard == null
        ? navigationShell
        : UnsavedChangesGuardScope(
            guard: unsavedChangesGuard!,
            activeBranchIndex: navigationShell.currentIndex,
            child: navigationShell,
          );
    final snapshot = access.state.snapshot;
    final titleKey = current >= 0
        ? visible[current].item.label
        : visible.isNotEmpty
        ? visible.first.item.label
        : null;

    final routeBreadcrumbs =
        breadcrumbBuilder?.call(GoRouterState.of(context)) ?? breadcrumbs;

    PreferredSizeWidget? topBar;
    if (snapshot != null && titleKey != null) {
      topBar = AppShellTopBar(
        titleKey: titleKey,
        snapshot: snapshot,
        selectedBranchId: access.state.selectedBranchId,
        onBranchChanged: access.selectBranch,
        beforeBranchChange: unsavedChangesGuard == null
            ? beforeBranchChange
            : confirmBranchChange,
        breadcrumbs: routeBreadcrumbs,
        cashierSessionKey: cashierSessionKey,
        userMenuEntries: guardedUserMenuEntries,
        leading: supportsCollapsibleSidebar && GoRouter.of(context).canPop()
            ? AppIconButton(
                AppIcons.back,
                tooltipKey: ShellKeys.back,
                onPressed: () => context.pop(),
              )
            : null,
      );
    }

    Widget withSideNav(Widget nav) => Scaffold(
      appBar: topBar,
      body: Row(
        children: [
          nav,
          Expanded(child: shellContent),
        ],
      ),
    );

    return AccessStatusGate(
      child: FlashMessageListener(
        child: Rh.builder(
          context: context,
          mobile: (_) {
            final hasOverflow =
                visible.length > _mobileDestinationOverflowThreshold;
            final mobileDestinations = hasOverflow
                ? visible.take(_mobileVisibleDestinationsWhenOverflow).toList()
                : visible;
            final overflow = hasOverflow
                ? visible.skip(_mobileVisibleDestinationsWhenOverflow).toList()
                : <AppDestination>[];
            final mobileItems = [
              for (final destination in mobileDestinations) destination.item,
              if (hasOverflow)
                NavBarItem.icons(icon: AppIcons.more, label: ShellKeys.more),
            ];
            final activeMobileIndex =
                hasOverflow && current >= _mobileVisibleDestinationsWhenOverflow
                ? _mobileVisibleDestinationsWhenOverflow
                : current < 0
                ? 0
                : current;

            return Scaffold(
              appBar: topBar,
              body: shellContent,
              bottomNavigationBar: mobileItems.isEmpty
                  ? null
                  : AppNavigationBar(
                      items: mobileItems,
                      activeIndex: activeMobileIndex,
                      onIndexChanged: (index) {
                        if (index < mobileDestinations.length) {
                          _select(context, mobileDestinations, index);
                        } else {
                          _showMore(context, overflow);
                        }
                      },
                      showLabelsAlways: false,
                    ),
            );
          },
          tablet: (_) => withSideNav(
            AppNavigationRail(
              items: items,
              activeIndex: current < 0 ? 0 : current,
              onIndexChanged: onSelect,
            ),
          ),
          desktop: (_) => withSideNav(
            supportsCollapsibleSidebar && settingsManager != null
                ? _PersistedWindowsSidebar(
                    items: items,
                    activeIndex: current < 0 ? 0 : current,
                    onIndexChanged: onSelect,
                    settingsManager: settingsManager!,
                  )
                : AppSidebar(
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


class _PersistedWindowsSidebar extends StatefulWidget {
  const _PersistedWindowsSidebar({
    required this.items,
    required this.activeIndex,
    required this.onIndexChanged,
    required this.settingsManager,
  });

  final List<NavBarItem> items;
  final int activeIndex;
  final ValueChanged<int> onIndexChanged;
  final AppSettingsManager settingsManager;

  @override
  State<_PersistedWindowsSidebar> createState() =>
      _PersistedWindowsSidebarState();
}

class _PersistedWindowsSidebarState extends State<_PersistedWindowsSidebar> {
  bool _collapsed = false;
  bool _restored = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final collapsed = await widget.settingsManager.getSidebarCollapsed();
    if (!mounted) return;
    setState(() {
      _collapsed = collapsed;
      _restored = true;
    });
  }

  Future<void> _toggle() async {
    final collapsed = !_collapsed;
    setState(() => _collapsed = collapsed);
    await widget.settingsManager.setSidebarCollapsed(collapsed);
  }

  @override
  Widget build(BuildContext context) => AppSidebar(
    items: widget.items,
    activeIndex: widget.activeIndex,
    onIndexChanged: widget.onIndexChanged,
    collapsed: _collapsed,
    onToggle: _restored ? _toggle : null,
  );
}
