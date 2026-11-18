// ─────────────────────────────────────────────────────────────────
// count_badge.dart  (C41)
//
// A small counter: the bell, a "low stock" tab, a filter that has values.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_count_badge/count_badge_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

export 'package:accounting_software/app/core/presentation/widgets/app_count_badge/count_badge_style.dart'
    show CountBadgeVariant, CountBadgeCorner;

/// A counter badge.
///
/// - **Zero (or less) is hidden**: the widget is empty, so a screen can pass
///   the raw count without an `if`.
/// - **Above 99 it shows `99+`**; the screen reader still hears the real count.
/// - **Dot style** ([CountBadge.dot]) shows a small dot with no number, for
///   "there is something new" when the number does not matter.
/// - **Accessibility:** the number is the value of the semantics node, and
///   [semanticsLabelKey] names what is counted ("Notifications"). Color is
///   never the only signal: the number (or, for a dot, the label) carries it.
/// - **Placement:** wrap the anchor in [CountBadgeAnchor], which places the
///   badge on a logical (start/end) corner.
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.count,
    this.variant = CountBadgeVariant.error,
    this.semanticsLabelKey,
  }) : dot = false;

  /// The dot style: no number, shown while [count] is above zero.
  const CountBadge.dot({
    super.key,
    required this.count,
    this.variant = CountBadgeVariant.error,
    this.semanticsLabelKey,
  }) : dot = true;

  final int count;
  final CountBadgeVariant variant;

  /// What is counted, read by screen readers together with the count.
  final AppKey? semanticsLabelKey;

  final bool dot;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final style = CountBadgeStyle(context);
    final visual = style.resolve(variant);

    final ring = Border.all(color: style.ringColor, width: style.ringWidth);

    final Widget shape = dot
        ? SizedBox.square(
            dimension: style.dotSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: visual.background,
                shape: BoxShape.circle,
                border: ring,
              ),
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: style.height,
              minHeight: style.height,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: visual.background,
                borderRadius: style.radius,
                border: ring,
              ),
              child: Padding(
                padding: style.padding,
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: AppText.raw(
                    CountBadgeStyle.label(count),
                    type: AppTextType.labelSmall,
                    color: visual.foreground,
                    weight: FontWeight.w600,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          );

    return Semantics(
      container: true,
      label: semanticsLabelKey?.tr(context: context),
      value: count.toString(),
      child: ExcludeSemantics(child: shape),
    );
  }
}

/// Puts a [badge] on a logical corner of [child], overhanging it a little.
///
/// The corner is `start`/`end`, never `left`/`right`, so in RTL the badge sits
/// on the other physical side without any code at the call site.
class CountBadgeAnchor extends StatelessWidget {
  const CountBadgeAnchor({
    super.key,
    required this.child,
    required this.badge,
    this.corner = CountBadgeCorner.topEnd,
  });

  final Widget child;
  final CountBadge badge;
  final CountBadgeCorner corner;

  @override
  Widget build(BuildContext context) {
    final overhang = CountBadgeStyle(context).overhang;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: -overhang,
          end: corner == CountBadgeCorner.topEnd ? -overhang : null,
          start: corner == CountBadgeCorner.topStart ? -overhang : null,
          child: badge,
        ),
      ],
    );
  }
}
