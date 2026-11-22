import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/shell_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/tokens/app_motion.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:flutter/rendering.dart';

/// Desktop navigation as a tree, optionally reduced to an icon rail.
///
/// * Each item with [NavBarItem.children] is a section: it opens and closes on
///   its own with a chevron; the others are not touched. The chevron only
///   toggles; tapping the row also opens its destination.
/// * Children are indented under a connecting line. The active child gets the
///   filled pill and its parent only the brand color (the selected item and
///   its ancestor are both visible, never two fills).
/// * The section of the selected destination or active child opens by itself.
/// * Open sections are reported through [onOpenSectionsChanged] (the owner
///   persists them) and restored from [initialOpenSections].
/// * Accordion: one section open at a time. One tap on a parent opens or
///   closes its list (it never leaves the page); a double tap opens the
///   parent's own page. A page without sub-items closes every list.
/// * [collapsed] (icons only): a tooltip names each item; the children of the
///   open section show as smaller icons under their parent.
/// * The owner filters items by permission before passing them.
class AppSidebar extends StatefulWidget {
  final List<NavBarItem> items;
  final int activeIndex;
  final ValueChanged<int> onIndexChanged;
  final bool collapsed;
  final VoidCallback? onToggle;

  /// Current route path; highlights the matching [NavBarChild].
  final String? activePath;

  /// Called with a child's path; the owner navigates.
  final ValueChanged<String>? onChildSelected;

  /// Section ids (see [sectionId]) to open at first, e.g. restored from
  /// storage.
  final Set<String> initialOpenSections;

  /// Called with the full set of open sections whenever the user changes it.
  final ValueChanged<Set<String>>? onOpenSectionsChanged;

  const AppSidebar({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onIndexChanged,
    this.collapsed = false,
    this.onToggle,
    this.activePath,
    this.onChildSelected,
    this.initialOpenSections = const {},
    this.onOpenSectionsChanged,
  });

  /// The stable id of a section: its label key.
  static String sectionId(NavBarItem item) => item.label.key;

  /// True when [path] is the child's page or one beneath it.
  static bool isChildActive(NavBarChild child, String? path) =>
      path != null && (path == child.path || path.startsWith('${child.path}/'));

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  /// At most one open section (an accordion): opening one closes the others.
  final Set<String> _open = {};
  bool _interacted = false;

  @override
  void initState() {
    super.initState();
    _syncToRoute(notify: false);
    if (_open.isEmpty && widget.initialOpenSections.isNotEmpty) {
      _open.add(widget.initialOpenSections.first);
    }
  }

  @override
  void didUpdateWidget(AppSidebar old) {
    super.didUpdateWidget(old);
    if (old.activeIndex != widget.activeIndex ||
        old.activePath != widget.activePath) {
      // Going to another page: its section opens, every other one closes
      // (a page without sub-items closes them all).
      _syncToRoute();
    } else if (old.initialOpenSections != widget.initialOpenSections &&
        !_interacted &&
        _open.isEmpty &&
        widget.initialOpenSections.isNotEmpty) {
      // Storage answered late: restore once, never over the user's choice.
      _open.add(widget.initialOpenSections.first);
    }
  }

