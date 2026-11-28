import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_draft.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/cubit/materials_form/material_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/localization/materials_keys.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/material_type_labels.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/widgets/material_field_validators.dart';

class MaterialEditorDialog extends StatefulWidget {
  const MaterialEditorDialog({super.key, this.item});
  final CatalogMaterial? item;

  @override
  State<MaterialEditorDialog> createState() => _MaterialEditorDialogState();
}

class _MaterialEditorDialogState extends State<MaterialEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  late final MaterialType? _initialType;
  bool _active = true;
  MaterialType? _selectedType;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _description => _fields['description'];

  bool get _extraDirty =>
      _active != _initialActive || _selectedType != _initialType;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _initialActive = item?.isActive ?? true;
    _initialType = item?.materialType;
    _active = _initialActive;
    _selectedType = _initialType;
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
      _selectedType = _initialType;
    });
  }

  Future<void> _save() => context.read<MaterialFormCubit>().save(
    id: widget.item?.id,
    draft: MaterialDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      materialType: _selectedType,
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      isActive: widget.item == null || _active != _initialActive
          ? _active
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<
        MaterialFormCubit,
        MaterialFormState,
        MaterialFormEffect
      >(
        cubit: context.read<MaterialFormCubit>(),
        fields: _fields,
        mode: widget.item == null ? CrudEditorMode.add : CrudEditorMode.edit,
        labels: const CrudEditorLabels(
          addTitle: MaterialsKeys.add,
          editTitle: MaterialsKeys.edit,
          duplicateTitle: MaterialsKeys.duplicate,
          subtitle: MaterialsKeys.description,
          save: MaterialsKeys.save,
          cancel: MaterialsKeys.cancel,
        ),
        isSaving: (status) => status is MaterialFormSaving,
        extraDirty: _extraDirty,
        onReset: _resetExternalFields,
        outcome: (effect) => switch (effect) {
          MaterialSavedEffect() => const CrudEditorSuccess(),
          MaterialSaveFailedEffect(:final messageKey) => CrudEditorFailure(
            messageKey,
          ),
        },
        onSave: _save,
        builder: (context, scope) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<MaterialType?>(
              initialValue: _selectedType,
              decoration: InputDecoration(label: AppText(MaterialsKeys.type)),
              items: [
                DropdownMenuItem<MaterialType?>(
                  value: null,
                  child: AppText(MaterialsKeys.notSpecified),
                ),
                for (final type in MaterialType.values)
                  DropdownMenuItem<MaterialType?>(
                    value: type,
                    child: AppText(materialTypeLabel(type)),
                  ),
              ],
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            AppTextField(
              controller: _name,
              labelKey: MaterialsKeys.materialName,
              validator: MaterialFieldValidators.name,
              onChanged: (_) => scope.clearFailure(),
            ),
            AppTextField(
              controller: _code,
              labelKey: MaterialsKeys.code,
              textDirection: TextDirection.ltr,
              validator: MaterialFieldValidators.code,
              onChanged: (_) => scope.clearFailure(),
            ),
            AppTextField(
              controller: _description,
              labelKey: MaterialsKeys.description,
              maxLines: 3,
            ),
            AppSwitch(
              value: _active,
              labelKey: _active ? MaterialsKeys.active : MaterialsKeys.inactive,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      );
}
