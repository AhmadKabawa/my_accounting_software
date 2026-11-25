import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor_fields.dart';
import 'package:accounting_software/app/features/catalog/categories/di/categories_di.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_node.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_effect.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_state.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

Future<bool?> showCategoryEditor(
  BuildContext context, {
  Category? category,
  CategoryTree? tree,
  int? initialParentId,
}) => showAppFormDialog<bool>(
  context,
  (_) => BlocProvider(
    create: (_) => sl<CategoryFormCubit>(
      param1: CategoryFormArgs(
        category: category,
        tree: tree,
        initialParentId: initialParentId,
      ),
    ),
    child: CategoryEditorDialog(category: category),
  ),
);

class CategoryEditorDialog extends StatefulWidget {
  const CategoryEditorDialog({super.key, this.category});

  final Category? category;

  @override
  State<CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends State<CategoryEditorDialog> {
  late final CrudEditorFields _fields;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _fields = CrudEditorFields(
      initialValues: {
        'name': category?.name ?? '',
        'slug': category?.slug ?? '',
        'description': category?.description ?? '',
        'image': category?.image ?? '',
        'sortOrder': '${category?.sortOrder ?? 0}',
      },
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryFormCubit>();
    return BlocBuilder<CategoryFormCubit, CategoryFormState>(
      bloc: cubit,
      builder: (context, state) =>
          CrudEditorDialog<
            CategoryFormCubit,
            CategoryFormState,
            CategoryFormEffect
          >(
            cubit: cubit,
            fields: _fields,
            mode: widget.category == null
                ? CrudEditorMode.add
                : CrudEditorMode.edit,
            labels: const CrudEditorLabels(
              addTitle: CategoriesKeys.add,
              editTitle: CategoriesKeys.edit,
              duplicateTitle: CategoriesKeys.add,
              subtitle: CategoriesKeys.editorSubtitle,
              save: CategoriesKeys.save,
              cancel: CategoriesKeys.cancel,
            ),
            isSaving: (value) => value.saving,
            outcome: (effect) => switch (effect) {
              CategorySavedEffect() => const CrudEditorSuccess(),
              CategorySaveFailedEffect(:final messageKey) => CrudEditorFailure(
                messageKey,
              ),
            },
            onSave: cubit.save,
            extraDirty: cubit.parentChanged,
            onReset: cubit.reset,
            builder: (dialogContext, scope) =>
                _CategoryEditorFields(cubit: cubit, scope: scope),
          ),
    );
  }
}

class _CategoryEditorFields extends StatelessWidget {
  const _CategoryEditorFields({required this.cubit, required this.scope});

  final CategoryFormCubit cubit;
  final CrudEditorScope scope;

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
        AppTextField(
          controller: scope.fields['image'],
          labelKey: CategoriesKeys.image,
          hintKey: CategoriesKeys.imageHint,
          textDirection: TextDirection.ltr,
          enabled: !scope.busy,
          validator: (_) => state.errorFor('image'),
          onChanged: (value) {
            cubit.imageChanged(value);
            scope.clearFailure();
          },
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
