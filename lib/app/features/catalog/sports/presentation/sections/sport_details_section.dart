import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/widgets/sport_field_validators.dart';

/// Editor section: optional description + display order.
class SportDetailsSection extends StatelessWidget {
  const SportDetailsSection({
    super.key,
    required this.description,
    required this.sortOrder,
    required this.onChanged,
  });

  final TextEditingController description;
  final TextEditingController sortOrder;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText(SportsKeys.detailsSection, type: AppTextType.titleSmall),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: description,
        labelKey: SportsKeys.description,
        maxLines: 3,
        onChanged: (_) => onChanged(),
      ),
      context.ui.spacing.gap(AppSpacing.smMd),
      AppTextField(
        controller: sortOrder,
        labelKey: SportsKeys.sortOrder,
        keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr,
        textInputAction: TextInputAction.done,
        validator: SportFieldValidators.sortOrder,
        onChanged: (_) => onChanged(),
      ),
      context.ui.spacing.gap(AppSpacing.xs),
      AppText(
        SportsKeys.sortOrderHint,
        type: AppTextType.bodySmall,
        color: context.ui.theme.colors.onSurfaceVariant,
      ),
    ],
  );
}
