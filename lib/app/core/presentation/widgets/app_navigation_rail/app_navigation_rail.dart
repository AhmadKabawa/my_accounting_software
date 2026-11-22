import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/shell_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_rail/app_navigation_rail_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Vertical navigation for tablets: icon above a short label, on the start
/// side of the content. Takes the same [items] / [activeIndex] /
/// [onIndexChanged] as `AppNavigationBar` and `AppSidebar`.
///
/// Handles its own safe-area insets, so it can sit directly beside the content.
class AppNavigationRail extends StatelessWidget {
  final List<NavBarItem> items;
  final int activeIndex;
  final ValueChanged<int> onIndexChanged;

  /// Not null = a clear button at the top that expands the rail (the owner
  /// shows the labelled tree; the rail itself stays compact).
  final VoidCallback? onExpand;

  const AppNavigationRail({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onIndexChanged,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppNavigationRailStyle(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: style.background, border: style.border),
      child: SafeArea(
        child: SizedBox(
          width: style.width,
          child: Column(
            children: [
              if (onExpand != null)
                Padding(
                  padding: style.padding,
                  child: AppIconButton(
                    AppIcons.sidebarExpand,
                    tooltipKey: ShellKeys.expandSidebar,
                    onPressed: onExpand,
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: style.padding,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(height: style.itemGap),
                  itemBuilder: (context, index) => _RailItem(
                    item: items[index],
                    selected: index == activeIndex,
                    style: style,
                    onTap: () => onIndexChanged(index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final NavBarItem item;
  final bool selected;
  final AppNavigationRailStyle style;
  final VoidCallback onTap;

  const _RailItem({
    required this.item,
    required this.selected,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = style.itemForeground(selected: selected);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: style.itemBackground(selected: selected),
        borderRadius: style.itemRadius,
        child: InkWell(
          borderRadius: style.itemRadius,
          onTap: onTap,
          child: Padding(
            padding: style.itemPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon.fixed(
                  selected ? (item.activeIcon ?? item.icon) : item.icon,
                  pixelSize: style.iconSize,
                  color: color,
                ),
                SizedBox(height: style.iconLabelGap),
                AppText(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  type: AppTextType.labelSmall,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
