import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/formatters/uppercase_code_formatter.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/widgets/sport_field_validators.dart';

/// Editor section: name + code.
class SportIdentitySection extends StatelessWidget {
  const SportIdentitySection({
    super.key,
    required this.name,
    required this.code,
    required this.onChanged,
  });

  final TextEditingController name;
  final TextEditingController code;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText(SportsKeys.identitySection, type: AppTextType.titleSmall),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: name,
        labelKey: SportsKeys.sportName,
        autofocus: true,
        validator: SportFieldValidators.name,
        onChanged: (_) => onChanged(),
      ),
      context.ui.spacing.gap(AppSpacing.smMd),
      AppTextField(
        controller: code,
        labelKey: SportsKeys.code,
        hintKey: SportsKeys.codeHint,
        textDirection: TextDirection.ltr,
        validator: SportFieldValidators.code,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: const [UppercaseCodeFormatter()],
        onChanged: (_) => onChanged(),
      ),
    ],
  );
}
