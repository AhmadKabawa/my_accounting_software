import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

/// Color form rules on the shared [AppValidator]. Limits mirror the `colors`
/// table; the HEX and order fields are optional, so blank values pass.
abstract final class ColorFieldValidators {
  static const maxName = 100;
  static const maxCode = 50;
  static final _wholeNumber = RegExp(r'^\d{1,9}$');

  static String? name(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxName},
    customKeys: {
      ValidationRule.required: ColorsKeys.required,
      ValidationRule.maxLength: ColorsKeys.nameTooLong,
    },
  );

  static String? code(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxCode},
    customKeys: {
      ValidationRule.required: ColorsKeys.required,
      ValidationRule.maxLength: ColorsKeys.codeTooLong,
    },
  );

  /// The value as stored: trimmed, with the leading `#` the user may omit.
  static String? withHash(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    return trimmed.startsWith('#') ? trimmed : '#$trimmed';
  }

  /// Optional: a blank value is valid (the pattern rule alone would reject it).
  static String? hex(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return HexColor.isValid(withHash(value)) ? null : ColorsKeys.hexFormat.tr();
  }

  /// Optional: blank means 0.
  static String? sortOrder(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return _wholeNumber.hasMatch(value.trim())
        ? null
        : ColorsKeys.sortOrderFormat.tr();
  }
}
