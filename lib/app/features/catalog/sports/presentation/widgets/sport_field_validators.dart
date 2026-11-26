import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';

/// Sport form rules on the shared [AppValidator]. Limits mirror the `sports`
/// table; the order field is optional, so blank values pass.
abstract final class SportFieldValidators {
  static const maxName = 100;
  static const maxCode = 50;
  static final _wholeNumber = RegExp(r'^\d{1,9}$');
  static final _codePattern = RegExp(r'^[A-Z][A-Z0-9_-]*$');

  static String? name(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength],
    params: {ValidationRule.maxLength: maxName},
    customKeys: {
      ValidationRule.required: SportsKeys.required,
      ValidationRule.maxLength: SportsKeys.nameTooLong,
    },
  );

  static String? code(String? value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.maxLength, ValidationRule.pattern],
    params: {
      ValidationRule.maxLength: maxCode,
      ValidationRule.pattern: _codePattern,
    },
    customKeys: {
      ValidationRule.required: SportsKeys.required,
      ValidationRule.maxLength: SportsKeys.codeTooLong,
      ValidationRule.pattern: SportsKeys.codeFormat,
    },
  );

  /// Optional: blank means 0.
  static String? sortOrder(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return _wholeNumber.hasMatch(value.trim())
        ? null
        : SportsKeys.sortOrderFormat.tr();
  }
}
