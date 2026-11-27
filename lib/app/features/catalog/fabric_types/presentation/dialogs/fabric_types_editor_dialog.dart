import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_draft.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/cubit/fabric_types_form/fabric_type_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/localization/fabric_types_keys.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/widgets/fabric_types_field_validators.dart';

class FabricTypeEditorDialog extends StatefulWidget {
  const FabricTypeEditorDialog({super.key, this.item});
  final CatalogFabricType? item;

  @override
  State<FabricTypeEditorDialog> createState() => _FabricTypeEditorDialogState();
}

class _FabricTypeEditorDialogState extends State<FabricTypeEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  late final FabricCategory? _initialCategory;
  bool _active = true;
  FabricCategory? _selectedCategory;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _description => _fields['description'];

  bool get _extraDirty =>
      _active != _initialActive ||
      _selectedCategory != _initialCategory;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _initialActive = item?.isActive ?? true;
    _initialCategory = item?.fabricCategory;
    _active = _initialActive;
    _selectedCategory = _initialCategory;
    _fields = CrudEditorFields(
      initialValues: {
        'name': item?.name ?? '',
        'code': item?.code ?? '',
        'description': item?.description ?? '',
      },
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  void _resetExternalFields() {
    setState(() {
      _active = _initialActive;
      _selectedCategory = _initialCategory;
    });
  }

  Future<void> _save() => context.read<FabricTypeFormCubit>().save(
    id: widget.item?.id,
    draft: FabricTypeDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      fabricCategory: _selectedCategory,
      isNamedFabric: widget.item?.isNamedFabric ?? false,
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      isActive: widget.item == null || _active != _initialActive ? _active : null,
    ),
  );

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<
        FabricTypeFormCubit,
        FabricTypeFormStatus,
        FabricTypeFormEffect
      >(
        cubit: context.read<FabricTypeFormCubit>(),
        fields: _fields,
        mode: widget.item == null ? CrudEditorMode.add : CrudEditorMode.edit,
        labels: const CrudEditorLabels(
          addTitle: FabricTypesKeys.add,
          editTitle: FabricTypesKeys.edit,
          duplicateTitle: FabricTypesKeys.duplicate,
          subtitle: FabricTypesKeys.description,
          save: FabricTypesKeys.save,
          cancel: FabricTypesKeys.cancel,
        ),
        isSaving: (status) => status == FabricTypeFormStatus.saving,
        extraDirty: _extraDirty,
        onReset: _resetExternalFields,
        outcome: (effect) => switch (effect) {
          FabricTypeSavedEffect() => const CrudEditorSuccess(),
          FabricTypeSaveFailedEffect(:final messageKey) =>
            CrudEditorFailure(messageKey),
        },
        onSave: _save,
        builder: (context, scope) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<FabricCategory?>(
              value: _selectedCategory,
              decoration: InputDecoration(
                label: AppText(FabricTypesKeys.category),
              ),
              items: [
                DropdownMenuItem<FabricCategory?>(
                  value: null,
                  child: AppText(
                    FabricTypesKeys.notSpecified.tr(context: context),
                  ),
                ),
                for (final category in FabricCategory.values)
                  DropdownMenuItem<FabricCategory?>(
                    value: category,
                    child: AppText(
                      switch (category) {
                        FabricCategory.knit =>
                          FabricTypesKeys.knit.tr(context: context),
                        FabricCategory.woven =>
                          FabricTypesKeys.woven.tr(context: context),
                        FabricCategory.fleece =>
                          FabricTypesKeys.fleece.tr(context: context),
                      },
                    ),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _selectedCategory = value),
            ),
            AppTextField(
              controller: _name,
              labelKey: FabricTypesKeys.fabricTypeName,
              validator: FabricTypeFieldValidators.name,
              onChanged: (_) => scope.clearFailure(),
            ),
            AppTextField(
              controller: _code,
              labelKey: FabricTypesKeys.code,
              textDirection: TextDirection.ltr,
              validator: FabricTypeFieldValidators.code,
              onChanged: (_) => scope.clearFailure(),
            ),
            AppTextField(
              controller: _description,
              labelKey: FabricTypesKeys.description,
              maxLines: 3,
            ),
            AppSwitch(
              value: _active,
              labelKey: _active ? FabricTypesKeys.active : FabricTypesKeys.inactive,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      );
}
