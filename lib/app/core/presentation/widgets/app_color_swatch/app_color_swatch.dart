import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// A round color sample (C26) for a `#RRGGBB[AA]` value.
///
/// The ring uses the control outline so very light colors (white on white)
/// keep at least 3:1 contrast. A missing or invalid value draws an empty ring.
/// Color alone carries no meaning: always show the color's name next to it, so
/// the swatch itself is hidden from screen readers.
class AppColorSwatch extends StatelessWidget {
  const AppColorSwatch({
    super.key,
    required this.hex,
    this.size = AppIconSize.md,
  });

  final String? hex;
  final AppIconSize size;

  @override
  Widget build(BuildContext context) {
    final argb = HexColor.toArgb(hex);
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size.of(context),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: argb == null ? null : Color(argb),
            border: Border.all(
              color: scheme.outline,
              width: AppBorderWidth.thin.of(context),
            ),
          ),
        ),
      ),
    );
  }
}
