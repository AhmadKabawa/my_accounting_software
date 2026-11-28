import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/localization/keys/date_picker_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_date_picker_field/app_date_picker_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_draft.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/cubit/seasons_form/season_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/localization/seasons_keys.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/widgets/season_field_validators.dart';

class SeasonEditorDialog extends StatefulWidget {
  const SeasonEditorDialog({super.key, this.item});
  final CatalogSeason? item;

  @override
  State<SeasonEditorDialog> createState() => _SeasonEditorDialogState();
}

class _SeasonEditorDialogState extends State<SeasonEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  late final SeasonType? _initialType;
  late final DateTime? _initialStartDate;
  late final DateTime? _initialEndDate;
  bool _active = true;
  SeasonType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _description => _fields['description'];

  bool get _extraDirty =>
      _active != _initialActive ||
      _selectedType != _initialType ||
      _startDate != _initialStartDate ||
      _endDate != _initialEndDate;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _initialActive = item?.isActive ?? true;
    _initialType = item?.seasonType;
    _initialStartDate = item?.startDate;
    _initialEndDate = item?.endDate;
    _active = _initialActive;
    _selectedType = _initialType;
    _startDate = _initialStartDate;
    _endDate = _initialEndDate;
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
      _startDate = _initialStartDate;
      _endDate = _initialEndDate;
    });
  }

  Future<void> _save() => context.read<SeasonFormCubit>().save(
    id: widget.item?.id,
    draft: SeasonDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      seasonType: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      isActive: widget.item == null || _active != _initialActive
          ? _active
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dateRangeError = AppValidator.validateDateRange(
      start: _startDate,
      end: _endDate,
    );
    return CrudEditorDialog<
      SeasonFormCubit,
      SeasonFormState,
      SeasonFormEffect
    >(
      cubit: context.read<SeasonFormCubit>(),
      fields: _fields,
      mode: widget.item == null ? CrudEditorMode.add : CrudEditorMode.edit,
      labels: const CrudEditorLabels(
        addTitle: SeasonsKeys.add,
        editTitle: SeasonsKeys.edit,
        duplicateTitle: SeasonsKeys.duplicate,
        subtitle: SeasonsKeys.description,
        save: SeasonsKeys.save,
        cancel: SeasonsKeys.cancel,
      ),
      isSaving: (status) => status is SeasonFormSaving,
      extraDirty: _extraDirty,
      onReset: _resetExternalFields,
      outcome: (effect) => switch (effect) {
        SeasonSavedEffect() => const CrudEditorSuccess(),
        SeasonSaveFailedEffect(:final messageKey) => CrudEditorFailure(
          messageKey,
        ),
      },
      onSave: _save,
      builder: (context, scope) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<SeasonType?>(
            initialValue: _selectedType,
            decoration: InputDecoration(label: AppText(SeasonsKeys.type)),
            items: [
              DropdownMenuItem<SeasonType?>(
                value: null,
                child: AppText(SeasonsKeys.notSpecified),
              ),
              for (final type in SeasonType.values)
                DropdownMenuItem<SeasonType?>(
                  value: type,
                  child: AppText(switch (type) {
                    SeasonType.summer => SeasonsKeys.summer,
                    SeasonType.winter => SeasonsKeys.winter,
                    SeasonType.spring => SeasonsKeys.spring,
                    SeasonType.autumn => SeasonsKeys.autumn,
                  }),
                ),
            ],
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          AppDatePickerField(
            label: SeasonsKeys.startDate,
            value: _startDate,
            clearable: true,
            onChanged: (value) => setState(() => _startDate = value),
          ),
          AppDatePickerField(
            label: SeasonsKeys.endDate,
            value: _endDate,
            clearable: true,
            errorText: dateRangeError,
            validator: (_) => dateRangeError,
            onChanged: (value) => setState(() => _endDate = value),
          ),
          AppTextField(
            controller: _name,
            labelKey: SeasonsKeys.seasonName,
            validator: SeasonFieldValidators.name,
            onChanged: (_) => scope.clearFailure(),
          ),
          AppTextField(
            controller: _code,
            labelKey: SeasonsKeys.code,
            textDirection: TextDirection.ltr,
            validator: SeasonFieldValidators.code,
            onChanged: (_) => scope.clearFailure(),
          ),
          AppTextField(
            controller: _description,
            labelKey: SeasonsKeys.description,
            maxLines: 3,
          ),
          AppSwitch(
            value: _active,
            labelKey: _active ? SeasonsKeys.active : SeasonsKeys.inactive,
            onChanged: (value) => setState(() => _active = value),
          ),
        ],
      ),
    );
  }
}
