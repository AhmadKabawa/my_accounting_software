import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_field_validators.dart';

/// Editor section: name + slug.
class BrandIdentitySection extends StatelessWidget {
  const BrandIdentitySection({
    super.key,
    required this.name,
    required this.slug,
    required this.onNameChanged,
  });

  final TextEditingController name;
  final TextEditingController slug;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText(BrandsKeys.identitySection, type: AppTextType.titleSmall),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: name,
        labelKey: BrandsKeys.brandName,
        validator: (v) => BrandFieldValidators.name(v),
        onChanged: onNameChanged,
      ),
      context.ui.spacing.gap(AppSpacing.smMd),
      AppTextField(
        controller: slug,
        labelKey: BrandsKeys.slug,
        validator: (v) => BrandFieldValidators.slug(v),
      ),
    ],
  );
}
