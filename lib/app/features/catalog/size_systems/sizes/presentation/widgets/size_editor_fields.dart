import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';

class SizeEditorFields extends StatelessWidget {
  const SizeEditorFields({
    super.key,
    required this.name,
    required this.code,
    required this.numericValue,
    required this.sortOrder,
    required this.active,
    required this.onChanged,
    required this.onActiveChanged,
  });

  static const nameMax = 50;
  static const codeMax = 50;

  /// `numeric(8,2)`: at most 6 integer digits and 2 decimals.
  static const numericMaxAbs = '999999.99';
  static const numericScale = 2;

  final TextEditingController name;
  final TextEditingController code;
  final TextEditingController numericValue;
  final TextEditingController sortOrder;
  final bool active;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool>? onActiveChanged;

  /// Blank is valid (the value is optional); otherwise it must fit n(8,2).
  static bool isValidNumeric(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return true;
    final value = Decimal.tryParse(text);
    if (value == null) return false;
    if (value.scale > numericScale) return false;
    return value.abs() <= Decimal.parse(numericMaxAbs);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText(SizeSystemsKeys.identity, type: AppTextType.titleSmall),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: name,
        labelKey: SizeSystemsKeys.nameField,
        onChanged: onChanged,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty)
            return SizeSystemsKeys.required.tr(context: context);
          if (text.length > nameMax) {
            return SizeSystemsKeys.nameTooLong.tr(context: context);
          }
          return null;
        },
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: code,
        labelKey: SizeSystemsKeys.code,
        onChanged: onChanged,
        textDirection: TextDirection.ltr,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty)
            return SizeSystemsKeys.required.tr(context: context);
          if (text.length > codeMax) {
            return SizeSystemsKeys.codeTooLong.tr(context: context);
          }
          return null;
        },
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: numericValue,
        labelKey: SizeSystemsKeys.numericValue,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textDirection: TextDirection.ltr,
        validator: (value) => isValidNumeric(value ?? '')
            ? null
            : SizeSystemsKeys.numberFormat.tr(context: context),
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: sortOrder,
        labelKey: SizeSystemsKeys.sortOrder,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr,
        validator: (value) {
          final parsed = int.tryParse((value ?? '').trim());
          if (parsed == null || parsed < 0) {
            return SizeSystemsKeys.sortFormat.tr(context: context);
          }
          return null;
        },
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      AppSwitch(
        value: active,
        labelKey: SizeSystemsKeys.active,
        onChanged: onActiveChanged,
      ),
    ],
  );
}
