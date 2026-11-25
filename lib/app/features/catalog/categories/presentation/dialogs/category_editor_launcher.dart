import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor_fields.dart';
import 'package:accounting_software/app/features/catalog/categories/di/categories_di.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_effect.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/dialogs/category_editor_fields.dart';

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
      builder: (context, _) =>
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
                CategoryEditorFields(cubit: cubit, scope: scope),
          ),
    );
  }
}

