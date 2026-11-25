import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload_cubit.dart';
import 'package:accounting_software/app/core/platform/file_drop/file_drop_target.dart';
import 'package:accounting_software/app/core/localization/keys/image_keys.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image_upload/app_image_upload_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_logo_thumb/app_logo_thumb.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/brand_logo_policy.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

/// Thin feature adapter: binds the shared field to the brand logo policy and copy.
class BrandLogoSection extends StatelessWidget {
  const BrandLogoSection({
    super.key,
    required this.logo,
    required this.brandName,
    required this.uploader,
    required this.onBusyChanged,
    this.picker,
    this.dropTargetAdapter,
  });

  final TextEditingController logo;
  final TextEditingController brandName;
  final ImageUploader uploader;
  final ValueChanged<bool> onBusyChanged;
  final ImagePickerPort? picker;
  final FileDropTargetAdapter? dropTargetAdapter;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([logo, brandName]),
    builder: (context, _) => AppImageUploadField(
      value: logo.text,
      onChanged: (value) => logo.text = value ?? '',
      label: brandName.text,
      policy: brandLogoPolicy,
      uploader: uploader,
      labels: const AppImageUploadFieldLabels(
        sectionTitle: BrandsKeys.logoSection,
        upload: BrandsKeys.uploadLogo,
        replace: BrandsKeys.replaceLogo,
        remove: BrandsKeys.removeLogo,
        dropHint: ImageKeys.dropHint,
      ),
      previewSize: AppLogoSize.small,
      picker: picker,
      dropTargetAdapter: dropTargetAdapter,
      onBusyChanged: onBusyChanged,
    ),
  );
}
