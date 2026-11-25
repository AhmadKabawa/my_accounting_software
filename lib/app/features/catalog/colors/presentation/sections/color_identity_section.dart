import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_field_validators.dart';

/// Editor section: name + code (+ display order).
class ColorIdentitySection extends StatelessWidget {
  const ColorIdentitySection({
    super.key,
    required this.name,
    required this.code,
    required this.sortOrder,
    required this.onChanged,
    required this.onNameChanged,
    this.suggestedName,
  });

  final TextEditingController name;
  final TextEditingController code;
  final TextEditingController sortOrder;
  final VoidCallback onChanged;
  final VoidCallback onNameChanged;
  final String? suggestedName;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText(ColorsKeys.identitySection, type: AppTextType.titleSmall),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: name,
        labelKey: ColorsKeys.colorName,
        autofocus: true,
        validator: ColorFieldValidators.name,
        onChanged: (_) {
          onNameChanged();
          onChanged();
        },
      ),
      if (suggestedName != null) ...[
        context.ui.spacing.gap(AppSpacing.xs),
        AppText(
          ColorsKeys.suggestedName,
          type: AppTextType.bodySmall,
          color: context.ui.theme.colors.onSurfaceVariant,
        ),
        AppText.raw(suggestedName!, type: AppTextType.bodySmall),
      ],
      context.ui.spacing.gap(AppSpacing.smMd),
      AppTextField(
        controller: code,
        labelKey: ColorsKeys.code,
        hintKey: ColorsKeys.codeHint,
        textDirection: TextDirection.ltr,
        validator: ColorFieldValidators.code,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: const [_UppercaseCodeFormatter()],
        onChanged: (_) => onChanged(),
      ),
      context.ui.spacing.gap(AppSpacing.smMd),
      AppTextField(
        controller: sortOrder,
        labelKey: ColorsKeys.sortOrder,
        keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr,
        textInputAction: TextInputAction.done,
        validator: ColorFieldValidators.sortOrder,
        onChanged: (_) => onChanged(),
      ),
      context.ui.spacing.gap(AppSpacing.xs),
      AppText(
        ColorsKeys.sortOrderHint,
        type: AppTextType.bodySmall,
        color: context.ui.theme.colors.onSurfaceVariant,
      ),
    ],
  );
}

class _UppercaseCodeFormatter extends TextInputFormatter {
  const _UppercaseCodeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '')
        .toUpperCase();
    final base = newValue.selection.baseOffset.clamp(0, text.length).toInt();
    final extent = newValue.selection.extentOffset
        .clamp(0, text.length)
        .toInt();
    return newValue.copyWith(
      text: text,
      selection: TextSelection(baseOffset: base, extentOffset: extent),
      composing: TextRange.empty,
    );
  }
}
