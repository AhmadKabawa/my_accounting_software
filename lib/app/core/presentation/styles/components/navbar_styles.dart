import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/responsive/helper/responsive_helper.dart';

class NavbarStyles {
  final BuildContext context;

  const NavbarStyles(this.context);

  // ═══════════════════════════════════════════
  // 🔹 SIZES
  // ═══════════════════════════════════════════

  double get defaultMaxItemSize => Rh.width(
    context,
    AppComponentSize.medium,
    min: AppComponentSize.small,
    max: AppComponentSize.large,
  );

  double get defaultActiveItemWidth => defaultMaxItemSize;

  double get height => Rh.spacing(context, AppSpacing.xl);

  // ═══════════════════════════════════════════
  // 🔹 SPACING
  // ═══════════════════════════════════════════

  double get spacing => Rh.spacing(context, AppSpacing.sm);

  EdgeInsets get padding => EdgeInsets.symmetric(
    horizontal: Rh.spacing(context, AppSpacing.lg),
    vertical: Rh.spacing(context, AppSpacing.sm),
  );

  EdgeInsets get itemPadding =>
      EdgeInsets.all(Rh.spacing(context, AppSpacing.xs));

  // ═══════════════════════════════════════════
  // 🔹 COLORS
  // ═══════════════════════════════════════════

  Color get background => Theme.of(context).colorScheme.surfaceContainer;

  Color get glassBackground =>
      Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.7);

  Color get activeColor => Theme.of(context).colorScheme.primary;

  Color get inactiveColor =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  Color get borderColor => Theme.of(context).colorScheme.outlineVariant;

  Color get shadowColor =>
      Theme.of(context).colorScheme.shadow.withOpacity(0.12);

  Color get neonColor => Theme.of(context).colorScheme.tertiary;

  // ═══════════════════════════════════════════
  // 🔹 BORDER RADIUS
  // ═══════════════════════════════════════════

  BorderRadius get radius => context.ui.radius.xxl;

  // ═══════════════════════════════════════════
  // 🔹 SHADOWS
  // ═══════════════════════════════════════════

  List<BoxShadow> get defaultShadow => [
    BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 4)),
  ];

  List<BoxShadow> neonShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
