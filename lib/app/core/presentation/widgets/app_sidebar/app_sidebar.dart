import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/shell_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Expanded desktop navigation, optionally reduced to an icon rail.
class AppSidebar extends StatelessWidget {
  final List<NavBarItem> items;
  final int activeIndex;
  final ValueChanged<int> onIndexChanged;
  final bool collapsed;
  final VoidCallback? onToggle;

  /// Current route path; highlights the matching [NavBarChild].
  final String? activePath;

  /// Called with a child's path; the owner navigates.
  final ValueChanged<String>? onChildSelected;

  const AppSidebar({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onIndexChanged,
    this.collapsed = false,
    this.onToggle,
    this.activePath,
    this.onChildSelected,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppSidebarStyle(context, collapsed: collapsed);

    return DecoratedBox(
      decoration: BoxDecoration(color: style.background, border: style.border),
      child: SafeArea(
        child: SizedBox(
          width: style.width,
          child: Column(
            children: [
              if (onToggle != null)
                Padding(
                  padding: style.togglePadding,
                  child: Align(
                    alignment: collapsed
                        ? AlignmentDirectional.center
                        : AlignmentDirectional.centerEnd,
                    child: AppIconButton(
                      collapsed
                          ? AppIcons.sidebarExpand
                          : AppIcons.sidebarCollapse,
                      tooltipKey: collapsed
                          ? ShellKeys.expandSidebar
                          : ShellKeys.collapseSidebar,
                      onPressed: onToggle,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: style.padding,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(height: style.itemGap),
                  itemBuilder: (context, index) {
                    final selected = index == activeIndex;
                    final children = items[index].children;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SidebarItem(
                          item: items[index],
                          selected: selected,
                          style: style,
                          collapsed: collapsed,
                          onTap: () => onIndexChanged(index),
                        ),
                        if (selected && !collapsed)
                          for (final child in children)
                            Padding(
                              padding: EdgeInsetsDirectional.only(
                                top: style.itemGap,
                                start: style.childIndent,
                              ),
                              child: _SidebarChild(
                                child: child,
                                selected: activePath == child.path,
                                style: style,
                                onTap: () => onChildSelected?.call(child.path),
                              ),
                            ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final NavBarItem item;
  final bool selected;
  final AppSidebarStyle style;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.style,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = style.itemForeground(selected: selected);
    final label = item.label.tr(context: context);
    final icon = AppIcon.fixed(
      selected ? (item.activeIcon ?? item.icon) : item.icon,
      pixelSize: style.iconSize,
      color: color,
    );

    return Semantics(
      label: label,
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
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: style.itemMinHeight),
              child: Padding(
                padding: style.itemPadding,
                child: collapsed
                    ? Tooltip(
                        message: label,
                        child: Center(child: icon),
                      )
                    : Row(
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
