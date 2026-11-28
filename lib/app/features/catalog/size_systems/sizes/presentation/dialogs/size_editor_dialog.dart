import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/size_form/size_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/size_form/size_form_effect.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/dialogs/size_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/widgets/size_editor_fields.dart';

class SizeEditorDialog extends StatefulWidget {
  const SizeEditorDialog({super.key, required this.sizeGroupId, this.size});

  final int sizeGroupId;
  final CatalogSize? size;

  @override
  State<SizeEditorDialog> createState() => _SizeEditorDialogState();
}

class _SizeEditorDialogState extends State<SizeEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  bool _active = true;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _value => _fields['numericValue'];
  TextEditingController get _order => _fields['sortOrder'];

  @override
  void initState() {
    super.initState();
    final size = widget.size;
    _initialActive = size?.isActive ?? true;
    _active = _initialActive;
    _fields = CrudEditorFields(
      initialValues: {
        'name': size?.name ?? '',
        'code': size?.code ?? '',
        'numericValue': size?.numericValue?.toString() ?? '',
        'sortOrder': (size?.sortOrder ?? 0).toString(),
      },
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _save() {
    final rawValue = _value.text.trim();
    return context.read<SizeFormCubit>().save(
      id: widget.size?.id,
      draft: CatalogSizeDraft(
        sizeGroupId: widget.size?.sizeGroupId ?? widget.sizeGroupId,
        name: _name.text.trim(),
        code: _code.text.trim(),
        numericValue: rawValue.isEmpty ? null : Decimal.parse(rawValue),
        sortOrder: int.parse(_order.text.trim()),
        isActive: _active,
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<SizeFormCubit, SizeFormStatus, SizeFormEffect>(
        cubit: context.read<SizeFormCubit>(),
        fields: _fields,
        mode: widget.size == null ? CrudEditorMode.add : CrudEditorMode.edit,
        labels: sizeEditorLabels,
        isSaving: (status) => status == SizeFormStatus.saving,
        outcome: (effect) => switch (effect) {
          SizeSavedEffect() => const CrudEditorSuccess(),
          SizeSaveFailedEffect(:final messageKey) => CrudEditorFailure(
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
        builder: (context, scope) => SizeEditorFields(
          name: _name,
          code: _code,
          numericValue: _value,
          sortOrder: _order,
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
