import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_system_form/size_system_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_system_form/size_system_form_effect.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/dialogs/size_system_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/widgets/size_system_editor_fields.dart';

class SizeSystemEditorDialog extends StatefulWidget {
  const SizeSystemEditorDialog({super.key, this.system});

  final SizeSystem? system;

  @override
  State<SizeSystemEditorDialog> createState() => _SizeSystemEditorDialogState();
}

class _SizeSystemEditorDialogState extends State<SizeSystemEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  bool _active = true;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _description => _fields['description'];

  @override
  void initState() {
    super.initState();
    final system = widget.system;
    _initialActive = system?.isActive ?? true;
    _active = _initialActive;
    _fields = CrudEditorFields(
      initialValues: {
        'name': system?.name ?? '',
        'code': system?.code ?? '',
        'description': system?.description ?? '',
      },
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _save() => context.read<SizeSystemFormCubit>().save(
    id: widget.system?.id,
    draft: SizeSystemDraft(
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
        SizeSystemFormCubit,
        SizeSystemFormStatus,
        SizeSystemFormEffect
      >(
        cubit: context.read<SizeSystemFormCubit>(),
        fields: _fields,
        mode: widget.system == null ? CrudEditorMode.add : CrudEditorMode.edit,
        labels: sizeSystemEditorLabels,
        isSaving: (status) => status == SizeSystemFormStatus.saving,
        outcome: (effect) => switch (effect) {
          SizeSystemSavedEffect() => const CrudEditorSuccess(),
          SizeSystemSaveFailedEffect(:final messageKey) => CrudEditorFailure(
            messageKey,
          ),
        },
        onSave: _save,
        extraDirty: _active != _initialActive,
        onReset: () {
          if (_active != _initialActive) {
            setState(() => _active = _initialActive);
          }
        },
        builder: (context, scope) => SizeSystemEditorFields(
          name: _name,
          code: _code,
          description: _description,
          active: _active,
          onChanged: (_) => scope.clearFailure(),
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
