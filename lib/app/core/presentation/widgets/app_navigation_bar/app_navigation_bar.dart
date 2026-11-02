// ─────────────────────────────────────────────────────────────────
// app_navigation_bar.dart
// Navigation Bar احترافي مع:
//   - Multiple styles (Elegant, Glassmorphism, Pill, Minimal, Neon)
//   - Smooth animations
//   - Custom configurations
//   - ✅ دقيق جداً لتقدير عرض العنصر النشط
//
// كل القيم البصرية (أحجام، ألوان، ظلال، blur) في AppNavigationBarStyle
// (AppNavigationBarStyle)؛ هنا فقط الأنيميشن والـ scale والحالة.
// ─────────────────────────────────────────────────────────────────

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

export 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar_style.dart'
    show NavBarStyle;

/// نموذج بيانات للـ navigation item
class NavBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final AppKey label;
  final VoidCallback? onTap;

  const NavBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.onTap,
  });
}

// ═══════════════════════════════════════════════════════════════
// MAIN CUSTOM NAVIGATION BAR
// ═══════════════════════════════════════════════════════════════

class AppNavigationBar extends StatefulWidget {
  final List<NavBarItem> items;
  final int activeIndex;
  final ValueChanged<int> onIndexChanged;
  final NavBarStyle style;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? maxItemSize;
  final double? maxWidthActiveItemSize;
  final bool showLabelsAlways;
  final bool deleteLabelsAlways;
  final double? borderRadius;

  /// null = the default elevation of the style.
  final double? elevation;

  const AppNavigationBar({
    Key? key,
    required this.items,
    required this.activeIndex,
    required this.onIndexChanged,
    this.style = NavBarStyle.elegant,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.showLabelsAlways = false,
    this.deleteLabelsAlways = false,
    this.borderRadius,
    this.maxItemSize,
    this.maxWidthActiveItemSize,
    this.elevation,
  }) : assert(items.length > 0),
       super(key: key);

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final variant = AppNavigationBarStyle(context).variant(
      widget.style,
      backgroundColor: widget.backgroundColor,
      activeColor: widget.activeColor,
      borderRadius: widget.borderRadius,
      elevation: widget.elevation,
    );

    Widget result = Container(
      margin: variant.margin,
      padding: variant.padding,
      decoration: BoxDecoration(
        borderRadius: variant.radius,
        color: variant.background,
        gradient: variant.gradient,
        border: variant.border,
        boxShadow: variant.shadows,
      ),
      child: _buildItemsRow(),
    );

    final blur = variant.blur;
    if (blur != null) {
      result = ClipRRect(
        borderRadius: variant.radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: result,
        ),
      );
    }

    return result;
  }

  /// بناء صف الـ items
  Widget _buildItemsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final styles = AppNavigationBarStyle(context);
        final count = widget.items.length;
        final availableWidth = constraints.maxWidth;

        // الأبعاد (مع القيم الافتراضية من AppNavigationBarStyle)
        final circleSize = widget.maxItemSize ?? styles.defaultMaxItemSize;
        final activeItemWidth =
            widget.maxWidthActiveItemSize ?? styles.defaultActiveItemWidth;

        // ═══════════════════════════════════════════════════════════
        // حساب الـ scale بطريقة بسيطة (بدل Binary Search)
        // ═══════════════════════════════════════════════════════════
        // المعادلة: (n-1) * circleSize + activeItemWidth = total needed
        final totalNeeded = ((count - 1) * circleSize) + activeItemWidth;
        final scale = totalNeeded > availableWidth
            ? availableWidth / totalNeeded
            : 1.0;

        final scaledCircleSize = circleSize * scale;
        final scaledActiveWidth = activeItemWidth * scale;

        // حساب الـ gaps
        final totalUsed = ((count - 1) * scaledCircleSize) + scaledActiveWidth;
        final remainingSpace = availableWidth - totalUsed;
        final gap = (remainingSpace / (count + 1)).clamp(
          styles.minGap,
          styles.maxGap,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            final isActive = index == widget.activeIndex;
            final isLast = index == count - 1;

            return Padding(
              padding: EdgeInsetsDirectional.only(end: isLast ? 0 : gap),
              child: NavBarItemWidget(
                item: widget.items[index],
                isActive: isActive,
                style: widget.style,
                activeColor: widget.activeColor,
                inactiveColor: widget.inactiveColor,
                showLabel:
                    (widget.showLabelsAlways || isActive) &&
                    !widget.deleteLabelsAlways,
                itemHeight: scaledCircleSize,
                activeItemWidth: scaledActiveWidth,
                onTap: () => widget.onIndexChanged(index),
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NAVIGATION ITEM WIDGET
// ═══════════════════════════════════════════════════════════════

class NavBarItemWidget extends StatefulWidget {
  final NavBarItem item;
  final bool isActive;
  final NavBarStyle style;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showLabel;
  final double itemHeight;
  final double activeItemWidth;
  final VoidCallback onTap;

  const NavBarItemWidget({
    Key? key,
    required this.item,
    required this.isActive,
    required this.style,
    this.activeColor,
    this.inactiveColor,
    required this.showLabel,
    required this.itemHeight,
    required this.activeItemWidth,
    required this.onTap,
  }) : super(key: key);

  @override
  State<NavBarItemWidget> createState() => _NavBarItemWidgetState();
}

class _NavBarItemWidgetState extends State<NavBarItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _labelFadeAnim;
  late Animation<double> _labelWidthAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );

    _scaleAnim = Tween<double>(
      begin: AppNavigationBarStyle.iconScaleBegin,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _labelFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _labelWidthAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    if (widget.isActive) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(NavBarItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styles = AppNavigationBarStyle(context);
    final activeColor = widget.activeColor ?? styles.activeColor;
    final onActiveColor = styles.onActiveColor;
    final inactiveColor = widget.inactiveColor ?? styles.inactiveColor;
    final onInactiveColor = styles.onInactiveColor;
    final height = widget.itemHeight;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            height: height,
            width: widget.showLabel ? widget.activeItemWidth : height,
            decoration: BoxDecoration(
              borderRadius: styles.itemRadius(height),
              color: widget.isActive ? activeColor : inactiveColor,
              boxShadow: widget.isActive
                  ? styles.activeItemShadow(activeColor)
                  : null,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final inset = styles.itemInset(constraints.maxHeight);
                final iconSize = styles.itemIconSize(constraints.maxHeight);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: inset),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Icon(
                          widget.isActive
                              ? (widget.item.activeIcon ?? widget.item.icon)
                              : widget.item.icon,
                          size: iconSize,
                          color: widget.isActive
                              ? onActiveColor
                              : onInactiveColor,
                        ),
                      ),
                      if (widget.showLabel) ...[
                        Flexible(
                          child: ClipRect(
                            child: SizeTransition(
                              sizeFactor: _labelWidthAnim,
                              axis: Axis.horizontal,
                              child: FadeTransition(
                                opacity: _labelFadeAnim,
                                child: Center(
                                  child: AppText(
                                    widget.item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    type: AppTextType.labelMedium,
                                    color: widget.isActive
                                        ? onActiveColor
                                        : onInactiveColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
