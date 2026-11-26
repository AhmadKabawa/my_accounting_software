import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_draft.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/unit_form/unit_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/unit_form/unit_form_effect.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/dialogs/unit_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/localization/units_keys.dart';

class UnitEditorDialog extends StatefulWidget {
  const UnitEditorDialog({super.key, this.unit});
  final CatalogUnit? unit;

  @override
  State<UnitEditorDialog> createState() => _UnitEditorDialogState();
}

class _UnitEditorDialogState extends State<UnitEditorDialog> {
  late final CrudEditorFields _fields;
  late final UnitType _initialType;
  late final bool _initialActive;
  late UnitType _type;
  late bool _active;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _symbol => _fields['symbol'];

  @override
  void initState() {
    super.initState();
    final unit = widget.unit;
    _initialType = unit?.type ?? UnitType.piece;
    _type = _initialType;
    _initialActive = unit?.isActive ?? true;
    _active = _initialActive;
    _fields = CrudEditorFields(
      initialValues: {
        'name': unit?.name ?? '',
        'symbol': unit?.symbol ?? '',
      },
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _save() {
    final unit = widget.unit;
    return context.read<UnitFormCubit>().save(
      id: unit?.id,
      draft: UnitDraft(
        name: _name.text.trim(),
        symbol: _symbol.text.trim(),
        type: _type,
        isActive: unit == null || _active != unit.isActive ? _active : null,
      ),
    );
  }

  AppKey _typeLabel(UnitType type) => switch (type) {
    UnitType.weight => UnitsKeys.weight,
    UnitType.length => UnitsKeys.length,
    UnitType.volume => UnitsKeys.volume,
    UnitType.piece => UnitsKeys.piece,
  };

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<UnitFormCubit, UnitFormStatus, UnitFormEffect>(
        cubit: context.read<UnitFormCubit>(),
        fields: _fields,
        mode: widget.unit == null ? CrudEditorMode.add : CrudEditorMode.edit,
        labels: unitEditorLabels,
        isSaving: (status) => status == UnitFormStatus.saving,
        outcome: (effect) => switch (effect) {
          UnitSavedEffect() => const CrudEditorSuccess(),
          UnitSaveFailedEffect(:final messageKey) =>
            CrudEditorFailure(messageKey),
        },
        onSave: _save,
        extraDirty: _type != _initialType || _active != _initialActive,
        onReset: () {
          setState(() {
            _type = _initialType;
            _active = _initialActive;
          });
        },
        builder: (context, scope) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _name,
              labelKey: UnitsKeys.unitName,
              onChanged: (_) => scope.clearFailure(),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return UnitsKeys.required.tr(context: context);
                if (text.length > 100) {
                  return UnitsKeys.nameTooLong.tr(context: context);
                }
                return null;
              },
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            AppTextField(
              controller: _symbol,
              labelKey: UnitsKeys.symbol,
              onChanged: (_) => scope.clearFailure(),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return UnitsKeys.required.tr(context: context);
                if (text.length > 20) {
                  return UnitsKeys.symbolTooLong.tr(context: context);
                }
                return null;
              },
              textDirection: TextDirection.ltr,
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            SearchableDropdown<UnitType>(
              options: UnitType.values,
              labelKey: UnitsKeys.type,
              optionLabel: (type) => _typeLabel(type).tr(context: context),
              value: _type,
              clearable: false,
              onChanged: (type) {
                if (type == null) return;
                setState(() => _type = type);
                scope.clearFailure();
              },
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            AppSwitch(
              value: _active,
              labelKey: widget.unit == null
                  ? UnitsKeys.activeOnCreate
                  : UnitsKeys.active,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      );
}
