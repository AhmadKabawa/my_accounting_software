import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/widgets/attribute_editor_lookup_fields.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_draft.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_lookup_choices.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_form/attribute_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_lookups/attribute_lookups_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_lookups/attribute_lookups_state.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/dialogs/attribute_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';

class AttributeEditorDialog extends StatefulWidget {
  const AttributeEditorDialog({
    super.key,
    this.attribute,
    this.duplicate = false,
  });
  final CatalogAttribute? attribute;
  final bool duplicate;
  @override
  State<AttributeEditorDialog> createState() => _AttributeEditorDialogState();
}

class _AttributeEditorDialogState extends State<AttributeEditorDialog> {
  static const _nameMax = 150;
  static const _codeMax = 80;
  late final CrudEditorFields _fields;
  late final AttributeDataType _initialType;
  late final int? _initialUnitId;
  late final int? _initialOptionSetId;
  late final bool _initialFilterable;
  late final bool _initialActive;
  late AttributeDataType _type;
  late int? _unitId;
  late int? _optionSetId;
  late bool _filterable;
  late bool _active;
  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];

  @override
  void initState() {
    super.initState();
    final item = widget.attribute;
    _initialType = item?.dataType ?? AttributeDataType.text;
    _type = _initialType;
    _initialUnitId = item?.unitId;
    _initialOptionSetId = item?.optionSetId;
    _unitId = _initialUnitId;
    _optionSetId = _initialOptionSetId;
    _initialFilterable = item?.isFilterable ?? false;
    _filterable = _initialFilterable;
    _initialActive = widget.duplicate ? true : item?.isActive ?? true;
    _active = _initialActive;
    final code = widget.duplicate && item != null
        ? _copyCode(item.code)
        : item?.code ?? '';
    _fields = CrudEditorFields(
      initialValues: {
        'name': widget.duplicate && item != null
            ? '${item.name} copy'
            : item?.name ?? '',
        'code': code,
      },
    );
  }

  String _copyCode(String source) {
    final suffix = '-${DateTime.now().microsecondsSinceEpoch}-copy';
    final prefix = source.length > _codeMax - suffix.length
        ? source.substring(0, _codeMax - suffix.length)
        : source;
    return '$prefix$suffix';
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  AppKey _typeLabel(AttributeDataType type) => switch (type) {
    AttributeDataType.text => AttributesKeys.text,
    AttributeDataType.number => AttributesKeys.number,
    AttributeDataType.boolean => AttributesKeys.boolean,
    AttributeDataType.date => AttributesKeys.date,
    AttributeDataType.json => AttributesKeys.json,
    AttributeDataType.option => AttributesKeys.option,
  };

  bool get _locked => widget.attribute?.isInUse ?? false;

  Future<void> _save() => context.read<AttributeFormCubit>().save(
    id: widget.duplicate ? null : widget.attribute?.id,
    draft: AttributeDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      dataType: _type,
      unitId: _type == AttributeDataType.number ? _unitId : null,
      optionSetId: _type == AttributeDataType.option ? _optionSetId : null,
      isFilterable: _filterable,
      isActive:
          widget.attribute == null ||
              widget.duplicate ||
              _active != widget.attribute!.isActive
          ? _active
          : null,
    ),
  );


  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AttributeLookupsCubit, AttributeLookupsState>(
        builder: (context, lookups) =>
            CrudEditorDialog<
              AttributeFormCubit,
              AttributeFormStatus,
              AttributeFormEffect
            >(
              cubit: context.read<AttributeFormCubit>(),
              fields: _fields,
              mode: widget.duplicate
                  ? CrudEditorMode.duplicate
                  : widget.attribute == null
                  ? CrudEditorMode.add
                  : CrudEditorMode.edit,
              labels: attributeEditorLabels,
              isSaving: (status) => status == AttributeFormStatus.saving,
              outcome: (effect) => switch (effect) {
                AttributeSavedEffect() => const CrudEditorSuccess(),
                AttributeSaveFailedEffect(:final messageKey) =>
                  CrudEditorFailure(messageKey),
              },
              onSave: _save,
              extraBusy: lookups.loading,
              extraDirty:
                  _type != _initialType ||
                  _unitId != _initialUnitId ||
                  _optionSetId != _initialOptionSetId ||
                  _filterable != _initialFilterable ||
                  _active != _initialActive,
              onReset: () => setState(() {
                _type = _initialType;
                _unitId = _initialUnitId;
                _optionSetId = _initialOptionSetId;
                _filterable = _initialFilterable;
                _active = _initialActive;
              }),
              builder: (context, scope) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _name,
                    labelKey: AttributesKeys.attributeName,
                    onChanged: (_) => scope.clearFailure(),
                    validator: (v) => AppValidator.validate(
                      v,
                      [ValidationRule.required, ValidationRule.maxLength],
                      params: {ValidationRule.maxLength: _nameMax},
                      customKeys: {
                        ValidationRule.maxLength: AttributesKeys.nameTooLong,
                      },
                    ),
                  ),
                  context.ui.spacing.gap(AppSpacing.sm),
                  AppTextField(
                    controller: _code,
                    labelKey: AttributesKeys.code,
                    textDirection: TextDirection.ltr,
                    onChanged: (_) => scope.clearFailure(),
                    validator: (v) => AppValidator.validate(
                      v,
                      [ValidationRule.required, ValidationRule.maxLength],
                      params: {ValidationRule.maxLength: _codeMax},
                      customKeys: {
                        ValidationRule.maxLength: AttributesKeys.codeTooLong,
                      },
                    ),
                  ),
                  context.ui.spacing.gap(AppSpacing.sm),
                  SearchableDropdown<AttributeDataType>(
                    options: AttributeDataType.values,
                    labelKey: AttributesKeys.dataType,
                    optionLabel: (v) => _typeLabel(v).tr(context: context),
                    value: _type,
                    enabled: !_locked,
                    clearable: false,
                    mode: SearchableDropdownMode.panel,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _type = v;
                        _unitId = null;
                        _optionSetId = null;
                      });
                      scope.clearFailure();
                    },
                  ),
                  if (_locked) ...[
                    context.ui.spacing.gap(AppSpacing.xs),
                    AppText(AttributesKeys.locked),
                  ],
                  if (_type == AttributeDataType.number) ...[
                    context.ui.spacing.gap(AppSpacing.sm),
                    AttributeUnitPicker(attribute: widget.attribute, selectedId: _unitId, state: lookups, onChanged: (id) => setState(() => _unitId = id)),
                  ],
                  if (_type == AttributeDataType.option) ...[
                    context.ui.spacing.gap(AppSpacing.sm),
                    AttributeOptionSetPicker(attribute: widget.attribute, selectedId: _optionSetId, state: lookups, locked: _locked, onChanged: (id) => setState(() => _optionSetId = id)),
                  ],
                  context.ui.spacing.gap(AppSpacing.sm),
                  AppSwitch(
                    value: _filterable,
                    labelKey: AttributesKeys.filterable,
                    onChanged: (v) => setState(() => _filterable = v),
                  ),
                  AppSwitch(
                    value: _active,
                    labelKey: AttributesKeys.active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                ],
              ),
            ),
      );
}
