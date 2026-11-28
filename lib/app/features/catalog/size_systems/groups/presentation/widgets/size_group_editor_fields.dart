import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/gender_option.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';

class SizeGroupEditorFields extends StatelessWidget {
  const SizeGroupEditorFields({
    super.key,
    required this.name,
    required this.code,
    required this.description,
    required this.genders,
    required this.genderId,
    required this.active,
    required this.onChanged,
    required this.onGenderChanged,
    required this.onActiveChanged,
  });

  static const nameMax = 150;
  static const codeMax = 50;

  final TextEditingController name;
  final TextEditingController code;
  final TextEditingController description;

  /// Selectable genders; the table may be empty (gender is optional).
  final List<GenderOption> genders;
  final int? genderId;
  final bool active;
  final ValueChanged<String> onChanged;
  final ValueChanged<int?>? onGenderChanged;
  final ValueChanged<bool>? onActiveChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      for (final gender in genders)
        if (gender.isActive || gender.id == genderId) gender,
    ];
    GenderOption? selected;
    for (final gender in options) {
      if (gender.id == genderId) selected = gender;
    }
    return Column(
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
            if (text.isEmpty) {
              return SizeSystemsKeys.required.tr(context: context);
            }
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
            if (text.isEmpty) {
              return SizeSystemsKeys.required.tr(context: context);
            }
            if (text.length > codeMax) {
              return SizeSystemsKeys.codeTooLong.tr(context: context);
            }
            return null;
          },
        ),
        context.ui.spacing.gap(AppSpacing.sm),
        SearchableDropdown<GenderOption>(
          options: options,
          labelKey: SizeSystemsKeys.gender,
          optionLabel: (gender) => gender.name,
          value: selected,
          allOptionLabel: SizeSystemsKeys.noGender,
          mode: SearchableDropdownMode.panel,
          onChanged: (gender) => onGenderChanged?.call(gender?.id),
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
}
