import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/foundation/color/color_name_resolver.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_effect.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/core/foundation/color/color_name_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/color_appearance_section.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/color_identity_section.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_field_validators.dart';

/// Opens the color editor and owns the form Cubit lifetime.
Future<bool?> showColorEditor(
  BuildContext context, {
  CatalogColor? color,
  bool duplicate = false,
}) {
  final seed = duplicate && color != null ? colorDuplicateSeed(context, color) : null;
  return showAppFormDialog<bool>(
    context,
    (_) => BlocProvider(
      create: (_) => sl<ColorFormCubit>(),
      child: ColorEditorDialog(
        color: duplicate ? null : color,
        seed: seed,
        duplicate: duplicate,
      ),
    ),
  );
}

CatalogColorDraft colorDuplicateSeed(BuildContext context, CatalogColor source) =>
    CatalogColorDraft(
      name: '${source.name} ${ColorsKeys.duplicateSuffix.tr(context: context)}',
      code: '${source.code}${ColorsKeys.duplicateCodeSuffix.tr(context: context)}',
      hexCode: source.hexCode,
      sortOrder: source.sortOrder,
    );

/// Add/edit dialog for one color.
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
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _hex;
  late final TextEditingController _sortOrder;
  late final List<String> _initial;
  AppKey? _failure;
  String? _lastAutoName;
  bool _manualName = false;
  bool _updatingName = false;
  bool _resolvedInitialName = false;

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
    final seed = widget.seed;
    _initial = [
      seed?.name ?? color?.name ?? '',
      seed?.code ?? color?.code ?? '',
      seed?.hexCode ?? color?.hexCode ?? '',
      seed != null ? '${seed.sortOrder}' : color == null ? '0' : '${color.sortOrder}',
    ];
    _name = TextEditingController(text: _initial[0]);
    _code = TextEditingController(text: _initial[1]);
    _hex = TextEditingController(text: _initial[2]);
    _sortOrder = TextEditingController(text: _initial[3]);
    if (widget.duplicate) {
      _name.selection = TextSelection(baseOffset: 0, extentOffset: _name.text.length);
      _code.selection = TextSelection(baseOffset: 0, extentOffset: _code.text.length);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedInitialName) return;
    _resolvedInitialName = true;
    _lastAutoName = _suggestedName(context, widget.color?.hexCode);
    if (_name.text.trim().isEmpty && _lastAutoName != null) {
      _setAutoName(_lastAutoName!);
    } else {
      _manualName =
          _name.text.trim().isNotEmpty && _name.text.trim() != _lastAutoName;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _suggestedName(BuildContext context, String? hex) {
    final resolved = ColorNameResolver.resolve(hex);
    if (resolved == null) return null;
    return ColorNameKeys.values
        .firstWhere((key) => key.name == resolved.name)
        .tr(context: context);
  }

  void _setAutoName(String value) {
    _updatingName = true;
    _name.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _updatingName = false;
  }

  void _onNameChanged() {
    if (_updatingName) return;
    _manualName =
        _name.text.trim().isNotEmpty && _name.text.trim() != _lastAutoName;
  }

  void _onHexChanged() {
    final suggestion = _suggestedName(context, _hex.text);
    if (!_manualName &&
        (_name.text.trim().isEmpty || _name.text.trim() == _lastAutoName) &&
        suggestion != null) {
      _setAutoName(suggestion);
    }
    if (suggestion != null) _lastAutoName = suggestion;
    _onChanged();
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
        hexCode: HexColor.normalize(ColorFieldValidators.withHash(_hex.text)),
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
              titleKey: widget.duplicate
                  ? ColorsKeys.duplicateTitle
                  : widget.color == null
                      ? ColorsKeys.add
                      : ColorsKeys.edit,
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
                      suggestedName: _lastAutoName,
                      onChanged: _onChanged,
                      onNameChanged: _onNameChanged,
                    ),
                    context.ui.spacing.gap(AppSpacing.md),
                    ColorAppearanceSection(hex: _hex, onChanged: _onHexChanged),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
