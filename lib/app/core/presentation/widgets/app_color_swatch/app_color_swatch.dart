import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// A round color sample (C26) for a `#RRGGBB[AA]` value.
///
/// The ring uses the control outline so very light colors (white on white)
/// keep at least 3:1 contrast. A missing or invalid value draws an empty ring.
///
/// Display only (no [onTap]): color alone carries no meaning, so always show
/// the color's name next to it; the swatch is hidden from screen readers.
///
/// Selectable (with [onTap]): behaves as a button named [semanticLabel], and
/// [selected] draws a thicker primary ring, so the state is not color-only.
class AppColorSwatch extends StatelessWidget {
  const AppColorSwatch({
    super.key,
    required this.hex,
    this.size = AppIconSize.md,
    this.onTap,
    this.selected = false,
    this.semanticLabel,
  });

  final String? hex;
  final AppIconSize size;
  final VoidCallback? onTap;
  final bool selected;

  /// Required for a selectable swatch: its accessible name.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final argb = HexColor.toArgb(hex);
    final scheme = Theme.of(context).colorScheme;
    final dimension = size.of(context);
    final ring = selected ? AppBorderWidth.thick : AppBorderWidth.thin;
    final circle = SizedBox.square(
      dimension: dimension,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: argb == null ? null : Color(argb),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline,
            width: ring.of(context),
          ),
        ),
      ),
    );

    if (onTap == null) return ExcludeSemantics(child: circle);

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: InkResponse(onTap: onTap, radius: dimension, child: circle),
    );
  }
}
