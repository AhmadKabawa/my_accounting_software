import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/localization/keys/date_picker_keys.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload_cubit.dart';
import 'package:accounting_software/app/core/platform/file_drop/file_drop_target.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_date_picker_field/app_date_picker_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_draft.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/cubit/collections_form/collection_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/localization/collections_keys.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/widgets/collection_field_validators.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/sections/collection_image_section.dart';

class CollectionEditorDialog extends StatefulWidget {
  const CollectionEditorDialog({
    super.key,
    this.item,
    required this.imageUploader,
    this.imagePicker,
    this.dropTargetAdapter,
  });

  final CatalogCollection? item;
  final ImageUploader imageUploader;
  final ImagePickerPort? imagePicker;
  final FileDropTargetAdapter? dropTargetAdapter;

  @override
  State<CollectionEditorDialog> createState() => _CollectionEditorDialogState();
}

class _CollectionEditorDialogState extends State<CollectionEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  late final DateTime? _initialStartDate;
  late final DateTime? _initialEndDate;
  bool _active = true;
  bool _imageBusy = false;
  DateTime? _startDate;
  DateTime? _endDate;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _description => _fields['description'];
  TextEditingController get _image => _fields['image'];

  bool get _extraDirty =>
      _active != _initialActive ||
      _startDate != _initialStartDate ||
      _endDate != _initialEndDate;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _initialActive = item?.isActive ?? true;
    _initialStartDate = item?.startDate;
    _initialEndDate = item?.endDate;
    _active = _initialActive;
    _startDate = _initialStartDate;
    _endDate = _initialEndDate;
    _fields = CrudEditorFields(
      initialValues: {
        'name': item?.name ?? '',
        'code': item?.code ?? '',
        'description': item?.description ?? '',
        'image': item?.image ?? '',
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
      _startDate = _initialStartDate;
      _endDate = _initialEndDate;
    });
  }

  Future<void> _save() => context.read<CollectionFormCubit>().save(
    id: widget.item?.id,
    draft: CollectionDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      image: _image.text.trim().isEmpty ? null : _image.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
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
      CollectionFormCubit,
      CollectionFormState,
      CollectionFormEffect
    >(
      cubit: context.read<CollectionFormCubit>(),
      fields: _fields,
      mode: widget.item == null ? CrudEditorMode.add : CrudEditorMode.edit,
      labels: const CrudEditorLabels(
        addTitle: CollectionsKeys.add,
        editTitle: CollectionsKeys.edit,
        duplicateTitle: CollectionsKeys.duplicate,
        subtitle: CollectionsKeys.description,
        save: CollectionsKeys.save,
        cancel: CollectionsKeys.cancel,
      ),
      isSaving: (status) => status is CollectionFormSaving,
      extraBusy: _imageBusy,
      extraDirty: _extraDirty,
      onReset: _resetExternalFields,
      outcome: (effect) => switch (effect) {
        CollectionSavedEffect() => const CrudEditorSuccess(),
        CollectionSaveFailedEffect(:final messageKey) => CrudEditorFailure(
          messageKey,
        ),
      },
      onSave: _save,
      builder: (context, scope) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDatePickerField(
            label: CollectionsKeys.startDate,
            value: _startDate,
            clearable: true,
            onChanged: (value) => setState(() => _startDate = value),
          ),
          AppDatePickerField(
            label: CollectionsKeys.endDate,
            value: _endDate,
            clearable: true,
            errorText: dateRangeError,
            validator: (_) => dateRangeError,
            onChanged: (value) => setState(() => _endDate = value),
          ),
          AppTextField(
            controller: _name,
            labelKey: CollectionsKeys.collectionName,
            validator: CollectionFieldValidators.name,
            onChanged: (_) => scope.clearFailure(),
          ),
          AppTextField(
            controller: _code,
            labelKey: CollectionsKeys.code,
            textDirection: TextDirection.ltr,
            validator: CollectionFieldValidators.code,
            onChanged: (_) => scope.clearFailure(),
          ),
          AppTextField(
            controller: _description,
            labelKey: CollectionsKeys.description,
            maxLines: 3,
          ),
          CollectionImageSection(
            image: _image,
            collectionName: _name,
            uploader: (upload) =>
                context.read<CollectionFormCubit>().uploadImage(upload),
            picker: widget.imagePicker,
            dropTargetAdapter: widget.dropTargetAdapter,
            onChanged: (value) {
              _image.text = value ?? '';
              scope.clearFailure();
              scope.changed();
            },
            onBusyChanged: (busy) {
              if (mounted && _imageBusy != busy) {
                setState(() => _imageBusy = busy);
              }
            },
          ),
          AppSwitch(
            value: _active,
            labelKey: _active ? CollectionsKeys.active : CollectionsKeys.inactive,
            onChanged: (value) => setState(() => _active = value),
          ),
        ],
      ),
    );
  }
}
