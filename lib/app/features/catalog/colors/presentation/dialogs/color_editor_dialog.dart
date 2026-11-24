import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_editor/crud_editor.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_effect.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/dialogs/color_editor_labels.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_editor_fields_view.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_field_validators.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_name_autofill.dart';

export 'color_duplicate_seed.dart' show colorDuplicateSeed;

class ColorEditorDialog extends StatefulWidget {
  const ColorEditorDialog({
    super.key,
    this.color,
    this.seed,
    this.duplicate = false,
  }) : assert(!duplicate || (color == null && seed != null));

  final CatalogColor? color;
  final CatalogColorDraft? seed;
  final bool duplicate;

  @override
  State<ColorEditorDialog> createState() => _ColorEditorDialogState();
}

class _ColorEditorDialogState extends State<ColorEditorDialog> {
  late final CrudEditorFields _fields;
  final _nameAutofill = ColorNameAutofill();

  TextEditingController get _name => _fields['name'];
  TextEditingController get _code => _fields['code'];
  TextEditingController get _hex => _fields['hex'];
  TextEditingController get _sortOrder => _fields['sortOrder'];

  @override
  void initState() {
    super.initState();
    final color = widget.color;
    final seed = widget.seed;
    _fields = CrudEditorFields(initialValues: {
      'name': seed?.name ?? color?.name ?? '',
      'code': seed?.code ?? color?.code ?? '',
      'hex': seed?.hexCode ?? color?.hexCode ?? '',
      'sortOrder': (seed?.sortOrder ?? color?.sortOrder ?? 0).toString(),
    });
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameAutofill.resolveInitial(
      context,
      name: _name,
      hex: widget.color?.hexCode ?? widget.seed?.hexCode,
    );
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  Future<void> _save() => context.read<ColorFormCubit>().save(
    id: widget.color?.id,
    draft: CatalogColorDraft(
      name: _name.text.trim(),
      code: _code.text.trim(),
      hexCode: HexColor.normalize(ColorFieldValidators.withHash(_hex.text)),
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      isActive: widget.seed?.isActive ?? widget.color?.isActive ?? true,
    ),
  );

  @override
  Widget build(BuildContext context) =>
      CrudEditorDialog<ColorFormCubit, ColorFormStatus, ColorFormEffect>(
        cubit: context.read<ColorFormCubit>(),
        fields: _fields,
        mode: widget.duplicate
            ? CrudEditorMode.duplicate
            : widget.color == null
            ? CrudEditorMode.add
            : CrudEditorMode.edit,
        labels: colorEditorLabels,
        isSaving: (status) => status == ColorFormStatus.saving,
        outcome: (effect) => switch (effect) {
          ColorSavedEffect() => const CrudEditorSuccess(),
          ColorSaveFailedEffect(:final messageKey) =>
            CrudEditorFailure(messageKey),
        },
        onSave: _save,
        builder: (context, scope) => ColorEditorFieldsView(
          name: _name,
          code: _code,
          hex: _hex,
          sortOrder: _sortOrder,
          suggestedName: _nameAutofill.suggestedName,
          onNameChanged: () {
            _nameAutofill.onNameChanged(_name.text);
            scope.clearFailure();
          },
          onChanged: scope.clearFailure,
          onHexChanged: () {
            _nameAutofill.onHexChanged(context, name: _name, hex: _hex.text);
            scope.clearFailure();
            scope.changed();
          },
        ),
      );
}
