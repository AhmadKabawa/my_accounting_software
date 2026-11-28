import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/gender_option.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/size_group_form/size_group_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/size_group_form/size_group_form_effect.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/dialogs/size_group_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/widgets/size_group_editor_fields.dart';

class SizeGroupEditorDialog extends StatefulWidget {
  const SizeGroupEditorDialog({
    super.key,
    required this.sizeSystemId,
    required this.genders,
    this.group,
  });

  final int sizeSystemId;
  final List<GenderOption> genders;
  final SizeGroup? group;

  @override
  State<SizeGroupEditorDialog> createState() => _SizeGroupEditorDialogState();
}

class _SizeGroupEditorDialogState extends State<SizeGroupEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  late final int? _initialGenderId;
  bool _active = true;
  int? _genderId;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _description => _fields['description'];

  bool get _extraDirty =>
      _active != _initialActive || _genderId != _initialGenderId;

  @override
  void initState() {
    super.initState();
    final group = widget.group;
    _initialActive = group?.isActive ?? true;
    _initialGenderId = group?.genderId;
    _active = _initialActive;
    _genderId = _initialGenderId;
    _fields = CrudEditorFields(
      initialValues: {
        'name': group?.name ?? '',
        'code': group?.code ?? '',
        'description': group?.description ?? '',
      },
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _save() => context.read<SizeGroupFormCubit>().save(
    id: widget.group?.id,
    draft: SizeGroupDraft(
      sizeSystemId: widget.group?.sizeSystemId ?? widget.sizeSystemId,
      genderId: _genderId,
      name: _name.text.trim(),
      code: _code.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      isActive: _active,
    ),
  );

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<
        SizeGroupFormCubit,
        SizeGroupFormStatus,
        SizeGroupFormEffect
      >(
        cubit: context.read<SizeGroupFormCubit>(),
        fields: _fields,
        mode: widget.group == null ? CrudEditorMode.add : CrudEditorMode.edit,
        labels: sizeGroupEditorLabels,
        isSaving: (status) => status == SizeGroupFormStatus.saving,
        outcome: (effect) => switch (effect) {
          SizeGroupSavedEffect() => const CrudEditorSuccess(),
          SizeGroupSaveFailedEffect(:final messageKey) => CrudEditorFailure(
            messageKey,
          ),
        },
        onSave: _save,
        extraDirty: _extraDirty,
        onReset: () {
          if (_extraDirty) {
            setState(() {
              _active = _initialActive;
              _genderId = _initialGenderId;
            });
          }
        },
        builder: (context, scope) => SizeGroupEditorFields(
          name: _name,
          code: _code,
          description: _description,
          genders: widget.genders,
          genderId: _genderId,
          active: _active,
          onChanged: (_) => scope.clearFailure(),
          onGenderChanged: scope.busy
              ? null
              : (value) {
                  setState(() => _genderId = value);
                  scope
                    ..clearFailure()
                    ..changed();
                },
          onActiveChanged: scope.busy
              ? null
              : (value) {
                  setState(() => _active = value);
                  scope
                    ..clearFailure()
                    ..changed();
                },
        ),
      );
}
