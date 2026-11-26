import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload_cubit.dart';
import 'package:accounting_software/app/core/localization/keys/image_keys.dart';
import 'package:accounting_software/app/core/platform/file_drop/file_drop_target.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image_upload/app_image_upload_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_logo_thumb/app_logo_thumb.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/category_image_policy.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

/// Thin adapter between the shared image uploader and category-specific copy.
class CategoryImageSection extends StatelessWidget {
  const CategoryImageSection({
    super.key,
    required this.image,
    required this.categoryName,
    required this.uploader,
    required this.onChanged,
    required this.onBusyChanged,
    this.picker,
    this.dropTargetAdapter,
  });

  final TextEditingController image;
  final TextEditingController categoryName;
  final ImageUploader uploader;
  final ValueChanged<String?> onChanged;
  final ValueChanged<bool> onBusyChanged;
  final ImagePickerPort? picker;
  final FileDropTargetAdapter? dropTargetAdapter;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([image, categoryName]),
    builder: (context, _) => AppImageUploadField(
      value: image.text.trim().isEmpty ? null : image.text,
      onChanged: onChanged,
      label: categoryName.text,
      policy: categoryImagePolicy,
      uploader: uploader,
      labels: const AppImageUploadFieldLabels(
        sectionTitle: CategoriesKeys.imageSection,
        upload: CategoriesKeys.uploadImage,
        replace: CategoriesKeys.replaceImage,
        remove: CategoriesKeys.removeImage,
        dropHint: ImageKeys.dropHint,
      ),
      previewSize: AppLogoSize.small,
      picker: picker,
      dropTargetAdapter: dropTargetAdapter,
      onBusyChanged: onBusyChanged,
    ),
  );
}
