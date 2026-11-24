import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/color/color_name_keys.dart';
import 'package:accounting_software/app/core/foundation/color/color_name_resolver.dart';

/// Keeps HEX-based name suggestions separate from the editor's manual input.
class ColorNameAutofill {
  String? _lastAutoName;
  bool _manualName = false;
  bool _updatingName = false;
  bool _resolvedInitialName = false;

  String? get suggestedName => _lastAutoName;

  String? _suggestion(BuildContext context, String? hex) {
    final resolved = ColorNameResolver.resolve(hex);
    if (resolved == null) return null;
    return ColorNameKeys.values
        .firstWhere((key) => key.name == resolved.name)
        .tr(context: context);
  }

  void resolveInitial(
    BuildContext context, {
    required TextEditingController name,
    required String? hex,
  }) {
    if (_resolvedInitialName) return;
    _resolvedInitialName = true;
    _lastAutoName = _suggestion(context, hex);
    if (name.text.trim().isEmpty && _lastAutoName != null) {
      _setAutoName(name, _lastAutoName!);
    } else {
      _manualName =
          name.text.trim().isNotEmpty && name.text.trim() != _lastAutoName;
    }
  }

  void onNameChanged(String value) {
    if (_updatingName) return;
    _manualName = value.trim().isNotEmpty && value.trim() != _lastAutoName;
  }

  void onHexChanged(
    BuildContext context, {
    required TextEditingController name,
    required String hex,
  }) {
    final suggestion = _suggestion(context, hex);
    if (!_manualName &&
        (name.text.trim().isEmpty || name.text.trim() == _lastAutoName) &&
        suggestion != null) {
      _setAutoName(name, suggestion);
    }
    if (suggestion != null) _lastAutoName = suggestion;
  }

  void _setAutoName(TextEditingController name, String value) {
    _updatingName = true;
    name.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _updatingName = false;
  }
}
