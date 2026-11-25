import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';

/// Fills the color code from the HEX value (for example `F57C21`) until the
/// user types a code of their own; editing the HEX later keeps refreshing a
/// code that was never customised.
class ColorCodeAutofill {
  String? _lastAutoCode;
  bool _manualCode = false;
  bool _updatingCode = false;

  /// `#F57C21` / `#f57c2180` become `F57C21`; anything invalid gives null.
  static String? codeFor(String? hex) {
    final trimmed = hex?.trim() ?? '';
    final withHash = trimmed.startsWith('#') ? trimmed : '#$trimmed';
    final normalized = HexColor.normalize(withHash);
    if (!HexColor.isValid(normalized)) return null;
    return normalized!.substring(1, 7);
  }

  void resolveInitial({
    required TextEditingController code,
    required String? hex,
  }) {
    _lastAutoCode = codeFor(hex);
    final text = code.text.trim();
    _manualCode = text.isNotEmpty && text != _lastAutoCode;
  }

  void onCodeChanged(String value) {
    if (_updatingCode) return;
    final text = value.trim();
    _manualCode = text.isNotEmpty && text != _lastAutoCode;
  }

  void onHexChanged({
    required TextEditingController code,
    required String hex,
  }) {
    final auto = codeFor(hex);
    if (auto == null) return;
    final text = code.text.trim();
    if (!_manualCode && (text.isEmpty || text == _lastAutoCode)) {
      _updatingCode = true;
      code.value = TextEditingValue(
        text: auto,
        selection: TextSelection.collapsed(offset: auto.length),
      );
      _updatingCode = false;
    }
    _lastAutoCode = auto;
  }
}
