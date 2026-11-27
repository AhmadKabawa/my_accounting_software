import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/localization/genders_keys.dart';

class GenderEditorFields extends StatelessWidget {
  const GenderEditorFields({
    super.key,
    required this.name,
    required this.code,
    required this.sortOrder,
    required this.active,
    required this.onNameChanged,
    required this.onActiveChanged,
  });

  final TextEditingController name;
  final TextEditingController code;
  final TextEditingController sortOrder;
  final bool active;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<bool>? onActiveChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText(GendersKeys.identity, type: AppTextType.titleSmall),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: name,
        labelKey: GendersKeys.name,
        onChanged: onNameChanged,
        textCapitalization: TextCapitalization.words,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return GendersKeys.required.tr(context: context);
          if (text.length > 50)
            return GendersKeys.nameTooLong.tr(context: context);
          return null;
        },
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: code,
        labelKey: GendersKeys.code,
        textDirection: TextDirection.ltr,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return GendersKeys.required.tr(context: context);
          if (text.length > 30)
            return GendersKeys.codeTooLong.tr(context: context);
          if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(text)) {
            return GendersKeys.codeFormat.tr(context: context);
          }
          return null;
        },
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: sortOrder,
        labelKey: GendersKeys.sortOrder,
        keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr,
        validator: (value) {
          final parsed = int.tryParse((value ?? '').trim());
          if (parsed == null || parsed < 0)
            return GendersKeys.sortFormat.tr(context: context);
          return null;
        },
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      AppSwitch(
        value: active,
        labelKey: GendersKeys.active,
        onChanged: onActiveChanged,
      ),
    ],
  );
}
