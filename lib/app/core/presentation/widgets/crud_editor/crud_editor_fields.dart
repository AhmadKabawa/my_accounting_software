import 'package:flutter/material.dart';

/// Owns the text controllers for one CRUD editor.
///
/// Keys are field names (for example, `name` or `slug`). Dirty comparison
/// follows the editor save normalization: surrounding whitespace is ignored.
class CrudEditorFields extends ChangeNotifier {
  CrudEditorFields({required Map<String, String> initialValues})
    : _initialValues = Map.unmodifiable(initialValues),
      _controllers = {
        for (final entry in initialValues.entries)
          entry.key: TextEditingController(text: entry.value),
      } {
    for (final controller in _controllers.values) {
      controller.addListener(_onFieldChanged);
    }
  }

  final Map<String, String> _initialValues;
  final Map<String, TextEditingController> _controllers;

  TextEditingController operator [](String name) {
    final controller = _controllers[name];
    if (controller == null) {
      throw ArgumentError.value(name, 'name', 'Unknown CRUD editor field');
    }
    return controller;
  }

  Iterable<String> get names => _controllers.keys;

  bool get dirty {
    for (final entry in _controllers.entries) {
      final initial = _initialValues[entry.key];
      if (initial == null || entry.value.text.trim() != initial.trim()) {
        return true;
      }
    }
    return false;
  }

  void _onFieldChanged() => notifyListeners();

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller
        ..removeListener(_onFieldChanged)
        ..dispose();
    }
    super.dispose();
  }
}
