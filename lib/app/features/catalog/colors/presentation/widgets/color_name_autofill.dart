import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/color/color_name_keys.dart';
import 'package:accounting_software/app/core/foundation/color/color_name_resolver.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Generates an editable name and abbreviation whenever a color is selected.
class ColorNameAutofill {
  String? _lastAutoName;
  bool _resolvedInitialName = false;

  String? get suggestedName => _lastAutoName;

  String? _suggestion(BuildContext context, ColorName? color) {
    if (color == null) return null;
    return ColorNameKeys.values
        .firstWhere((key) => key.name == color.name)
        .tr(context: context);
  }

  void resolveInitial(
    BuildContext context, {
    required TextEditingController name,
    required TextEditingController code,
    required String? hex,
  }) {
    if (_resolvedInitialName) return;
    _resolvedInitialName = true;
    final color = ColorNameResolver.resolve(hex);
    _lastAutoName = _suggestion(context, color);
    if (name.text.trim().isEmpty && code.text.trim().isEmpty && color != null) {
      _apply(context, name: name, code: code, color: color, hex: hex!);
    }
  }

  void onHexChanged(
    BuildContext context, {
    required TextEditingController name,
    required TextEditingController code,
    required String hex,
  }) {
    final color = ColorNameResolver.resolve(hex);
    if (color == null) return;
    _apply(context, name: name, code: code, color: color, hex: hex);
  }

  void _apply(
    BuildContext context, {
    required TextEditingController name,
    required TextEditingController code,
    required ColorName color,
    required String hex,
  }) {
    _lastAutoName = _suggestion(context, color);
    if (_lastAutoName != null) _setText(name, _lastAutoName!);
    _setText(code, _generatedCode(color, hex));
  }

  String _generatedCode(ColorName color, String hex) {
    final digits = hex.replaceFirst('#', '').substring(0, 6);
    final rgb = int.parse(digits, radix: 16);
    final red = (rgb >> 16) & 0xff;
    final green = (rgb >> 8) & 0xff;
    final blue = rgb & 0xff;
    final colorValue = (red + green + blue).toString().padLeft(3, '0');
    final abbreviation = color.name.substring(0, 3).toUpperCase();
    return '$abbreviation-$colorValue';
  }

  void _setText(TextEditingController controller, String value) {
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}
