import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload_cubit.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brand_details_section.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brand_identity_section.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brand_logo_section.dart';

/// Feature-owned field layout for the shared CRUD editor lifecycle.
class BrandEditorFieldsView extends StatelessWidget {
  const BrandEditorFieldsView({
    super.key,
    required this.name,
    required this.slug,
    required this.logo,
    required this.logoUploader,
    required this.onLogoBusyChanged,
    this.logoPicker,
    required this.description,
    required this.onNameChanged,
    required this.onSlugChanged,
    required this.showSlugHint,
    required this.nameAutofocus,
    required this.onRegenerateSlug,
    required this.active,
    required this.activeLabelKey,
    required this.onActiveChanged,
  });

  final TextEditingController name;
  final TextEditingController slug;
  final TextEditingController logo;
  final ImageUploader logoUploader;
  final ValueChanged<bool> onLogoBusyChanged;
  final ImagePickerPort? logoPicker;
  final TextEditingController description;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onSlugChanged;
  final bool showSlugHint;
  final bool nameAutofocus;
  final VoidCallback? onRegenerateSlug;
  final bool active;
  final AppKey activeLabelKey;
  final ValueChanged<bool>? onActiveChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      BrandIdentitySection(
        name: name,
        slug: slug,
        onNameChanged: onNameChanged,
        onSlugChanged: onSlugChanged,
        showSlugHint: showSlugHint,
        nameAutofocus: nameAutofocus,
        onRegenerateSlug: onRegenerateSlug,
      ),
      BrandLogoSection(
        logo: logo,
        brandName: name,
        uploader: logoUploader,
        picker: logoPicker,
        onBusyChanged: onLogoBusyChanged,
      ),
      BrandDetailsSection(description: description),
      context.ui.spacing.gap(AppSpacing.md),
      AppSwitch(
        value: active,
        labelKey: activeLabelKey,
        onChanged: onActiveChanged,
      ),
    ],
  );
}
