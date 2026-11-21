import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_effect.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/color_appearance_section.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/color_identity_section.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_field_validators.dart';

/// Opens the color editor and owns the form Cubit lifetime.
Future<bool?> showColorEditor(BuildContext context, {CatalogColor? color}) =>
    showAppFormDialog<bool>(
      context,
      (_) => BlocProvider(
        create: (_) => sl<ColorFormCubit>(),
        child: ColorEditorDialog(color: color),
      ),
    );

/// Add/edit dialog for one color.
class ColorEditorDialog extends StatefulWidget {
  const ColorEditorDialog({super.key, this.color});

  final CatalogColor? color;

  @override
  State<ColorEditorDialog> createState() => _ColorEditorDialogState();
}

class _ColorEditorDialogState extends State<ColorEditorDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _hex;
  late final TextEditingController _sortOrder;
  late final List<String> _initial;
  AppKey? _failure;

  List<TextEditingController> get _controllers => [
    _name,
    _code,
    _hex,
    _sortOrder,
  ];

  bool get _dirty {
    final now = [for (final c in _controllers) c.text];
    for (var i = 0; i < now.length; i++) {
      if (now[i] != _initial[i]) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    final color = widget.color;
    _initial = [
      color?.name ?? '',
      color?.code ?? '',
      color?.hexCode ?? '',
      color == null ? '0' : '${color.sortOrder}',
    ];
    _name = TextEditingController(text: _initial[0]);
    _code = TextEditingController(text: _initial[1]);
    _hex = TextEditingController(text: _initial[2]);
    _sortOrder = TextEditingController(text: _initial[3]);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() => _failure = null);
  }

  Future<void> _save() async {
    if (_key.currentState?.validate() != true) return;
    await context.read<ColorFormCubit>().save(
      id: widget.color?.id,
      draft: CatalogColorDraft(
        name: _name.text.trim(),
        code: _code.text.trim(),
        hexCode: ColorFieldValidators.withHash(_hex.text),
        sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ColorFormCubit, ColorFormStatus>(
        builder: (context, status) {
          final busy = status == ColorFormStatus.saving;
          return BlocEffectListener<ColorFormEffect, ColorFormCubit>(
            onEffect: (context, effect) {
              switch (effect) {
                case ColorSavedEffect():
                  Navigator.of(context).pop(true);
                case ColorSaveFailedEffect(:final messageKey):
                  setState(() => _failure = messageKey);
              }
            },
            child: AppFormDialog(
              titleKey: widget.color == null ? ColorsKeys.add : ColorsKeys.edit,
              subtitleKey: ColorsKeys.editorSubtitle,
              saveLabelKey: ColorsKeys.save,
              cancelLabelKey: ColorsKeys.cancel,
              busy: busy,
              saveEnabled: !busy,
              dirty: _dirty,
              errorKey: _failure,
              onSave: _save,
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ColorIdentitySection(
                      name: _name,
                      code: _code,
                      sortOrder: _sortOrder,
                      onChanged: _onChanged,
                    ),
                    context.ui.spacing.gap(AppSpacing.md),
                    ColorAppearanceSection(hex: _hex, onChanged: _onChanged),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
