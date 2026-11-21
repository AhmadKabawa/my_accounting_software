import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_swatch/app_color_swatch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';

/// Swatch + name (+ HEX): the primary cell of the table and the card header.
class ColorIdentity extends StatelessWidget {
  const ColorIdentity(this.color, {super.key});
  final CatalogColor color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      AppColorSwatch(hex: color.hexCode, size: AppIconSize.lg),
      context.ui.spacing.gap(AppSpacing.smMd, axis: Axis.horizontal),
      Expanded(child: AppText.raw(color.name, type: AppTextType.titleSmall)),
    ],
  );
}
