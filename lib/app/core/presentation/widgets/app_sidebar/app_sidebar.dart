import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Expanded vertical navigation for desktops: icon and full label per row, on
/// the start side of the content. Takes the same [items] / [activeIndex] /
/// [onIndexChanged] as `AppNavigationBar` and `AppNavigationRail`.
///
/// Handles its own safe-area insets, so it can sit directly beside the content.
class AppSidebar extends StatelessWidget {
  final List<NavBarItem> items;
  final int activeIndex;
  final ValueChanged<int> onIndexChanged;

  const AppSidebar({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppSidebarStyle(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: style.background, border: style.border),
      child: SafeArea(
        child: SizedBox(
          width: style.width,
          child: ListView.separated(
            padding: style.padding,
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: style.itemGap),
            itemBuilder: (context, index) => _SidebarItem(
              item: items[index],
              selected: index == activeIndex,
              style: style,
              onTap: () => onIndexChanged(index),
            ),
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
  final VoidCallback onTap;

  const _SidebarItem({
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
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: style.itemMinHeight),
            child: Padding(
              padding: style.itemPadding,
              child: Row(
                children: [
                  Icon(
                    selected ? (item.activeIcon ?? item.icon) : item.icon,
                    size: style.iconSize,
                    color: color,
                  ),
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
    );
  }
}
