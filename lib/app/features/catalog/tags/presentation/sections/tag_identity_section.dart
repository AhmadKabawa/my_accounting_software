import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/widgets/tag_field_validators.dart';

/// Editor section: name + slug.
class TagIdentitySection extends StatelessWidget {
  const TagIdentitySection({
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
      AppText(TagsKeys.identitySection, type: AppTextType.titleSmall),
      context.ui.spacing.gap(AppSpacing.sm),
      AppTextField(
        controller: name,
        labelKey: TagsKeys.tagName,
        autofocus: true,
        validator: TagFieldValidators.name,
        onChanged: onNameChanged,
      ),
      context.ui.spacing.gap(AppSpacing.smMd),
      AppTextField(
        controller: slug,
        labelKey: TagsKeys.slug,
        hintKey: TagsKeys.slugHint,
        textDirection: TextDirection.ltr,
        validator: TagFieldValidators.slug,
        onChanged: onSlugChanged,
      ),
      if (showSlugHint) ...[
        context.ui.spacing.gap(AppSpacing.xs),
        AppText(TagsKeys.slugLatinHint, type: AppTextType.bodySmall),
      ],
      if (onRegenerateSlug != null) ...[
        context.ui.spacing.gap(AppSpacing.xs),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppButton(
            TagsKeys.regenerateSlug,
            variant: AppButtonVariant.text,
            onPressed: onRegenerateSlug,
          ),
        ),
      ],
    ],
  );
}
