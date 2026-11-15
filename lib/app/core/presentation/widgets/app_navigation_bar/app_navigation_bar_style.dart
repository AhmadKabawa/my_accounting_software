import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// Only two styles are kept: [minimal] (the default: a flat bar on a surface
/// with a hairline top border) and [pill] (a floating bar with a primary
/// gradient and glow).
enum NavBarStyle { minimal, pill }

/// Every visual value of one [NavBarStyle], resolved for the current context.
class NavbarVariant {
  final BorderRadius radius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color background;
  final Border? border;
  final List<BoxShadow> shadows;
  final Gradient? gradient;

  const NavbarVariant({
    required this.radius,
    required this.padding,
    required this.margin,
    required this.background,
    required this.shadows,
    this.border,
    this.gradient,
  });
}

class AppNavigationBarStyle {
  final BuildContext context;

  const AppNavigationBarStyle(this.context);

  // ═══════════════════════════════════════════
  // 🔹 TOKENS
  // Decorative values that moved here from the widget keep the same size on
  // every screen (`ResponsiveMode.fixed` = the token's mobile value). Tokens
  // with no match in AppElevation are declared here.
  // ═══════════════════════════════════════════

  static const _pillBlur = AppElevation(15, 18, 21);

  static const _pillShadowOffset = Offset(0, 8);
  static const _itemShadowOffset = Offset(0, 3);

  static const _pillStartOpacity = 0.8;
  static const _glowOpacity = 0.4;
  static const _itemShadowOpacity = 0.25;

  /// Padding inside an item, as a fraction of its height.
  static const _itemInsetRatio = 0.15;

  /// Scale an inactive icon starts from when its item becomes active.
  /// Static: the item animation is created in initState, before a context
  /// can be read.
  static const iconScaleBegin = 0.9;

  double _fixed(AppElevation token) =>
      Rh.elevation(context, token, mode: ResponsiveMode.fixed);

  // ═══════════════════════════════════════════
  // 🔹 SIZES
  // ═══════════════════════════════════════════

  double get defaultMaxItemSize => Rh.width(
    context,
    AppComponentSize.medium,
    min: AppComponentSize.small,
    max: AppComponentSize.large,
  );

  /// The active item is as wide as two inactive ones.
  double get defaultActiveItemWidth => defaultMaxItemSize * 2;

  double get height => Rh.spacing(context, AppSpacing.xl);

  /// Horizontal padding inside an item of [itemHeight].
  double itemInset(double itemHeight) => itemHeight * _itemInsetRatio;

  double itemIconSize(double itemHeight) =>
      itemHeight - itemInset(itemHeight) * 3;

  /// An item is a pill: fully rounded ends.
  BorderRadius itemRadius(double itemHeight) =>
      BorderRadius.circular(itemHeight / 2);

  // ═══════════════════════════════════════════
  // 🔹 SPACING
  // ═══════════════════════════════════════════

  double get spacing => Rh.spacing(context, AppSpacing.sm);

  /// Range of the gap between items.
  double get minGap =>
      Rh.spacing(context, AppSpacing.xs, mode: ResponsiveMode.fixed);

  double get maxGap =>
      Rh.spacing(context, AppSpacing.smMd, mode: ResponsiveMode.fixed);

  EdgeInsets get padding => EdgeInsets.symmetric(
    horizontal: Rh.spacing(context, AppSpacing.lg),
    vertical: Rh.spacing(context, AppSpacing.sm),
  );

  // ═══════════════════════════════════════════
  // 🔹 COLORS
  // ═══════════════════════════════════════════

  ColorScheme get _scheme => Theme.of(context).colorScheme;

  /// The bar is a surface (like cards), not a see-through layer.
  Color get background => _scheme.surface;

  Color get activeColor => _scheme.primary;

  Color get onActiveColor => _scheme.onPrimary;

  Color get inactiveColor => _scheme.surfaceContainerHighest;

  Color get onInactiveColor => _scheme.onSurfaceVariant;

  /// Hairline on the top edge of the bar.
  Color get borderColor => _scheme.outlineVariant;

  // ═══════════════════════════════════════════
  // 🔹 BORDER RADIUS
  // ═══════════════════════════════════════════

  BorderRadius get radius => context.ui.radius.xxl;

  // ═══════════════════════════════════════════
  // 🔹 SHADOWS
  // ═══════════════════════════════════════════

  List<BoxShadow> activeItemShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(_itemShadowOpacity),
      blurRadius: _fixed(AppElevation.lg),
      offset: _itemShadowOffset,
    ),
  ];

  List<BoxShadow> _glow(Color color, {required double blur, Offset? offset}) =>
      [
        BoxShadow(
          color: color.withOpacity(_glowOpacity),
          blurRadius: blur,
          offset: offset ?? _pillShadowOffset,
        ),
      ];

  // ═══════════════════════════════════════════
  // 🔹 VARIANTS
  // ═══════════════════════════════════════════

  /// The visual values of [style]. The optional arguments are the widget's
  /// overrides: they win over the style's own values. [borderRadius] only
  /// applies to [NavBarStyle.pill]; [backgroundColor] only to
  /// [NavBarStyle.minimal].
  NavbarVariant variant(
    NavBarStyle style, {
    Color? backgroundColor,
    Color? activeColor,
    double? borderRadius,
  }) {
    switch (style) {
      case NavBarStyle.pill:
        final primary = activeColor ?? this.activeColor;
        return NavbarVariant(
          radius: borderRadius != null
              ? BorderRadius.circular(borderRadius)
              : radius,
          padding: padding,
          margin: EdgeInsets.all(spacing),
          background: Colors.transparent,
          gradient: LinearGradient(
            colors: [primary.withOpacity(_pillStartOpacity), primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadows: _glow(primary, blur: _fixed(_pillBlur)),
        );

      case NavBarStyle.minimal:
        return NavbarVariant(
          radius: BorderRadius.zero,
          padding: padding,
          margin: EdgeInsets.zero,
          background: backgroundColor ?? background,
          border: Border(
            top: BorderSide(
              color: borderColor,
              width: AppBorderWidth.thin.of(context),
            ),
          ),
          shadows: const [],
        );
    }
  }
}
