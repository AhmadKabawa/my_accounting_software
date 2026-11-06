import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// A bordered surface that groups related content (summary tiles, list
/// blocks). Radius, padding and border come from tokens; colors from the
/// theme. Tappable when [onTap] is given.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.md,
    this.radius = AppRadius.md,
    this.onTap,
    this.semanticsLabel,
  });

  final Widget child;
  final AppSpacing padding;
  final AppRadius radius;
  final VoidCallback? onTap;

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
      content = InkWell(onTap: onTap, borderRadius: borderRadius, child: content);
    }

    final card = Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: scheme.outlineVariant,
          width: AppBorderWidth.thin.of(context),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    return semanticsLabel == null
        ? card
        : Semantics(label: semanticsLabel, container: true, child: card);
  }
}
