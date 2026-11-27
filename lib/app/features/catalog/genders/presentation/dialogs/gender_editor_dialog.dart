import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_draft.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/gender_form/gender_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/gender_form/gender_form_effect.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/dialogs/gender_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/widgets/gender_editor_fields.dart';

class GenderEditorDialog extends StatefulWidget {
  const GenderEditorDialog({super.key, this.gender});
  final Gender? gender;

  @override
  State<GenderEditorDialog> createState() => _GenderEditorDialogState();
}

class _GenderEditorDialogState extends State<GenderEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  bool _active = true;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _order => _fields['sortOrder'];

  @override
  void initState() {
    super.initState();
    final gender = widget.gender;
    _initialActive = gender?.isActive ?? true;
    _active = _initialActive;
    _fields = CrudEditorFields(initialValues: {
      'name': gender?.name ?? '',
      'code': gender?.code ?? '',
      'sortOrder': (gender?.sortOrder ?? 0).toString(),
    });
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _save() => context.read<GenderFormCubit>().save(
    id: widget.gender?.id,
    draft: GenderDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      sortOrder: int.parse(_order.text.trim()),
      isActive: widget.gender == null ? _active : (_active == _initialActive ? null : _active),
    ),
  );

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<GenderFormCubit, GenderFormStatus, GenderFormEffect>(
        cubit: context.read<GenderFormCubit>(),
        fields: _fields,
        mode: widget.gender == null ? CrudEditorMode.add : CrudEditorMode.edit,
        labels: genderEditorLabels,
        isSaving: (status) => status == GenderFormStatus.saving,
        outcome: (effect) => switch (effect) {
          GenderSavedEffect() => const CrudEditorSuccess(),
          GenderSaveFailedEffect(:final messageKey) => CrudEditorFailure(messageKey),
        },
        onSave: _save,
        extraDirty: _active != _initialActive,
        onReset: () {
          if (_active != _initialActive) setState(() => _active = _initialActive);
        },
        builder: (context, scope) => GenderEditorFields(
          name: _name,
          code: _code,
          sortOrder: _order,
          active: _active,
          onNameChanged: (_) => scope.clearFailure(),
          onActiveChanged: scope.busy ? null : (value) {
            setState(() => _active = value);
            scope..clearFailure()..changed();
          },
        ),
      );
}
