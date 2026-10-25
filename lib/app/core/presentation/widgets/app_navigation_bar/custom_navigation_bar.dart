// ─────────────────────────────────────────────────────────────────
// custom_navigation_bar.dart (FIXED)
// Navigation Bar احترافي مع:
//   - Responsive scaling
//   - Multiple styles (Elegant, Glassmorphism, Pill)
//   - Smooth animations
//   - Custom configurations
//   - ✅ دقيق جداً لتقدير عرض العنصر النشط
// ─────────────────────────────────────────────────────────────────

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/responsive/helper/responsive_helper.dart';
import 'package:accounting_software/app/core/presentation/styles/styles_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

// ═══════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════

enum NavBarStyle { elegant, glassmorphism, pill, minimal, neon }

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
// STYLE CONFIG CLASS - كل الـ styling في مكان واحد
// ═══════════════════════════════════════════════════════════════

class _StyleConfig {
  final BorderRadius radius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color backgroundColor;
  final Border? border;
  final List<BoxShadow> shadows;
  final Gradient? gradient;

  const _StyleConfig({
    required this.radius,
    required this.padding,
    required this.margin,
    required this.backgroundColor,
    this.border,
    required this.shadows,
    this.gradient,
  });

  Widget build(BuildContext context, Widget child) {
    Widget result = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: backgroundColor,
        gradient: gradient,
        border: border,
        boxShadow: shadows,
      ),
      child: child,
    );

    // للـ glassmorphism فقط
    if (gradient == null && backgroundColor.alpha < 200) {
      result = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: result,
        ),
      );
    }

    return result;
  }
}

// ═══════════════════════════════════════════════════════════════
// MAIN CUSTOM NAVIGATION BAR
// ═══════════════════════════════════════════════════════════════

class CustomNavigationBar extends StatefulWidget {
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
  final double elevation;

  const CustomNavigationBar({
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
    this.elevation = 8.0,
  }) : assert(items.length > 0),
       super(key: key);

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  /// الحصول على الحجم الافتراضي من Rh
  double _getDefaultMaxItemSize(BuildContext context) {
    return context.uiStyles.navbar.defaultMaxItemSize;
  }

  /// الحصول على عرض العنصر النشط الافتراضي
  double _getDefaultActiveItemWidth(BuildContext context) {
    return _getDefaultMaxItemSize(context) * 2;
  }

  /// الحصول على Border Radius الافتراضي
  BorderRadius _getDefaultRadius(BuildContext context) {
    final radiusSize = widget.borderRadius != null
        ? BorderRadius.circular(widget.borderRadius!)
        : context.uiStyles.navbar.radius;
    return radiusSize;
  }

  /// الحصول على spacing الافتراضي
  double _getDefaultSpacing(BuildContext context) {
    return context.uiStyles.navbar.spacing;
  }

