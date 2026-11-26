import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_form/option_set_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_form/option_set_form_effect.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/dialogs/option_set_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';

class OptionSetEditorDialog extends StatefulWidget {
  const OptionSetEditorDialog({super.key, this.optionSet});
  final OptionSet? optionSet;

  @override
  State<OptionSetEditorDialog> createState() => _OptionSetEditorDialogState();
}

class _OptionSetEditorDialogState extends State<OptionSetEditorDialog> {
  late final CrudEditorFields _fields;
  late final OptionSelectionType _initialSelection;
  late final bool _initialActive;
  late OptionSelectionType _selection;
  late bool _active;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];

  @override
  void initState() {
    super.initState();
    final set = widget.optionSet;
    _initialSelection = set?.selectionType ?? OptionSelectionType.single;
    _selection = _initialSelection;
    _initialActive = set?.isActive ?? true;
    _active = _initialActive;
    _fields = CrudEditorFields(
      initialValues: {'name': set?.name ?? '', 'code': set?.code ?? ''},
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _save() => context.read<OptionSetFormCubit>().save(
    id: widget.optionSet?.id,
    draft: OptionSetDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      selectionType: _selection,
      isActive: widget.optionSet == null || _active != widget.optionSet!.isActive
          ? _active
          : null,
    ),
  );

  AppKey _selectionLabel(OptionSelectionType value) => switch (value) {
    OptionSelectionType.single => OptionSetsKeys.single,
    OptionSelectionType.multiple => OptionSetsKeys.multiple,
  };

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<OptionSetFormCubit, OptionSetFormStatus, OptionSetFormEffect>(
        cubit: context.read<OptionSetFormCubit>(),
        fields: _fields,
        mode: widget.optionSet == null ? CrudEditorMode.add : CrudEditorMode.edit,
        labels: optionSetEditorLabels,
        isSaving: (status) => status == OptionSetFormStatus.saving,
        outcome: (effect) => switch (effect) {
          OptionSetSavedEffect() => const CrudEditorSuccess(),
          OptionSetSaveFailedEffect(:final messageKey) => CrudEditorFailure(messageKey),
        },
        onSave: _save,
        extraDirty: _selection != _initialSelection || _active != _initialActive,
        onReset: () => setState(() {
          _selection = _initialSelection;
          _active = _initialActive;
        }),
        builder: (context, scope) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _name,
              labelKey: OptionSetsKeys.optionSetName,
              onChanged: (_) => scope.clearFailure(),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? OptionSetsKeys.required.tr(context: context)
                  : null,
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            AppTextField(
              controller: _code,
              labelKey: OptionSetsKeys.code,
              textDirection: TextDirection.ltr,
              onChanged: (_) => scope.clearFailure(),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? OptionSetsKeys.required.tr(context: context)
                  : null,
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            SearchableDropdown<OptionSelectionType>(
              options: OptionSelectionType.values,
              labelKey: OptionSetsKeys.selectionType,
              optionLabel: (value) => _selectionLabel(value).tr(context: context),
              value: _selection,
              clearable: false,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selection = value);
                scope.clearFailure();
              },
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            AppSwitch(
              value: _active,
              labelKey: widget.optionSet == null
                  ? OptionSetsKeys.activeOnCreate
                  : OptionSetsKeys.active,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      );
}
