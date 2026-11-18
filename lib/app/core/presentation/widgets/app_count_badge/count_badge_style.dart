import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';

/// The meaning of a count badge. A badge is never told its color directly:
/// the variant names the intent and [CountBadgeStyle] resolves it.
enum CountBadgeVariant {
  /// A neutral count of something the user may open (a tab, a list).
  neutral,

  /// Something that wants attention (the bell, unread items).
  primary,

  /// Something that is wrong or overdue.
  error,
}

/// The corner of the anchored widget a badge sits on. Logical (start/end), so
/// it flips with the text direction.
enum CountBadgeCorner { topEnd, topStart }

/// Colors of one [CountBadgeVariant].
class CountBadgeVisual {
  const CountBadgeVisual({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

/// Resolves every visual value of a `CountBadge` from the theme and tokens.
class CountBadgeStyle {
  const CountBadgeStyle(this.context);

  final BuildContext context;

  /// The highest count shown as a number. Above it the badge shows `99+`.
  static const maxCount = 99;

  /// The text of a count: the number, or `99+` above [maxCount]. Digits are
  /// western (decision 77), which `int.toString` already gives.
  static String label(int count) =>
      count > maxCount ? '$maxCount+' : count.toString();

  CountBadgeVisual resolve(CountBadgeVariant variant) {
    final colors = context.ui.theme.colors;

    return switch (variant) {
      CountBadgeVariant.neutral => CountBadgeVisual(
        background: colors.surfaceContainerHighest,
        foreground: colors.onSurface,
      ),
      CountBadgeVariant.primary => CountBadgeVisual(
        background: colors.primary,
        foreground: colors.onPrimary,
      ),
      CountBadgeVariant.error => CountBadgeVisual(
        background: colors.error,
        foreground: colors.onError,
      ),
    };
  }

  /// Height of the number pill, and its minimum width (a single digit is a
  /// circle).
  double get height => AppIconSize.sm.of(context);

  /// Diameter of the dot style.
  double get dotSize => AppSpacing.sm.of(context);

  EdgeInsets get padding =>
      EdgeInsets.symmetric(horizontal: AppSpacing.xs.of(context));

  BorderRadius get radius => AppRadius.full.circular(context);

  /// The ring that separates the badge from what it sits on.
  Color get ringColor => context.ui.theme.colors.surface;

  double get ringWidth => AppBorderWidth.thin.of(context);

  /// How far the badge sticks out of the corner of its anchor.
  double get overhang => AppSpacing.xs.of(context);
}