  /// إنشاء configuration حسب الـ style
  _StyleConfig _buildConfig(BuildContext context) {
    final spacing = _getDefaultSpacing(context);
    final radius = _getDefaultRadius(context);
    final margin = EdgeInsets.all(spacing);
    final styles = context.uiStyles.navbar;

    switch (widget.style) {
      case NavBarStyle.elegant:
        return _StyleConfig(
          radius: radius,
          padding: const EdgeInsets.all(8),
          margin: margin,
          backgroundColor: widget.backgroundColor ?? styles.background,
          border: Border.all(color: styles.borderColor, width: 1),
          shadows: [
            BoxShadow(
              color: styles.shadowColor,
              blurRadius: widget.elevation,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case NavBarStyle.glassmorphism:
        return _StyleConfig(
          radius: radius,
          padding: Rh.allPadding(context, AppSpacing.sm),
          margin: margin,
          backgroundColor: styles.glassBackground,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          shadows: [
            BoxShadow(
              color: styles.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        );

      case NavBarStyle.pill:
        final primaryColor = widget.activeColor ?? styles.activeColor;
        return _StyleConfig(
          radius: radius,
          padding: styles.padding,
          margin: margin,
          backgroundColor: Colors.transparent,
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.8), primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadows: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        );

      case NavBarStyle.minimal:
        return _StyleConfig(
          radius: BorderRadius.zero,
          padding: styles.padding,
          margin: margin,
          backgroundColor: Colors.transparent,
          border: Border(
            top: BorderSide(color: styles.borderColor, width: 0.5),
          ),
          shadows: [],
        );

      case NavBarStyle.neon:
        final neonColor = widget.activeColor ?? styles.neonColor;
        return _StyleConfig(
          radius: radius,
          padding: styles.padding,
          margin: margin,
          backgroundColor: styles.background,
          border: Border.all(color: neonColor, width: 1.5),
          shadows: [
            BoxShadow(
              color: neonColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _buildConfig(context);
    return config.build(context, _buildItemsRow(context));
  }

  /// بناء صف الـ items
  Widget _buildItemsRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = widget.items.length;
        final availableWidth = constraints.maxWidth;

        // الحصول على الأبعاد (مع القيم الافتراضية من Rh)
        final circleSize =
            widget.maxItemSize ?? _getDefaultMaxItemSize(context);
        final activeItemWidth =
            widget.maxWidthActiveItemSize ??
            _getDefaultActiveItemWidth(context);

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
        final gap = (remainingSpace / (count + 1)).clamp(4.0, 12.0);

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
      begin: 0.9,
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
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final onActiveColor = theme.colorScheme.onPrimary;
    final inactiveColor =
        widget.inactiveColor ?? theme.colorScheme.surfaceContainerHighest;
    final onInactiveColor = theme.colorScheme.onSurfaceVariant;
    final hight = widget.itemHeight;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            height: hight,
            width: widget.showLabel ? widget.activeItemWidth : hight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(hight / 2),
              color: widget.isActive ? activeColor : inactiveColor,
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final padding = constraints.maxHeight * 0.15;
                final iconSize = constraints.maxHeight - (padding * 3);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
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
                        // SizedBox(width: padding * 0.5),
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

/*
// ═══════════════════════════════════════════════════════════════
// ENUMS
// // ═══════════════════════════════════════════════════════════════

// enum NavBarStyle {
//   /// الـ style الكلاسيكي (مثل الصورة)
//   elegant,

//   /// Glassmorphism - تأثير زجاج مع blur
//   glassmorphism,

//   /// Pill - شكل حبة دواء منتفخة
//   pill,

//   /// Minimal - بسيط جداً بدون خلفية
//   minimal,

//   /// Neon - ألوان مضيئة مع glow
//   neon,
// }

// /// نموذج بيانات للـ navigation item
// class NavBarItem {
//   final IconData icon;
//   final IconData? activeIcon;
//   final AppKey label;
//   final VoidCallback? onTap;

//   const NavBarItem({
//     required this.icon,
//     this.activeIcon,
//     required this.label,
//     this.onTap,
//   });
// }

// // ═══════════════════════════════════════════════════════════════
// // MAIN CUSTOM NAVIGATION BAR
// // ═══════════════════════════════════════════════════════════════

// class CustomNavigationBar extends StatefulWidget {
//   /// قائمة الـ items
//   final List<NavBarItem> items;

//   /// الـ index النشط
//   final int activeIndex;

//   /// callback عند تغيير الـ tab
//   final ValueChanged<int> onIndexChanged;

//   /// الـ style المفضل
//   final NavBarStyle style;

//   /// اللون الأساسي للـ navbar
//   final Color? backgroundColor;

//   /// لون الـ item النشط
//   final Color? activeColor;

//   /// لون الـ item غير النشط
//   final Color? inactiveColor;

//   /// الحجم الأقصى لكل عنصر (قبل التصغير التلقائي)
//   final double? maxItemSize;

//   /// الحجم الأقصى   عنصر المحدد (قبل التصغير التلقائي)
//   final double? maxWidthActiveItemSize;

//   /// إظهار الـ labels دائماً أم فقط للـ item النشط؟
//   final bool showLabelsAlways;
//   final bool deleteLabelsAlways;

//   /// border radius للـ navbar
//   final double? borderRadius;

//   /// هل نستخدم الـ floating behavior؟
//   final bool isFloating;

//   /// elevation/shadow
//   final double elevation;

//   const CustomNavigationBar({
//     Key? key,
//     required this.items,
//     required this.activeIndex,
//     required this.onIndexChanged,
//     this.style = NavBarStyle.elegant,
//     this.backgroundColor,
//     this.activeColor,
//     this.inactiveColor,
//     this.showLabelsAlways = false,
//     this.deleteLabelsAlways = false,
//     this.borderRadius,
//     this.isFloating = true,
//     this.maxItemSize = 56.0,
//     this.maxWidthActiveItemSize = 160.0,
//     this.elevation = 8.0,
//   }) : assert(items.length > 0),

//        super(key: key);

//   @override
//   State<CustomNavigationBar> createState() => _CustomNavigationBarState();
// }

// class _CustomNavigationBarState extends State<CustomNavigationBar>
//     with SingleTickerProviderStateMixin {
//   @override
//   Widget build(BuildContext context) {
//     return switch (widget.style) {
//       NavBarStyle.elegant => _buildElegant(context),
//       NavBarStyle.glassmorphism => _buildGlassmorphism(context),
//       NavBarStyle.pill => _buildPill(context),
//       NavBarStyle.minimal => _buildMinimal(context),
//       NavBarStyle.neon => _buildNeon(context),
//     };
//   }

//   // ───────────────────────────────────────────────────────────────
//   // ELEGANT STYLE (مثل الصورة تماماً)
//   // ───────────────────────────────────────────────────────────────

//   Widget _buildElegant(BuildContext context) {
//     final spacing = Rh.spacing(
//       context,
//       mobile: AppSpacingConfig(size: AppSpacing.md),
//     );

//     final padding = EdgeInsets.all(8);

//     final radius = Rh.radius(
//       context,
//       mobile: AppRadiusConfig(size: AppRadius.full),
//     );

//     return Container(
//       margin: EdgeInsets.all(spacing),
//       padding: padding,
//       decoration: BoxDecoration(
//         borderRadius: radius,
//         color:
//             widget.backgroundColor ??
//             Theme.of(context).colorScheme.surfaceContainer,
//         border: Border.all(
//           color: Theme.of(context).colorScheme.outlineVariant,
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Theme.of(context).colorScheme.shadow.withOpacity(0.12),
//             blurRadius: widget.elevation,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: _buildItemsRow(),
//     );
//   }

//   // ───────────────────────────────────────────────────────────────
//   // GLASSMORPHISM STYLE
//   // ───────────────────────────────────────────────────────────────

//   Widget _buildGlassmorphism(BuildContext context) {
//     final spacing = Rh.spacing(
//       context,
//       mobile: AppSpacingConfig(size: AppSpacing.md),
//       tablet: AppSpacingConfig(size: AppSpacing.lg),
//     );

//     final padding = Rh.padding(
//       context,
//       mobile: AppPaddingConfig(all: AppSpacing.sm),
//       tablet: AppPaddingConfig(all: AppSpacing.md),
//     );

//     final radius = Rh.radius(
//       context,
//       mobile: AppRadiusConfig(size: AppRadius.full),
//       tablet: AppRadiusConfig(size: AppRadius.full),
//     );

//     return ClipRRect(
//       borderRadius: radius,
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           margin: EdgeInsets.all(spacing),
//           padding: padding,
//           decoration: BoxDecoration(
//             borderRadius: radius,
//             color: Theme.of(
//               context,
//             ).colorScheme.surfaceContainer.withOpacity(0.7),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.3),
//               width: 1.5,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Theme.of(context).colorScheme.outlineVariant,
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: _buildItemsRow(),
//         ),
//       ),
//     );
//   }

//   // ───────────────────────────────────────────────────────────────
//   // PILL STYLE
//   // ───────────────────────────────────────────────────────────────

//   Widget _buildPill(BuildContext context) {
//     final spacing = Rh.spacing(
//       context,
//       mobile: AppSpacingConfig(size: AppSpacing.md),
//       tablet: AppSpacingConfig(size: AppSpacing.lg),
//     );
//     final padding = Rh.padding(
//       context,
//       mobile: AppPaddingConfig.symmetric(h: AppSpacing.lg, v: AppSpacing.md),
//       tablet: AppPaddingConfig.symmetric(h: AppSpacing.xl, v: AppSpacing.lg),
//     );

//     final radius = Rh.radius(
//       context,
//       mobile: AppRadiusConfig(size: AppRadius.xl),
//       tablet: AppRadiusConfig(size: AppRadius.xxl),
//     );

//     return Container(
//       margin: EdgeInsets.all(spacing),
//       padding: padding,
//       decoration: BoxDecoration(
//         borderRadius: radius,
//         gradient: LinearGradient(
//           colors: [
//             Theme.of(context).colorScheme.primary.withOpacity(0.8),
//             Theme.of(context).colorScheme.primaryContainer,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: _buildItemsRow(),
//     );
//   }

//   // ───────────────────────────────────────────────────────────────
//   // MINIMAL STYLE
//   // ───────────────────────────────────────────────────────────────

//   Widget _buildMinimal(BuildContext context) {
//     final spacing = Rh.spacing(
//       context,
//       mobile: AppSpacingConfig(size: AppSpacing.sm),
//       tablet: AppSpacingConfig(size: AppSpacing.md),
//     );

//     final padding = Rh.padding(
//       context,
//       mobile: AppPaddingConfig(all: AppSpacing.xs),
//       tablet: AppPaddingConfig(all: AppSpacing.sm),
//     );

//     return Container(
//       margin: EdgeInsets.all(spacing),
//       padding: padding,
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(
//             color: Theme.of(context).colorScheme.outlineVariant,
//             width: 0.5,
//           ),
//         ),
//       ),
//       child: _buildItemsRow(),
//     );
//   }

//   // ───────────────────────────────────────────────────────────────
//   // NEON STYLE
//   // ───────────────────────────────────────────────────────────────

//   Widget _buildNeon(BuildContext context) {
//     final spacing = Rh.spacing(
//       context,
//       mobile: AppSpacingConfig(size: AppSpacing.md),
//       tablet: AppSpacingConfig(size: AppSpacing.lg),
//     );

//     final padding = Rh.padding(
//       context,
//       mobile: AppPaddingConfig(all: AppSpacing.sm),
//       tablet: AppPaddingConfig(all: AppSpacing.md),
//     );

//     final radius = Rh.radius(
//       context,
//       mobile: AppRadiusConfig(size: AppRadius.lg),
//       tablet: AppRadiusConfig(size: AppRadius.xl),
//     );

//     final neonColor =
//         widget.activeColor ?? Theme.of(context).colorScheme.tertiary;
//     return Container(
//       margin: EdgeInsets.all(spacing),
//       padding: padding,
//       decoration: BoxDecoration(
//         borderRadius: radius,
//         color: Theme.of(context).colorScheme.inverseSurface,
//         border: Border.all(color: neonColor, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: neonColor.withOpacity(0.4),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: _buildItemsRow(),
//     );
//   }

//   Widget _buildItemsRow() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final count = widget.items.length;
//         final availableW = constraints.maxWidth;
//         final availableH = constraints.maxHeight;

//         // =============================================================
//         // 1️⃣ الحجم الأساسي
//         // =============================================================
//         double baseCircleSize = availableH.clamp(28.0, widget.maxItemSize);

//         double baseActiveWidth = widget.maxWidthActiveItemSize;

//         // =============================================================
//         // 2️⃣ حساب العرض الكلي
//         // =============================================================
//         double calculateTotalWidth(double circleSize, double activeWidth) {
//           return ((count - 1) * circleSize) + activeWidth;
//         }

//         // =============================================================
//         // 3️⃣ Binary Search لإيجاد الحجم المناسب
//         // =============================================================
//         void findOptimalSizes() {
//           double low = 0.5;
//           double high = 1.0;
//           double bestScale = 1.0;

//           for (int i = 0; i < 10; i++) {
//             final mid = (low + high) / 2;

//             final circleSize = baseCircleSize * mid;
//             final activeWidth = baseActiveWidth * mid;

//             final totalWidth = calculateTotalWidth(circleSize, activeWidth);

//             if (totalWidth <= availableW) {
//               bestScale = mid;
//               low = mid;
//             } else {
//               high = mid;
//             }
//           }

//           baseCircleSize *= bestScale;
//           baseActiveWidth *= bestScale;
//         }

//         double totalWidth = calculateTotalWidth(
//           baseCircleSize,
//           baseActiveWidth,
//         );

//         if (totalWidth > availableW) {
//           findOptimalSizes();
//           totalWidth = calculateTotalWidth(baseCircleSize, baseActiveWidth);
//         }

//         // =============================================================
//         // 4️⃣ حساب المسافات
//         // =============================================================
//         final remainingSpace = availableW - totalWidth;
//         final gapCount = count;

//         final gap = (remainingSpace / (gapCount + 1)).clamp(4.0, 12.0);

//         final totalWidth2 =
//             ((count - 1) * baseCircleSize) +
//             widget.maxWidthActiveItemSize +
//             ((count - 1) * gap);
//         // =============================================================
//         // 5️⃣ بناء العناصر
//         // =============================================================
//         return SizedBox(
//           width: totalWidth2,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ...List.generate(count, (index) {
//                 final isActive = index == widget.activeIndex;

//                 final isLast = index == count - 1;

//                 return Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     NavBarItemWidget(
//                       item: widget.items[index],
//                       isActive: isActive,
//                       style: widget.style,
//                       activeColor: widget.activeColor,
//                       inactiveColor: widget.inactiveColor,
//                       showLabel:
//                           (widget.showLabelsAlways || isActive) &&
//                           !widget.deleteLabelsAlways,
//                       innerHeight: baseCircleSize,
//                       innerActiveItemWidth: baseActiveWidth,
//                       onTap: () => widget.onIndexChanged(index),
//                     ),
//                     if (!isLast) SizedBox(width: gap),
//                   ],
//                 );
//               }),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class NavBarItemWidget extends StatefulWidget {
//   final NavBarItem item;
//   final bool isActive;
//   final NavBarStyle style;
//   final Color? activeColor;
//   final Color? inactiveColor;
//   final bool showLabel;
//   final double innerHeight;
//   final double innerActiveItemWidth;
//   final VoidCallback onTap;

//   const NavBarItemWidget({
//     Key? key,
//     required this.item,
//     required this.isActive,
//     required this.style,
//     this.activeColor,
//     this.inactiveColor,
//     required this.showLabel,
//     required this.innerHeight,
//     required this.innerActiveItemWidth,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   State<NavBarItemWidget> createState() => _NavBarItemWidgetState();
// }

// class _NavBarItemWidgetState extends State<NavBarItemWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnim;
//   late Animation<double> _labelFadeAnim;
//   late Animation<double> _labelWidthAnim;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 280),
//       vsync: this,
//     );

//     _scaleAnim = Tween<double>(
//       begin: 0.9,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

//     _labelFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
//       ),
//     );

//     _labelWidthAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
//       ),
//     );

//     if (widget.isActive) {
//       _controller.value = 1.0;
//     }
//   }

//   @override
//   void didUpdateWidget(NavBarItemWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isActive && !oldWidget.isActive) {
//       _controller.forward(from: 0.0);
//     } else if (!widget.isActive && oldWidget.isActive) {
//       _controller.reverse();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final activeColor =
//         widget.activeColor ?? Theme.of(context).colorScheme.primary;
//     final onActiveColor = Theme.of(context).colorScheme.onPrimary;
//     final inactiveColor =
//         widget.inactiveColor ??
//         Theme.of(context).colorScheme.surfaceContainerHighest;
//     final onInactiveColor = Theme.of(context).colorScheme.onSurfaceVariant;

//     final iconSize = widget.innerHeight * 0.5;
//     final innerPaddingH = widget.innerHeight * 0.25;

//     return GestureDetector(
//       onTap: widget.onTap,
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, _) {
//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 280),
//             curve: Curves.easeInOut,
//             height: widget.innerHeight,
//             width: widget.showLabel
//                 ? widget.innerActiveItemWidth
//                 : widget.innerHeight,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(widget.innerHeight / 2),
//               color: widget.isActive ? activeColor : inactiveColor,
//               boxShadow: widget.isActive
//                   ? [
//                       BoxShadow(
//                         color: activeColor.withOpacity(0.25),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       ),
//                     ]
//                   : null,
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(widget.innerHeight / 2),
//               child: Padding(
//                 padding: EdgeInsets.all(innerPaddingH),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     ScaleTransition(
//                       scale: _scaleAnim,
//                       child: Icon(
//                         widget.isActive
//                             ? (widget.item.activeIcon ?? widget.item.icon)
//                             : widget.item.icon,
//                         size: iconSize,
//                         color: widget.isActive
//                             ? onActiveColor
//                             : onInactiveColor,
//                       ),
//                     ),
//                     if (widget.showLabel) ...[
//                       Expanded(
//                         child: ClipRect(
//                           child: SizeTransition(
//                             sizeFactor: _labelWidthAnim,
//                             axis: Axis.horizontal,
//                             child: FadeTransition(
//                               opacity: _labelFadeAnim,
//                               child: Padding(
//                                 padding: EdgeInsetsDirectional.symmetric(
//                                   horizontal: innerPaddingH * 0.6,
//                                 ),
//                                 child: Center(
//                                   child: AppText(
//                                     widget.item.label,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     type: AppTextType.labelMedium,
//                                     color: widget.isActive
//                                         ? onActiveColor
//                                         : onInactiveColor,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
/**
  Widget _buildItemsRow2() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = widget.items.length;
        final availableW = constraints.maxWidth;
        final availableH = constraints.maxHeight;
 
        // =============================================================
        // 1️⃣ الحجم الأساسي (بدون تكرار حساب النص)
        // =============================================================
        double baseCircleSize = availableH.clamp(28.0, widget.maxItemSize);

        // =============================================================
        // 2️⃣ دالة لحساب العرض الكلي بناءً على حجم معين
        // =============================================================
        double calculateTotalWidth(double circleSize) {
          // قياس النص بناءً على هذا الحجم
          final textWidth = _measureActiveItemTextWidth(context, circleSize);
        
          final innerPaddingH = circleSize * 0.259;
          final iconSize = circleSize * 0.5;
          final textGap = innerPaddingH * 0.6;

          final activeItemWidth =
              (innerPaddingH * 2) + iconSize + textGap + textWidth + 4;

          return ((count - 1) * circleSize) + activeItemWidth;
        }

        // =============================================================
        // 3️⃣ البحث عن الحجم الأمثل (Binary Search)
        // =============================================================
        double findOptimalSize(double minSize, double maxSize) {
          double low = minSize;
          double high = maxSize;
          double bestSize = maxSize;

          for (int i = 0; i < 10; i++) {
            // 10 iterations足够了
            double mid = (low + high) / 2;
            double totalWidth = calculateTotalWidth(mid);

            if (totalWidth <= availableW) {
              bestSize = mid;
              low = mid; // نحاول نكبر أكثر
            } else {
              high = mid; // نحتاج نضيق
            }
          }
          return bestSize;
        }

        // =============================================================
        // 4️⃣ الحصول على الحجم النهائي
        // =============================================================
        double finalCircleSize = baseCircleSize;
        double totalWidth = calculateTotalWidth(baseCircleSize);

        if (totalWidth > availableW) {
          // البحث عن الحجم المناسب بين 28 و baseCircleSize
          finalCircleSize = findOptimalSize(28.0, baseCircleSize);
          totalWidth = calculateTotalWidth(finalCircleSize);
        }

        // =============================================================
        // 5️⃣ إعادة الحساب النهائي للعناصر
        // =============================================================
        final textWidth = _measureActiveItemTextWidth(context, finalCircleSize);
        final innerPaddingH = finalCircleSize * 0.259;
        final iconSize = finalCircleSize * 0.5;
        final textGap = innerPaddingH * 0.6;

        final activeItemWidth =
            (innerPaddingH * 2) + iconSize + textGap + textWidth + 4;

        // حساب المسافات
        final remainingSpace = availableW - totalWidth;
        final gapCount = count;
        final gap = (remainingSpace / (gapCount + 1)).clamp(4.0, 12.0);

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(count, (index) {
              final isActive = index == widget.activeIndex;
              final isLast = index == count - 1;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NavBarItemWidget(
                    item: widget.items[index],
                    isActive: isActive,
                    style: widget.style,
                    activeColor: widget.activeColor,
                    inactiveColor: widget.inactiveColor,
                    showLabel:
                        (widget.showLabelsAlways || isActive) &&
                        !widget.deleteLabelsAlways,
                    innerHeight: finalCircleSize,
                    innerActiveItemWidth: widget.maxWidthActiveItemSize,
                    onTap: () => widget.onIndexChanged(index),
                  ),
                  if (!isLast) SizedBox(width: gap),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildItemsRow1() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = widget.items.length;
        final availableW = constraints.maxWidth;
        final availableH = constraints.maxHeight;

        // ═════════════════════════════════════════════════════════════
        // 1️⃣ حساب حجم العنصر الأساسي (الدائرة)
        // ═════════════════════════════════════════════════════════════
        double circleSize = availableH.clamp(28.0, widget.maxItemSize);

        // ═════════════════════════════════════════════════════════════
        // 2️⃣ قياس عرض النص للعنصر النشط بدقة
        // ═════════════════════════════════════════════════════════════
        final textWidth = _measureActiveItemTextWidth(context, circleSize);

        // ═════════════════════════════════════════════════════════════
        // 3️⃣ حساب العرض الإضافي للعنصر النشط
        // ═════════════════════════════════════════════════════════════
        final innerPaddingH = circleSize * 0.259; // 25.9% من الحجم
        final iconSize = circleSize * 0.5;
        final textGap = innerPaddingH * 0.6;

        // عرض العنصر النشط الموسع
        final activeItemWidth =
            (innerPaddingH * 2) + // padding يمين ويسار
            iconSize + // الأيقونة
            textGap + // المسافة بين الأيقونة والنص
            textWidth + // عرض النص
            4; // buffer إضافي للأمان

        // ═════════════════════════════════════════════════════════════
        // 4️⃣ حساب العرض الكلي للـ navbar
        // ═════════════════════════════════════════════════════════════
        // (count-1) عناصر غير نشطة بحجم circleSize
        // + 1 عنصر نشط بحجم activeItemWidth
        double totalItemsWidth = ((count - 1) * circleSize) + activeItemWidth;

        // ═════════════════════════════════════════════════════════════
        // 5️⃣ التعامل مع الـ overflow (إذا كان العرض أكبر من الشاشة)
        // ═════════════════════════════════════════════════════════════
        double adjustedCircleSize = circleSize;
        double adjustedActiveItemWidth = activeItemWidth;

        if (totalItemsWidth > availableW) {
          // نسبة التصغير
          final shrinkRatio = availableW / totalItemsWidth;

          // تصغير حجم الدائرة الأساسية
          adjustedCircleSize = circleSize * shrinkRatio;

          // تصغير عرض العنصر النشط
          adjustedActiveItemWidth = activeItemWidth * shrinkRatio;

          // إعادة حساب العرض الكلي
          totalItemsWidth =
              ((count - 1) * adjustedCircleSize) + adjustedActiveItemWidth;
        }

        // ═════════════════════════════════════════════════════════════
        // 6️⃣ حساب الفراغ بين العناصر
        // ═════════════════════════════════════════════════════════════
        final remainingSpace = availableW - totalItemsWidth;
        final gapCount = count; // الفراغات بين العناصر + الأطراف

        // توزيع متساوي للفراغات (بين 4-8 pixels)
        final gap = (remainingSpace / (gapCount + 1)).clamp(4.0, 12.0);

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: gap),
            ...List.generate(count, (index) {
              final isActive = index == widget.activeIndex;
              final isLast = index == count - 1;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NavBarItemWidget(
                    item: widget.items[index],
                    isActive: isActive,
                    style: widget.style,
                    activeColor: widget.activeColor,
                    inactiveColor: widget.inactiveColor,
                    showLabel: widget.showLabelsAlways || isActive,
                    innerHeight: adjustedCircleSize,
                    innerActiveItemWidth: widget.maxWidthActiveItemSize,
                    onTap: () => widget.onIndexChanged(index),
                  ),
                  if (!isLast) SizedBox(width: gap),
                ],
              );
            }),
            SizedBox(width: gap),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ دالة تقدير عرض النص بدقة عالية جداً
  // ═══════════════════════════════════════════════════════════════
  double _measureActiveItemTextWidth(BuildContext context, double circleSize) {
    try {
      final activeItem = widget.items[widget.activeIndex];
      final labelStr = activeItem.label.tran;
 
      // الحصول على الـ text style من الـ theme
      final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        // تعديل الـ font size بناءً على حجم الدائرة
        fontSize: (circleSize * 0.35).clamp(11.0, 16.0),
      );

      // استخدام TextPainter لقياس العرض بدقة
      final textPainter = TextPainter(
        text: TextSpan(text: labelStr, style: textStyle),
        textDirection: Directionality.of(context),
      )..layout();

      // إضافة 2px buffer للأمان (padding داخل النص)
      return textPainter.width + 2.0;
    } catch (e) {
      // في حالة الخطأ، نستخدم تقدير بسيط
      // 6-7 pixels لكل حرف في الحجم الصغير
      final labelStr = widget.items[widget.activeIndex].label.value;
      return (labelStr.length * 7.0).clamp(20.0, 120.0);
    }
  }
 */
*/
