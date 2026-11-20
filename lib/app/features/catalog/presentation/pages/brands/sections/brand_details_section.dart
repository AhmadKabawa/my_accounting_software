import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';

/// Editor section: free-text description.
class BrandDetailsSection extends StatelessWidget {
  const BrandDetailsSection({super.key, required this.description});
  final TextEditingController description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText(BrandsKeys.detailsSection, type: AppTextType.titleSmall),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: description,
        labelKey: BrandsKeys.description,
        maxLines: 3,
      ),
    ],
  );
}
