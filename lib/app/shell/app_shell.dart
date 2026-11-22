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
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_scope_selector/scope_selector.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_shell/app_shell_top_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/shell/destinations.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';

const _mobileDestinationOverflowThreshold = 5;
const _mobileVisibleDestinationsWhenOverflow = 4;

Future<bool> runGuardedUserMenuAction({
  required AppMenuEntry entry,
  required Future<bool> Function() confirmAllForms,
  required bool Function() isMounted,
  required void Function() discardAll,
}) async {
  if (entry.requiresUnsavedChangesCheck) {
    if (!await confirmAllForms() || !isMounted()) return false;
  }

  final succeeded = entry.onSelectedGuardedAsync != null
      ? await entry.onSelectedGuardedAsync!()
      : entry.onSelectedAsync != null
      ? await _runAsyncMenuAction(entry)
      : _runSyncMenuAction(entry);

  if (entry.requiresUnsavedChangesCheck && succeeded) discardAll();
  return succeeded;
}

Future<bool> _runAsyncMenuAction(AppMenuEntry entry) async {
  await entry.onSelectedAsync!();
  return true;
}

bool _runSyncMenuAction(AppMenuEntry entry) {
  entry.onSelected();
  return true;
}

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<AppDestination> destinations;
  final List<AppMenuEntry> userMenuEntries;
  final List<AppBreadcrumbItem> breadcrumbs;
  final List<AppBreadcrumbItem> Function(GoRouterState state)?
  breadcrumbBuilder;
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

  /// "More" on a phone: the overflow destinations as a main/sub tree (each
  /// destination followed by its children), not a flat list.
  Future<void> _showMore(
    BuildContext context,
    List<AppDestination> overflow,
  ) async {
    final picked = await showModalBottomSheet<_MoreChoice>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => _MoreTree(
        destinations: overflow,
        activePath: _activePath(context),
        activeBranch: navigationShell.currentIndex,
      ),
    );
    if (picked == null || !context.mounted) return;
    final branch = picked.branch;
    final isActiveBranch = branch == navigationShell.currentIndex;
    if (!await _canNavigateTo(context, branch) || !context.mounted) return;
    if (picked.path != null) {
      context.go(picked.path!);
      return;
    }
    navigationShell.goBranch(branch, initialLocation: isActiveBranch);
    if (isActiveBranch) unsavedChangesGuard?.discardBranch(branch);
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
    // Switching to another indexedStack branch preserves the current form.
    // Only reselecting the active destination resets its initial location.
    if (destinationBranch != navigationShell.currentIndex) return true;
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
    final isActiveBranch = branch == navigationShell.currentIndex;
    navigationShell.goBranch(branch, initialLocation: isActiveBranch);
    if (isActiveBranch) unsavedChangesGuard?.discardBranch(branch);
  }

  Future<bool> _confirmAllForms() async {
    final guard = unsavedChangesGuard;
    if (guard == null) return true;
    return guard.confirmAll();
  }

  /// Current location, to highlight a sidebar child. Null outside a router.
  String? _activePath(BuildContext context) =>
      GoRouter.maybeOf(context)?.routeInformationProvider.value.uri.path;

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
      final ownerAllows = await beforeBranchChange?.call(option) ?? true;
      if (!ownerAllows || !context.mounted) return false;
      return await _confirmAllForms() && context.mounted;
    }

    Future<void> selectBranch(int branchId) async {
      final previousBranchId = access.state.selectedBranchId;
      await access.selectBranch(branchId);
      if (previousBranchId != branchId &&
          access.state.isReady &&
          access.state.selectedBranchId == branchId) {
        unsavedChangesGuard?.discardAll();
      }
    }

    final guardedUserMenuEntries = [
      for (final entry in userMenuEntries)
        AppMenuEntry(
          label: entry.label,
          icon: entry.icon,
          enabled: entry.enabled,
          requiresUnsavedChangesCheck: entry.requiresUnsavedChangesCheck,
          onSelected: () {},
          onSelectedAsync: entry.onSelectedAsync,
          onSelectedGuardedAsync: () => runGuardedUserMenuAction(
            entry: entry,
            confirmAllForms: _confirmAllForms,
            isMounted: () => context.mounted,
            discardAll: () => unsavedChangesGuard?.discardAll(),
          ),
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
        onBranchChanged: selectBranch,
        beforeBranchChange: unsavedChangesGuard == null
            ? beforeBranchChange
            : confirmBranchChange,
        breadcrumbs: routeBreadcrumbs,
        cashierSessionKey: cashierSessionKey,
        userMenuEntries: guardedUserMenuEntries,
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

    Widget sidebar({bool startCollapsed = false}) => settingsManager != null
        ? _PersistedSidebar(
            items: items,
            activeIndex: current < 0 ? 0 : current,
            onIndexChanged: onSelect,
            settingsManager: settingsManager!,
            collapsible: startCollapsed || supportsCollapsibleSidebar,
            startCollapsed: startCollapsed,
            activePath: _activePath(context),
            onChildSelected: (path) => context.go(path),
          )
        : AppSidebar(
            items: items,
            activeIndex: current < 0 ? 0 : current,
            onIndexChanged: onSelect,
            collapsed: startCollapsed,
            activePath: _activePath(context),
            onChildSelected: (path) => context.go(path),
          );

    return AccessStatusGate(
      signOutLabel: AuthKeys.signOut,
      onSignOut: () async {
        if (!await _confirmAllForms() || !context.mounted) return false;
        final succeeded = await context
            .read<SessionCubit>()
            .signOutWithResult();
        if (succeeded) unsavedChangesGuard?.discardAll();
        return succeeded;
      },
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
                  : _ShellMobileNavigation(
                      items: mobileItems,
                      activeIndex: activeMobileIndex,
                      onDestinationSelected: (index) =>
                          _select(context, mobileDestinations, index),
                      moreIndex: hasOverflow ? mobileDestinations.length : null,
                      onMoreSelected: () => _showMore(context, overflow),
                    ),
            );
          },
          // A tablet gets the same sidebar, icon-only until the user opens it.
          tablet: (_) => withSideNav(sidebar(startCollapsed: true)),
          desktop: (_) => withSideNav(sidebar()),
        ),
      ),
    );
  }
}

