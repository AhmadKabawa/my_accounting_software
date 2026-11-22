import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// A bordered surface that groups related content (summary tiles, list
/// blocks). Radius, padding and border come from tokens; colors from the
/// theme. Tappable when [onTap] is given.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.md,
    this.radius = AppRadius.lg,
    this.onTap,
    this.semanticsLabel,
    this.selected = false,
  });

  final Widget child;
  final AppSpacing padding;
  final AppRadius radius;
  final VoidCallback? onTap;

  /// Marks the card as the chosen one: a thicker border in the primary color
  /// and the semantic `selected` flag (the border is not the only signal).
  final bool selected;

  /// Read by screen readers instead of the card's content when set.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderRadius = Rh.circularRadius(context, radius);

    Widget content = Padding(
      padding: Rh.allPadding(context, padding),
      child: child,
    );
    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: content,
      );
    }

    final card = Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: (selected ? AppBorderWidth.thick : AppBorderWidth.thin).of(
            context,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    return semanticsLabel == null && !selected
        ? card
        : Semantics(
            label: semanticsLabel,
            selected: selected,
            container: true,
            child: card,
          );
  }
}
