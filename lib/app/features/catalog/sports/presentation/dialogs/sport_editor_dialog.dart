import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sport_form/sport_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sport_form/sport_form_effect.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/dialogs/sport_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/widgets/sport_editor_fields_view.dart';

export 'sport_duplicate_seed.dart' show sportDuplicateSeed;

class SportEditorDialog extends StatefulWidget {
  const SportEditorDialog({
    super.key,
    this.sport,
    this.seed,
    this.duplicate = false,
  }) : assert(!duplicate || (sport == null && seed != null));

  final Sport? sport;
  final SportDraft? seed;
  final bool duplicate;

  @override
  State<SportEditorDialog> createState() => _SportEditorDialogState();
}

class _SportEditorDialogState extends State<SportEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  bool? _active;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _description => _fields['description'];
  TextEditingController get _sortOrder => _fields['sortOrder'];

  @override
  void initState() {
    super.initState();
    final sport = widget.sport;
    final seed = widget.seed;
    _initialActive = seed?.isActive ?? sport?.isActive ?? true;
    _fields = CrudEditorFields(
      initialValues: {
        'name': seed?.name ?? sport?.name ?? '',
        'code': seed?.code ?? sport?.code ?? '',
        'description': seed?.description ?? sport?.description ?? '',
        'sortOrder': (seed?.sortOrder ?? sport?.sortOrder ?? 0).toString(),
      },
    );
    if (widget.duplicate) {
      for (final controller in [_name, _code]) {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      }
    }
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _save() => context.read<SportFormCubit>().save(
    id: widget.sport?.id,
    draft: SportDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      isActive: widget.sport == null
          ? (_active ?? _initialActive)
          : (_active ?? _initialActive) == _initialActive
          ? null
          : _active,
    ),
  );

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<SportFormCubit, SportFormStatus, SportFormEffect>(
        cubit: context.read<SportFormCubit>(),
        fields: _fields,
        mode: widget.duplicate
            ? CrudEditorMode.duplicate
            : widget.sport == null
            ? CrudEditorMode.add
            : CrudEditorMode.edit,
        labels: sportEditorLabels,
        isSaving: (status) => status == SportFormStatus.saving,
        outcome: (effect) => switch (effect) {
          SportSavedEffect() => const CrudEditorSuccess(),
          SportSaveFailedEffect(:final messageKey) => CrudEditorFailure(
            messageKey,
          ),
        },
        onSave: _save,
        builder: (context, scope) => SportEditorFieldsView(
          name: _name,
          code: _code,
          description: _description,
          sortOrder: _sortOrder,
          isActive: _active ?? _initialActive,
          onActiveChanged: (value) => setState(() => _active = value),
          onChanged: scope.clearFailure,
        ),
      );
}