/// The desktop sidebar with its preferences: the open sections are always
/// restored and saved; collapsing is offered only where [collapsible].
class _PersistedSidebar extends StatefulWidget {
  const _PersistedSidebar({
    required this.items,
    required this.activeIndex,
    required this.onIndexChanged,
    required this.settingsManager,
    required this.collapsible,
    this.startCollapsed = false,
    this.activePath,
    this.onChildSelected,
  });

  final String? activePath;
  final ValueChanged<String>? onChildSelected;
  final List<NavBarItem> items;
  final int activeIndex;
  final ValueChanged<int> onIndexChanged;
  final AppSettingsManager settingsManager;
  final bool collapsible;

  /// The collapsed state when nothing was saved yet (tablet: icon-only).
  final bool startCollapsed;

  @override
  State<_PersistedSidebar> createState() => _PersistedSidebarState();
}

class _PersistedSidebarState extends State<_PersistedSidebar> {
  late bool _collapsed = widget.startCollapsed;
  bool _restored = false;
  Set<String> _openSections = const {};

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final collapsed = widget.collapsible
        ? await widget.settingsManager.getSidebarCollapsedOrNull() ??
              widget.startCollapsed
        : widget.startCollapsed;
    final open = await widget.settingsManager.getSidebarOpenSections();
    if (!mounted) return;
    setState(() {
      _collapsed = collapsed;
      _openSections = open;
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
    onToggle: _restored && widget.collapsible ? _toggle : null,
    activePath: widget.activePath,
    onChildSelected: widget.onChildSelected,
    initialOpenSections: _openSections,
    onOpenSectionsChanged: (open) =>
        widget.settingsManager.setSidebarOpenSections(open),
  );
}

/// What the phone "More" sheet returns: a branch, and the child path when a
/// child of it was chosen.
class _MoreChoice {
  const _MoreChoice(this.branch, [this.path]);
  final int branch;
  final String? path;
}

/// The overflow destinations as a main/sub tree (children indented under
/// their parent with a connecting line).
class _MoreTree extends StatelessWidget {
  const _MoreTree({
    required this.destinations,
    required this.activePath,
    required this.activeBranch,
  });

  final List<AppDestination> destinations;
  final String? activePath;
  final int activeBranch;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md.of(context)),
      shrinkWrap: true,
      children: [
        for (final destination in destinations) ...[
          ListTile(
            selected:
                destination.branchIndex == activeBranch &&
                !destination.item.children.any(
                  (c) => AppSidebar.isChildActive(c, activePath),
                ),
            leading: AppIcon(destination.item.icon),
            title: AppText(destination.item.label),
            onTap: () => Navigator.of(
              context,
            ).pop(_MoreChoice(destination.branchIndex)),
          ),
          if (destination.item.children.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.xl.of(context),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    start: BorderSide(
                      color: colors.outlineVariant,
                      width: AppBorderWidth.thin.of(context),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    for (final child in destination.item.children)
                      ListTile(
                        selected: AppSidebar.isChildActive(child, activePath),
                        leading: AppIcon(child.icon),
                        title: AppText(child.label),
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_MoreChoice(destination.branchIndex, child.path)),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _ShellMobileNavigation extends StatefulWidget {
  const _ShellMobileNavigation({
    required this.items,
    required this.activeIndex,
    required this.onDestinationSelected,
    required this.moreIndex,
    required this.onMoreSelected,
  });

  final List<NavBarItem> items;
  final int activeIndex;
  final ValueChanged<int> onDestinationSelected;
  final int? moreIndex;
  final Future<void> Function() onMoreSelected;

  @override
  State<_ShellMobileNavigation> createState() => _ShellMobileNavigationState();
}

class _ShellMobileNavigationState extends State<_ShellMobileNavigation> {
  bool _moreSheetOpen = false;

  Future<void> _select(int index) async {
    if (widget.moreIndex == null || index != widget.moreIndex) {
      widget.onDestinationSelected(index);
      return;
    }
    if (_moreSheetOpen) return;
    setState(() => _moreSheetOpen = true);
    try {
      await widget.onMoreSelected();
    } finally {
      if (mounted) setState(() => _moreSheetOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppNavigationBar(
    items: widget.items,
    activeIndex: widget.activeIndex,
    onIndexChanged: _select,
    showLabelsAlways: false,
  );
}
