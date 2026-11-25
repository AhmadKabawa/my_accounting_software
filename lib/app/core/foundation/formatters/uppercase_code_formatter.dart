import 'package:flutter/services.dart';

/// Uppercases color codes and removes characters outside A-Z, 0-9, _ and -.
class UppercaseCodeFormatter extends TextInputFormatter {
  const UppercaseCodeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '')
        .toUpperCase();
    final base = newValue.selection.baseOffset.clamp(0, text.length).toInt();
    final extent = newValue.selection.extentOffset
        .clamp(0, text.length)
        .toInt();
    return newValue.copyWith(
      text: text,
      selection: TextSelection(baseOffset: base, extentOffset: extent),
      composing: TextRange.empty,
    );
  }
}
