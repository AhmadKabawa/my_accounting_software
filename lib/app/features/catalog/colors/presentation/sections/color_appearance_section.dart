import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_swatch/app_color_swatch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_field_validators.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_presets.dart';

/// Editor section: HEX field, live sample and a preset palette.
class ColorAppearanceSection extends StatelessWidget {
  const ColorAppearanceSection({
    super.key,
    required this.hex,
    required this.onChanged,
  });

  final TextEditingController hex;
  final VoidCallback onChanged;

  static const _maxHexLength = 9; // #RRGGBBAA

  @override
  Widget build(BuildContext context) {
    final current = HexColor.normalize(ColorFieldValidators.withHash(hex.text));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(ColorsKeys.appearanceSection, type: AppTextType.titleSmall),
        context.ui.spacing.gap(AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: hex,
                labelKey: ColorsKeys.hexCode,
                hintKey: ColorsKeys.hexHint,
                textDirection: TextDirection.ltr,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[#0-9A-Fa-f]')),
                  LengthLimitingTextInputFormatter(_maxHexLength),
                ],
                validator: ColorFieldValidators.hex,
                onChanged: (_) => onChanged(),
              ),
            ),
            context.ui.spacing.gap(AppSpacing.smMd, axis: Axis.horizontal),
            AppColorSwatch(
              hex: HexColor.isValid(current) ? current : null,
              size: AppIconSize.xl,
            ),
          ],
        ),
        context.ui.spacing.gap(AppSpacing.sm),
        AppText(
          ColorsKeys.presets,
          type: AppTextType.bodySmall,
          color: context.ui.theme.colors.onSurfaceVariant,
        ),
        context.ui.spacing.gap(AppSpacing.xs),
        Wrap(
          spacing: context.ui.spacing.sm,
          runSpacing: context.ui.spacing.sm,
          children: [
            for (final preset in ColorPresets.hexes)
              AppColorSwatch(
                hex: preset,
                size: AppIconSize.xl,
                selected: current == preset,
                semanticLabel: ColorsKeys.presetPick.tr(
                  context: context,
                  namedArgs: {'name': preset},
                ),
                onTap: () {
                  hex.text = preset;
                  onChanged();
                },
              ),
          ],
        ),
      ],
    );
  }
}
