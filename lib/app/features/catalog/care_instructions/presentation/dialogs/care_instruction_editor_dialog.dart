import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instruction_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/localization/care_instructions_keys.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/widgets/care_instruction_field_validators.dart';

class CareInstructionEditorDialog extends StatefulWidget {
  const CareInstructionEditorDialog({super.key, this.item});
  final CareInstruction? item;

  @override
  State<CareInstructionEditorDialog> createState() =>
      _CareInstructionEditorDialogState();
}

class _CareInstructionEditorDialogState
    extends State<CareInstructionEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  late final CareType _initialType;
  bool _active = true;
  CareType _selectedType = CareType.washing;

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
    _initialType = item?.careType ?? CareType.washing;
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

  void _resetExternalFields() => setState(() {
    _active = _initialActive;
    _selectedType = _initialType;
  });

  Future<void> _save() => context.read<CareInstructionFormCubit>().save(
    id: widget.item?.id,
    draft: CareInstructionDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      careType: _selectedType,
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
        CareInstructionFormCubit,
        CareInstructionFormState,
        CareInstructionFormEffect
      >(
        cubit: context.read<CareInstructionFormCubit>(),
        fields: _fields,
        mode: widget.item == null ? CrudEditorMode.add : CrudEditorMode.edit,
        labels: const CrudEditorLabels(
          addTitle: CareInstructionsKeys.add,
          editTitle: CareInstructionsKeys.edit,
          duplicateTitle: CareInstructionsKeys.edit,
          subtitle: CareInstructionsKeys.description,
          save: CareInstructionsKeys.save,
          cancel: CareInstructionsKeys.cancel,
        ),
        isSaving: (status) => status is CareInstructionFormSaving,
        extraDirty: _extraDirty,
        onReset: _resetExternalFields,
        outcome: (effect) => switch (effect) {
          CareInstructionSavedEffect() => const CrudEditorSuccess(),
          CareInstructionSaveFailedEffect(:final messageKey) =>
            CrudEditorFailure(messageKey),
        },
        onSave: _save,
        builder: (context, scope) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<CareType>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                label: AppText(CareInstructionsKeys.careType),
              ),
              validator: (value) => value == null
                  ? CareInstructionsKeys.required.tr(context: context)
                  : null,
              items: [
                for (final type in CareType.values)
                  DropdownMenuItem(
                    value: type,
                    child: AppText(_careTypeKey(type)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            AppTextField(
              controller: _name,
              labelKey: CareInstructionsKeys.name,
              validator: CareInstructionFieldValidators.name,
              onChanged: (_) => scope.clearFailure(),
            ),
            AppTextField(
              controller: _code,
              labelKey: CareInstructionsKeys.code,
              textDirection: TextDirection.ltr,
              validator: CareInstructionFieldValidators.code,
              onChanged: (_) => scope.clearFailure(),
            ),
            AppTextField(
              controller: _description,
              labelKey: CareInstructionsKeys.description,
              maxLines: 3,
            ),
            AppSwitch(
              value: _active,
              labelKey: _active
                  ? CareInstructionsKeys.active
                  : CareInstructionsKeys.inactive,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      );

  AppKey _careTypeKey(CareType type) => switch (type) {
    CareType.washing => CareInstructionsKeys.washing,
    CareType.drying => CareInstructionsKeys.drying,
    CareType.ironing => CareInstructionsKeys.ironing,
    CareType.bleaching => CareInstructionsKeys.bleaching,
    CareType.dryCleaning => CareInstructionsKeys.dryCleaning,
  };
}
