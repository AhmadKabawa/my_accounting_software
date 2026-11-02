import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

enum NavBarStyle { elegant, glassmorphism, pill, minimal, neon }

/// Every visual value of one [NavBarStyle], resolved for the current context.
class NavbarVariant {
  final BorderRadius radius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color background;
  final Border? border;
  final List<BoxShadow> shadows;
  final Gradient? gradient;

  /// Backdrop blur sigma; null = no blur.
  final double? blur;

  const NavbarVariant({
    required this.radius,
    required this.padding,
    required this.margin,
    required this.background,
    required this.shadows,
    this.border,
    this.gradient,
    this.blur,
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

  static const _glassBlur = AppElevation(10, 12, 14);
  static const _pillBlur = AppElevation(15, 18, 21);

  static const _borderWidth = 1.0;
  static const _strongBorderWidth = 1.5;
  static const _minimalBorderWidth = 0.5;

  static const _shadowOffset = Offset(0, 4);
  static const _glassShadowOffset = Offset(0, 5);
  static const _pillShadowOffset = Offset(0, 8);
  static const _itemShadowOffset = Offset(0, 3);

  static const _glassOpacity = 0.7;
  static const _shadowOpacity = 0.12;
  static const _glassBorderOpacity = 0.3;
  static const _pillStartOpacity = 0.8;
  static const _glowOpacity = 0.4;
  static const _itemShadowOpacity = 0.25;

  /// Padding inside an item, as a fraction of its height.
  static const _itemInsetRatio = 0.15;

  /// Scale an inactive icon starts from when its item becomes active.
  /// Static: the item animation is created in initState, before a context
  /// can be read.
  static const iconScaleBegin = 0.9;

  /// Backdrops more transparent than this (alpha 0-255) get blurred.
  static const _blurAlphaThreshold = 200;

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

  EdgeInsets get _elegantPadding =>
      Rh.allPadding(context, AppSpacing.sm, mode: ResponsiveMode.fixed);

  EdgeInsets get _glassPadding => Rh.allPadding(context, AppSpacing.sm);

  // ═══════════════════════════════════════════
  // 🔹 COLORS
  // ═══════════════════════════════════════════

  ColorScheme get _scheme => Theme.of(context).colorScheme;

  Color get background => _scheme.surfaceContainer;

  Color get glassBackground => background.withOpacity(_glassOpacity);

  Color get glassBorderColor =>
      Colors.white.withOpacity(_glassBorderOpacity);

  Color get activeColor => _scheme.primary;

  Color get onActiveColor => _scheme.onPrimary;

  Color get inactiveColor => _scheme.surfaceContainerHighest;

  Color get onInactiveColor => _scheme.onSurfaceVariant;

  Color get borderColor => _scheme.outlineVariant;

  Color get shadowColor => _scheme.shadow.withOpacity(_shadowOpacity);

  Color get neonColor => _scheme.tertiary;

  // ═══════════════════════════════════════════
  // 🔹 BORDER RADIUS
  // ═══════════════════════════════════════════

  BorderRadius get radius => context.ui.radius.xxl;

  // ═══════════════════════════════════════════
  // 🔹 SHADOWS
  // ═══════════════════════════════════════════

  double get defaultElevation => _fixed(AppElevation.lg);

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
          offset: offset ?? _shadowOffset,
        ),
      ];

  // ═══════════════════════════════════════════
  // 🔹 VARIANTS
  // ═══════════════════════════════════════════

  /// The visual values of [style]. The optional arguments are the widget's
  /// overrides: they win over the style's own values.
  NavbarVariant variant(
    NavBarStyle style, {
    Color? backgroundColor,
    Color? activeColor,
    double? borderRadius,
    double? elevation,
  }) {
    final radius = borderRadius != null
        ? BorderRadius.circular(borderRadius)
        : this.radius;
    final margin = EdgeInsets.all(spacing);

    switch (style) {
      case NavBarStyle.elegant:
        return _variant(
          radius: radius,
          padding: _elegantPadding,
          margin: margin,
          background: backgroundColor ?? background,
          border: Border.all(color: borderColor, width: _borderWidth),
          shadows: [
            BoxShadow(
              color: shadowColor,
              blurRadius: elevation ?? defaultElevation,
              offset: _shadowOffset,
            ),
          ],
        );

      case NavBarStyle.glassmorphism:
        return _variant(
          radius: radius,
          padding: _glassPadding,
          margin: margin,
          background: glassBackground,
          border: Border.all(color: glassBorderColor, width: _strongBorderWidth),
          shadows: [
            BoxShadow(
              color: shadowColor,
              blurRadius: _fixed(_glassBlur),
              offset: _glassShadowOffset,
            ),
          ],
        );

      case NavBarStyle.pill:
        final primary = activeColor ?? this.activeColor;
        return _variant(
          radius: radius,
          padding: padding,
          margin: margin,
          background: Colors.transparent,
          gradient: LinearGradient(
            colors: [primary.withOpacity(_pillStartOpacity), primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadows: _glow(
            primary,
            blur: _fixed(_pillBlur),
            offset: _pillShadowOffset,
          ),
        );

      case NavBarStyle.minimal:
        return _variant(
          radius: BorderRadius.zero,
          padding: padding,
          margin: margin,
          background: Colors.transparent,
          border: Border(
            top: BorderSide(color: borderColor, width: _minimalBorderWidth),
          ),
          shadows: const [],
        );

      case NavBarStyle.neon:
        final neon = activeColor ?? neonColor;
        return _variant(
          radius: radius,
          padding: padding,
          margin: margin,
          background: background,
          border: Border.all(color: neon, width: _strongBorderWidth),
          shadows: _glow(neon, blur: _fixed(AppElevation.xxl)),
        );
    }
  }

  /// Adds the backdrop blur: a see-through bar without a gradient is blurred.
  NavbarVariant _variant({
    required BorderRadius radius,
    required EdgeInsets padding,
    required EdgeInsets margin,
    required Color background,
    required List<BoxShadow> shadows,
    Border? border,
    Gradient? gradient,
  }) => NavbarVariant(
    radius: radius,
    padding: padding,
    margin: margin,
    background: background,
    border: border,
    shadows: shadows,
    gradient: gradient,
    blur: gradient == null && background.alpha < _blurAlphaThreshold
        ? _fixed(_glassBlur)
        : null,
  );
}
