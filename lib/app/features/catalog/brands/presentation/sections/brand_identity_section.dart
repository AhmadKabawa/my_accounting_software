import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_field_validators.dart';

/// Editor section: name + slug.
class BrandIdentitySection extends StatelessWidget {
  const BrandIdentitySection({
    super.key,
    required this.name,
    required this.slug,
    required this.onNameChanged,
    required this.onSlugChanged,
    required this.showSlugHint,
    this.onRegenerateSlug,
  });

  final TextEditingController name;
  final TextEditingController slug;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onSlugChanged;
  final bool showSlugHint;
  final VoidCallback? onRegenerateSlug;

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
        onChanged: onSlugChanged,
      ),
      if (showSlugHint) ...[
        context.ui.spacing.gap(AppSpacing.xs),
        AppText(BrandsKeys.slugLatinHint, type: AppTextType.bodySmall),
      ],
      if (onRegenerateSlug != null) ...[
        context.ui.spacing.gap(AppSpacing.xs),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppButton(
            BrandsKeys.regenerateSlug,
            variant: AppButtonVariant.text,
            onPressed: onRegenerateSlug,
          ),
        ),
      ],
    ],
  );
}
