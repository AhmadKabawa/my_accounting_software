import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';

class SizeSystemEditorFields extends StatelessWidget {
  const SizeSystemEditorFields({
    super.key,
    required this.name,
    required this.code,
    required this.description,
    required this.active,
    required this.onChanged,
    required this.onActiveChanged,
  });

  static const nameMax = 100;
  static const codeMax = 30;

  final TextEditingController name;
  final TextEditingController code;
  final TextEditingController description;
  final bool active;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool>? onActiveChanged;

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
        textCapitalization: TextCapitalization.words,
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
        controller: description,
        labelKey: SizeSystemsKeys.description,
        onChanged: onChanged,
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
