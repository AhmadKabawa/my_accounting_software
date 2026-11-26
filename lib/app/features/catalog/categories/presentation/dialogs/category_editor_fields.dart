import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload_cubit.dart';
import 'package:accounting_software/app/core/platform/file_drop/file_drop_target.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/sections/category_image_section.dart';

class CategoryEditorFields extends StatelessWidget {
  const CategoryEditorFields({
    super.key,
    required this.cubit,
    required this.scope,
    required this.imageUploader,
    required this.onImageBusyChanged,
    this.imagePicker,
    this.dropTargetAdapter,
  });

  final CategoryFormCubit cubit;
  final CrudEditorScope scope;
  final ImageUploader imageUploader;
  final ValueChanged<bool> onImageBusyChanged;
  final ImagePickerPort? imagePicker;
  final FileDropTargetAdapter? dropTargetAdapter;

  @override
  Widget build(BuildContext context) {
    final state = cubit.state;
    final parentOptions = cubit.parentOptions;
    CategoryNode? selectedParent;
    for (final option in parentOptions) {
      if (option.id == state.parentId) {
        selectedParent = option;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(CategoriesKeys.identitySection, type: AppTextType.titleSmall),
        context.ui.spacing.gap(AppSpacing.sm),
        AppTextField(
          controller: scope.fields['name'],
          labelKey: CategoriesKeys.categoryName,
          enabled: !scope.busy,
          validator: (_) => state.errorFor('name'),
          onChanged: (value) {
            cubit.nameChanged(value);
            if (!cubit.state.slugManuallyEdited) {
              scope.fields['slug'].text = cubit.state.slug;
            }
            scope.clearFailure();
          },
        ),
        _fieldError(
          context,
          state.errorFor('name'),
          state.name.trim().isNotEmpty,
        ),
        context.ui.spacing.gap(AppSpacing.md),
        AppTextField(
          controller: scope.fields['slug'],
          labelKey: CategoriesKeys.slug,
          hintKey: CategoriesKeys.slugHint,
          textDirection: TextDirection.ltr,
          enabled: !scope.busy,
          validator: (_) => state.errorFor('slug'),
          suffix: AppIconButton(
            AppIcons.refresh,
            tooltipKey: CategoriesKeys.regenerateSlug,
            onPressed: scope.busy
                ? null
                : () {
                    cubit.regenerateSlug();
                    scope.fields['slug'].text = cubit.state.slug;
                    scope.clearFailure();
                  },
            size: AppButtonSize.small,
          ),
          onChanged: (value) {
            cubit.slugChanged(value);
            scope.clearFailure();
          },
        ),
        _fieldError(
          context,
          state.errorFor('slug'),
          state.name.trim().isNotEmpty || state.slug.trim().isNotEmpty,
        ),
        context.ui.spacing.gap(AppSpacing.md),
        AppTextField(
          controller: scope.fields['description'],
          labelKey: CategoriesKeys.description,
          enabled: !scope.busy,
          maxLines: 3,
          onChanged: (value) {
            cubit.descriptionChanged(value);
            scope.clearFailure();
          },
        ),
        context.ui.spacing.gap(AppSpacing.md),
        CategoryImageSection(
          image: scope.fields['image'],
          categoryName: scope.fields['name'],
          uploader: imageUploader,
          picker: imagePicker,
          dropTargetAdapter: dropTargetAdapter,
          onChanged: (value) {
            cubit.imageChanged(value ?? '');
            scope.fields['image'].text = value ?? '';
            scope.clearFailure();
            scope.changed();
          },
          onBusyChanged: onImageBusyChanged,
        ),
        _fieldError(
          context,
          state.errorFor('image'),
          state.image.trim().isNotEmpty,
        ),
        context.ui.spacing.gap(AppSpacing.md),
        AppTextField(
          controller: scope.fields['sortOrder'],
          labelKey: CategoriesKeys.sortOrder,
          hintKey: CategoriesKeys.sortOrderHint,
          enabled: !scope.busy,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (_) => state.errorFor('sortOrder'),
          onChanged: (value) {
            cubit.sortOrderChanged(value);
            scope.clearFailure();
          },
        ),
        _fieldError(
          context,
          state.errorFor('sortOrder'),
          state.sortOrder.trim().isNotEmpty,
        ),
        context.ui.spacing.gap(AppSpacing.md),
        AppSwitch(
          value: state.isActive,
          labelKey: cubit.isNew ? CategoriesKeys.activeOnCreate : CategoriesKeys.active,
          onChanged: scope.busy ? null : cubit.setActive,
        ),
        context.ui.spacing.gap(AppSpacing.md),

        context.ui.spacing.gap(AppSpacing.lg),
        AppText(CategoriesKeys.placementSection, type: AppTextType.titleSmall),
        context.ui.spacing.gap(AppSpacing.sm),
        SearchableDropdown<CategoryNode>(
          options: parentOptions,
          labelKey: CategoriesKeys.parent,
          optionLabel: cubit.parentOptionLabel,
          optionSubtitle: (node) => node.category.slug,
          value: selectedParent,
          clearable: true,
          mode: SearchableDropdownMode.panel,
          allOptionLabel: CategoriesKeys.noParent,
          onChanged: (node) {
            if (scope.busy) return;
            cubit.setParent(node?.id);
            scope.clearFailure();
            scope.changed();
          },
        ),
        context.ui.spacing.gap(AppSpacing.xs),
        AppText(
          CategoriesKeys.parentHint,
          type: AppTextType.bodySmall,
          color: context.ui.theme.colors.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _fieldError(BuildContext context, String? message, bool visible) {
    if (!visible || message == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsetsDirectional.only(top: context.ui.spacing.xs),
      child: AppText.raw(
        message,
        type: AppTextType.bodySmall,
        color: context.ui.theme.colors.error,
      ),
    );
  }
}
