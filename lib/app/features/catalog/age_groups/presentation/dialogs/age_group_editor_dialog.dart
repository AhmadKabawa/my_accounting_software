import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_draft.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/cubit/age_group_form/age_group_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/cubit/age_group_form/age_group_form_effect.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/dialogs/age_group_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/widgets/age_group_editor_fields.dart';

class AgeGroupEditorDialog extends StatefulWidget {
  const AgeGroupEditorDialog({super.key, this.ageGroup});
  final AgeGroup? ageGroup;
  @override
  State<AgeGroupEditorDialog> createState() => _AgeGroupEditorDialogState();
}

class _AgeGroupEditorDialogState extends State<AgeGroupEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  bool _active = true;
  TextEditingController get _name => _fields['name'];
  TextEditingController get _min => _fields['minAge'];
  TextEditingController get _max => _fields['maxAge'];
  TextEditingController get _order => _fields['sortOrder'];
  @override
  void initState() {
    super.initState();
    final x = widget.ageGroup;
    _initialActive = x?.isActive ?? true;
    _active = _initialActive;
    _fields = CrudEditorFields(
      initialValues: {
        'name': x?.name ?? '',
        'minAge': x?.minAge?.toString() ?? '',
        'maxAge': x?.maxAge?.toString() ?? '',
        'sortOrder': (x?.sortOrder ?? 0).toString(),
      },
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  int? _optional(TextEditingController c) {
    final s = c.text.trim();
    return s.isEmpty ? null : int.parse(s);
  }

  Future<void> _save() => context.read<AgeGroupFormCubit>().save(
    id: widget.ageGroup?.id,
    draft: AgeGroupDraft(
      name: _name.text.trim(),
      minAge: _optional(_min),
      maxAge: _optional(_max),
      sortOrder: int.parse(_order.text.trim()),
      isActive: widget.ageGroup == null
          ? _active
          : (_active == _initialActive ? null : _active),
    ),
  );
  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<
        AgeGroupFormCubit,
        AgeGroupFormStatus,
        AgeGroupFormEffect
      >(
        cubit: context.read<AgeGroupFormCubit>(),
        fields: _fields,
        mode: widget.ageGroup == null
            ? CrudEditorMode.add
            : CrudEditorMode.edit,
        labels: ageGroupEditorLabels,
        isSaving: (s) => s == AgeGroupFormStatus.saving,
        outcome: (e) => switch (e) {
          AgeGroupSavedEffect() => const CrudEditorSuccess(),
          AgeGroupSaveFailedEffect(:final messageKey) => CrudEditorFailure(
            messageKey,
          ),
        },
        onSave: _save,
        extraDirty: _active != _initialActive,
        onReset: () {
          if (_active != _initialActive)
            setState(() => _active = _initialActive);
        },
        builder: (context, scope) => AgeGroupEditorFields(
          name: _name,
          minAge: _min,
          maxAge: _max,
          sortOrder: _order,
          active: _active,
          onChanged: (_) => scope.clearFailure(),
          onActiveChanged: scope.busy
              ? null
              : (v) {
                  setState(() => _active = v);
                  scope
                    ..clearFailure()
                    ..changed();
                },
        ),
      );
}
