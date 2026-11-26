import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_form/product_type_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_form/product_type_form_effect.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/dialogs/product_type_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';

class ProductTypeEditorDialog extends StatefulWidget {
  const ProductTypeEditorDialog({
    super.key,
    this.productType,
  });

  final ProductType? productType;

  @override
  State<ProductTypeEditorDialog> createState() =>
      _ProductTypeEditorDialogState();
}

class _ProductTypeEditorDialogState extends State<ProductTypeEditorDialog> {
  late final CrudEditorFields _fields;
  late final bool _initialActive;
  bool _active = true;

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _description => _fields['description'];
  TextEditingController get _sortOrder => _fields['sortOrder'];

  @override
  void initState() {
    super.initState();
    final item = widget.productType;
    _initialActive = item?.isActive ?? true;
    _active = _initialActive;
    _fields = CrudEditorFields(
      initialValues: {
        'name': item?.name ?? '',
        'code': item?.code ?? '',
        'description': item?.description ?? '',
        'sortOrder': (item?.sortOrder ?? 0).toString(),
      },
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _save() => context.read<ProductTypeFormCubit>().save(
    id: widget.productType?.id,
    draft: ProductTypeDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      description: _description.text.trim(),
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      isActive: widget.productType == null ||
              _active != widget.productType!.isActive
          ? _active
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<ProductTypeFormCubit, ProductTypeFormStatus,
        ProductTypeFormEffect>(
        cubit: context.read<ProductTypeFormCubit>(),
        fields: _fields,
        mode: widget.productType == null
            ? CrudEditorMode.add
            : CrudEditorMode.edit,
        labels: productTypeEditorLabels,
        isSaving: (status) => status == ProductTypeFormStatus.saving,
        outcome: (effect) => switch (effect) {
          ProductTypeSavedEffect() => const CrudEditorSuccess(),
          ProductTypeSaveFailedEffect(:final messageKey) =>
            CrudEditorFailure(messageKey),
        },
        onSave: _save,
        extraDirty: _active != _initialActive,
        onReset: () {
          if (_active != _initialActive) {
            setState(() => _active = _initialActive);
          }
        },
        builder: (context, scope) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _name,
              labelKey: ProductTypesKeys.nameLabel,
              validator: (value) => AppValidator.validate(
                value,
                [ValidationRule.required, ValidationRule.maxLength],
                params: {ValidationRule.maxLength: 150},
                customKeys: {
                  ValidationRule.maxLength: ProductTypesKeys.nameTooLong,
                },
              ),
              onChanged: (_) => scope.clearFailure(),
              textCapitalization: TextCapitalization.words,
            ),
            context.ui.spacing.gap(AppSpacing.md),
            AppTextField(
              controller: _code,
              labelKey: ProductTypesKeys.codeLabel,
              readOnly: widget.productType?.codeLocked ?? false,
              validator: (value) => AppValidator.validate(
                value,
                [ValidationRule.required, ValidationRule.maxLength],
                params: {ValidationRule.maxLength: 50},
                customKeys: {
                  ValidationRule.maxLength: ProductTypesKeys.codeTooLong,
                },
              ),
              onChanged: (_) => scope.clearFailure(),
              textDirection: TextDirection.ltr,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
            ),
            context.ui.spacing.gap(AppSpacing.md),
            AppTextField(
              controller: _description,
              labelKey: ProductTypesKeys.descriptionLabel,
              maxLines: 3,
              onChanged: (_) => scope.clearFailure(),
            ),
            context.ui.spacing.gap(AppSpacing.md),
            AppTextField(
              controller: _sortOrder,
              labelKey: ProductTypesKeys.sortOrderLabel,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => AppValidator.validate(
                value,
                [ValidationRule.required, ValidationRule.pattern],
                params: {ValidationRule.pattern: RegExp(r'^\\d+
              onChanged: (_) => scope.clearFailure(),
            ),
            context.ui.spacing.gap(AppSpacing.md),
            AppSwitch(
              value: _active,
              labelKey: widget.productType == null
                  ? ProductTypesKeys.activeOnCreate
                  : ProductTypesKeys.active,
              onChanged: scope.busy
                  ? null
                  : (value) {
                      setState(() => _active = value);
                      scope.clearFailure();
                    },
            ),
          ],
        ),
      );
}
)},
                customKeys: {
                  ValidationRule.pattern: ProductTypesKeys.sortOrderInvalid,
                },
              ),
              onChanged: (_) => scope.clearFailure(),
            ),
            context.ui.spacing.gap(AppSpacing.md),
            AppSwitch(
              value: _active,
              labelKey: widget.productType == null
                  ? ProductTypesKeys.activeOnCreate
                  : ProductTypesKeys.active,
              onChanged: scope.busy
                  ? null
                  : (value) {
                      setState(() => _active = value);
                      scope.clearFailure();
                    },
            ),
          ],
        ),
      );
}