  /// Opens only the section that holds the current page (if any).
  void _syncToRoute({bool notify = true}) {
    String? id;
    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      if (item.children.isEmpty) continue;
      final hasActiveChild = item.children.any(
        (c) => AppSidebar.isChildActive(c, widget.activePath),
      );
      if (i == widget.activeIndex || hasActiveChild)
        id = AppSidebar.sectionId(item);
    }
    _setOpen(id, notify: notify);
  }

  void _setOpen(String? id, {bool notify = true}) {
    final next = id == null ? <String>{} : {id};
    if (next.length == _open.length && _open.containsAll(next)) return;
    _open
      ..clear()
      ..addAll(next);
    if (notify) widget.onOpenSectionsChanged?.call({..._open});
  }

  /// A tap on a parent: opens its list, or closes it when already open.
  void _toggle(NavBarItem item) {
    final id = AppSidebar.sectionId(item);
    _interacted = true;
    setState(() => _setOpen(_open.contains(id) ? null : id));
  }

  /// A tap on a page without sub-items: every list closes.
  void _closeAll() {
    _interacted = true;
    setState(() => _setOpen(null));
  }

  @override
  Widget build(BuildContext context) {
    final style = AppSidebarStyle(context, collapsed: widget.collapsed);

    return DecoratedBox(
      decoration: BoxDecoration(color: style.background, border: style.border),
      child: SafeArea(
        child: SizedBox(
          width: style.width,
          child: Column(
            children: [
              if (widget.onToggle != null)
                Padding(
                  padding: style.togglePadding,
                  child: Align(
                    alignment: widget.collapsed
                        ? AlignmentDirectional.center
                        : AlignmentDirectional.centerEnd,
                    child: AppIconButton(
                      widget.collapsed
                          ? AppIcons.sidebarExpand
                          : AppIcons.sidebarCollapse,
                      tooltipKey: widget.collapsed
                          ? ShellKeys.expandSidebar
                          : ShellKeys.collapseSidebar,
                      onPressed: widget.onToggle,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: style.padding,
                  itemCount: widget.items.length,
                  separatorBuilder: (_, _) => SizedBox(height: style.itemGap),
                  itemBuilder: (context, index) =>
                      _section(context, style, index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, AppSidebarStyle style, int index) {
    final item = widget.items[index];
    final children = item.children;
    final isCurrent = index == widget.activeIndex;
    final activeChild = isCurrent || children.isNotEmpty
        ? children.any((c) => AppSidebar.isChildActive(c, widget.activePath))
        : false;
    // The item is "selected" (filled) only when no child of it is active.
    final selected = isCurrent && !activeChild;
    final ancestor = activeChild;
    final open = _open.contains(AppSidebar.sectionId(item));

    final row = _SidebarItem(
      item: item,
      selected: selected,
      ancestor: ancestor,
      style: style,
      collapsed: widget.collapsed,
      open: children.isEmpty ? null : open,
      // A parent with sub-items: one tap opens/closes its list and never
      // leaves the page; a double tap goes to the parent's own page.
      onTap: () {
        if (children.isEmpty) {
          _closeAll();
          widget.onIndexChanged(index);
        } else {
          _toggle(item);
        }
      },
      onDoubleTap: children.isEmpty
          ? null
          : () {
              _interacted = true;
              setState(() => _setOpen(AppSidebar.sectionId(item)));
              widget.onIndexChanged(index);
            },
      onToggle: children.isEmpty ? null : () => _toggle(item),
    );

    if (widget.collapsed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row,
          if (open && children.isNotEmpty)
            _CollapsedChildren(
              children: children,
              activePath: widget.activePath,
              style: style,
              onChild: (path) {
                _interacted = true;
                setState(() => _setOpen(AppSidebar.sectionId(item)));
                widget.onChildSelected?.call(path);
              },
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        AnimatedSize(
          duration: AppMotion.duration(context, AppMotionDuration.fast),
          alignment: AlignmentDirectional.topStart,
          child: open && children.isNotEmpty
              ? Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: style.itemGap,
                    start: style.childIndent,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(
                          color: style.line,
                          width: style.lineWidth,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: style.childLineGap,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final child in children) ...[
                            _SidebarChild(
                              child: child,
                              selected: AppSidebar.isChildActive(
                                child,
                                widget.activePath,
                              ),
                              style: style,
                              onTap: () {
                                _interacted = true;
                                setState(
                                  () => _setOpen(AppSidebar.sectionId(item)),
                                );
                                widget.onChildSelected?.call(child.path);
                              },
                            ),
                            if (child != children.last)
                              SizedBox(height: style.itemGap),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final NavBarItem item;
  final bool selected;
  final bool ancestor;
  final AppSidebarStyle style;
  final bool collapsed;

  /// null = no children (no chevron).
  final bool? open;
  final VoidCallback onTap;

  /// Items with sub-items: the second tap of a double tap (opens the page).
  final VoidCallback? onDoubleTap;
  final VoidCallback? onToggle;

  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.ancestor,
    required this.style,
    required this.collapsed,
    required this.open,
    required this.onTap,
    required this.onDoubleTap,
    required this.onToggle,
  });

  /// Screen readers cannot double tap the row: give them an explicit action.
  Map<CustomSemanticsAction, VoidCallback>? _openPageAction(
    BuildContext context,
  ) => onDoubleTap == null
      ? null
      : {
          CustomSemanticsAction(label: ShellKeys.openPage.tr(context: context)):
              onDoubleTap!,
        };

  @override
  Widget build(BuildContext context) {
    final color = style.itemForeground(selected: selected, ancestor: ancestor);
    final label = item.label.tr(context: context);
    final highlighted = selected || ancestor;
    final icon = AppIcon.fixed(
      highlighted ? (item.activeIcon ?? item.icon) : item.icon,
      pixelSize: style.iconSize,
      color: color,
    );

    if (collapsed) {
      final side = style.itemMinHeight;
      return Semantics(
        label: label,
        button: true,
        selected: selected || ancestor,
        onTap: onTap,
        customSemanticsActions: _openPageAction(context),
        child: ExcludeSemantics(
          child: Center(
            child: Tooltip(
              message: label,
              child: SizedBox(
                width: side,
                height: side,
                child: Material(
                  color: style.itemBackground(selected: selected),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onTap,
                    onDoubleTap: onDoubleTap,
                    child: Center(child: icon),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: label,
      button: true,
      selected: selected || ancestor,
      expanded: open,
      onTap: onTap,
      customSemanticsActions: _openPageAction(context),
      child: ExcludeSemantics(
        child: Material(
          color: style.itemBackground(selected: selected),
          borderRadius: style.itemRadius,
          child: InkWell(
            borderRadius: style.itemRadius,
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: style.itemMinHeight),
              child: Padding(
                padding: style.itemPadding,
                child: Row(
                  children: [
                    icon,
                    SizedBox(width: style.iconLabelGap),
                    Expanded(
                      child: AppText(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        type: AppTextType.labelLarge,
                        color: color,
                      ),
                    ),
                    if (onToggle != null)
                      Tooltip(
                        message:
                            (open!
                                    ? ShellKeys.collapseSection
                                    : ShellKeys.expandSection)
                                .tr(context: context),
                        child: Semantics(
                          button: true,
                          expanded: open,
                          label: label,
                          child: InkWell(
                            borderRadius: style.itemRadius,
                            onTap: onToggle,
                            child: Padding(
                              padding: style.chevronPadding,
                              child: AppIcon.fixed(
                                open! ? AppIcons.collapse : AppIcons.expand,
                                pixelSize: style.chevronSize,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon-only mode: the sub-items of an open section as smaller icons inside
/// one soft capsule right under their parent, so they read as its children.
class _CollapsedChildren extends StatelessWidget {
  const _CollapsedChildren({
    required this.children,
    required this.activePath,
    required this.style,
    required this.onChild,
  });

  final List<NavBarChild> children;
  final String? activePath;
  final AppSidebarStyle style;
  final ValueChanged<String> onChild;

  @override
  Widget build(BuildContext context) {
    final side = style.itemMinHeight;
    return Padding(
      padding: EdgeInsets.only(top: style.itemGap),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.ui.theme.saasColors.tableHeaderBand,
            borderRadius: style.itemRadius,
          ),
          child: Padding(
            padding: style.togglePadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final child in children) ...[
                  Builder(
                    builder: (context) {
                      final selected = AppSidebar.isChildActive(
                        child,
                        activePath,
                      );
                      final label = child.label.tr(context: context);
                      return Semantics(
                        label: label,
                        button: true,
                        selected: selected,
                        excludeSemantics: true,
                        onTap: () => onChild(child.path),
                        child: Tooltip(
                          message: label,
                          child: SizedBox.square(
                            dimension: side,
                            child: Material(
                              color: style.itemBackground(selected: selected),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => onChild(child.path),
                                child: Center(
                                  child: AppIcon.fixed(
                                    child.icon,
                                    pixelSize: style.childIconSize,
                                    color: style.itemForeground(
                                      selected: selected,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (child != children.last) SizedBox(height: style.itemGap),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarChild extends StatelessWidget {
  const _SidebarChild({
    required this.child,
    required this.selected,
    required this.style,
    required this.onTap,
  });

  final NavBarChild child;
  final bool selected;
  final AppSidebarStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = style.itemForeground(selected: selected);
    return Semantics(
      label: child.label.tr(context: context),
      button: true,
      selected: selected,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: style.itemBackground(selected: selected),
          borderRadius: style.itemRadius,
          child: InkWell(
            borderRadius: style.itemRadius,
            onTap: onTap,
            child: Padding(
              padding: style.itemPadding,
              child: Row(
                children: [
                  AppIcon.fixed(
                    child.icon,
                    pixelSize: style.childIconSize,
                    color: color,
                  ),
                  SizedBox(width: style.iconLabelGap),
                  Expanded(
                    child: AppText(
                      child.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      type: AppTextType.labelMedium,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
