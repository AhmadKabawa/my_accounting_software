import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/formatters/uppercase_code_formatter.dart';

void main() {
  const formatter = UppercaseCodeFormatter();

  test('removes unsupported characters and uppercases allowed characters', () {
    const value = TextEditingValue(
      text: 'red red_1-x!',
      selection: TextSelection.collapsed(offset: 11),
    );

    final formatted = formatter.formatEditUpdate(
      const TextEditingValue.empty,
      value,
    );

    expect(formatted.text, 'REDRED_1-X');
  });

  test('preserves the cursor position when characters are filtered', () {
    const value = TextEditingValue(
      text: 're d',
      selection: TextSelection.collapsed(offset: 3),
    );

    final formatted = formatter.formatEditUpdate(
      const TextEditingValue.empty,
      value,
    );

    expect(formatted.text, 'RED');
    expect(formatted.selection, const TextSelection.collapsed(offset: 3));
  });
}
