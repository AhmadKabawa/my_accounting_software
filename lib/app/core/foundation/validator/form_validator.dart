import 'package:easy_localization/easy_localization.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_keys.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';

/// أنواع التحقق الممكنة
enum ValidationRule {
  required,
  email,
  minLength,
  maxLength,
  hasUppercase,
  hasNumber,
  hasSpecialChar,
  phone,
  match,
  password, // composite
  async, // async custom rule
}

typedef AsyncValidator = Future<bool> Function(String value);

/// Class رئيسي للتحقق الديناميكي
class AppValidator {
  /// دالة التحقق
  /// [value] : القيمة المراد التحقق منها
  /// [rules] : قائمة بأنواع التحقق
  /// [params] : خيارات إضافية لكل قاعدة (مثل minLength، maxLength، أو TextEditingController للمطابقة)
  /// Sync Validation
  static String? validate(
    String? value,
    List<ValidationRule> rules, {
    Map<ValidationRule, dynamic>? params,
    Map<ValidationRule, AppKey>? customKeys,
  }) {
    for (final rule in rules) {
      switch (rule) {
        case ValidationRule.required:
          if (value == null || value.trim().isEmpty) {
            return _translate(ValidationRule.required, customKeys);
          }
          break;

        case ValidationRule.email:
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (value == null || !emailRegex.hasMatch(value.trim())) {
            return _translate(ValidationRule.email, customKeys);
          }
          break;

        case ValidationRule.minLength:
          final min = params?[ValidationRule.minLength] ?? 0;
          if (value == null || value.length < min) {
            return _translate(
              ValidationRule.minLength,
              customKeys,
              namedArgs: {'length': '$min'},
            );
          }
          break;

        case ValidationRule.maxLength:
          final max = params?[ValidationRule.maxLength];
          if (value != null && max != null && value.length > max) {
            return _translate(
              ValidationRule.maxLength,
              customKeys,
              namedArgs: {'length': '$max'},
            );
          }
          break;

        case ValidationRule.hasUppercase:
          if (value == null || !value.contains(RegExp(r'[A-Z]'))) {
            return _translate(ValidationRule.hasUppercase, customKeys);
          }
          break;

        case ValidationRule.hasNumber:
          if (value == null || !value.contains(RegExp(r'[0-9]'))) {
            return _translate(ValidationRule.hasNumber, customKeys);
          }
          break;

        case ValidationRule.hasSpecialChar:
          if (value == null ||
              !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
            return _translate(ValidationRule.hasSpecialChar, customKeys);
          }
          break;

        case ValidationRule.phone:
          final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
          if (value == null ||
              !phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
            return _translate(ValidationRule.phone, customKeys);
          }
          break;

        case ValidationRule.match:
          final otherValue = params?[ValidationRule.match];
          if (value != otherValue) {
            return _translate(ValidationRule.match, customKeys);
          }
          break;

        case ValidationRule.password:
          final result = validate(
            value,
            [
              ValidationRule.minLength,
              ValidationRule.hasUppercase,
              ValidationRule.hasNumber,
              ValidationRule.hasSpecialChar,
            ],
            params: {
              ValidationRule.minLength: params?[ValidationRule.minLength] ?? 8,
            },
            customKeys: customKeys,
          );
          if (result != null) return result;
          break;

        case ValidationRule.async:
          break; // handled separately
      }
    }

    return null;
  }

  /// Translation Helper
  static String _translate(
    ValidationRule rule,
    Map<ValidationRule, AppKey>? customKeys, {
    Map<String, String>? namedArgs,
  }) {
    final key = customKeys?[rule] ?? _defaultKey(rule);
    return key.tr(namedArgs: namedArgs);
  }

  static AppKey _defaultKey(ValidationRule rule) {
    switch (rule) {
      case ValidationRule.required:
        return AppKeys.valid.required;
      case ValidationRule.email:
        return AppKeys.valid.emailInvalid;
      case ValidationRule.minLength:
        return AppKeys.valid.fieldMinLength;
      case ValidationRule.maxLength:
        return AppKeys.valid.fieldMaxLength;

      case ValidationRule.hasUppercase:
        return AppKeys.valid.passwordNeedsUpper;
      case ValidationRule.hasNumber:
        return AppKeys.valid.passwordNeedsNumber;
      case ValidationRule.hasSpecialChar:
        return AppKeys.valid.passwordNeedsSpecial;
      case ValidationRule.phone:
        return AppKeys.valid.phoneInvalid;
      case ValidationRule.match:
        return AppKeys.valid.passwordsNotMatch;
      case ValidationRule.password:
      case ValidationRule.async:
        return AppKeys.valid.required;
    }
  }
}
/**final passwordController = TextEditingController();
final confirmPasswordController = TextEditingController();
TextFormField(
  controller: passwordController,
  obscureText: true,
  decoration: InputDecoration(
    labelText: 'password'.tr(),
  ),
  validator: (value) => AppValidator.validate(
    value,
    [
      ValidationRule.required,
      ValidationRule.password,
    ],
    params: {
      ValidationRule.minLength: 8,
    },
  ),
),
TextFormField(
  controller: confirmPasswordController,
  obscureText: true,
  decoration: InputDecoration(labelText: 'Confirm Password'),
  validator: (value) => SmartValidator.validate(
    value,
    [ValidatorType.isNotEmpty, ValidatorType.matchField],
    params: {ValidatorType.matchField: passwordController},
  ),
),

TextFormField(
  decoration: InputDecoration(labelText: 'Email'),
  validator: (value) => SmartValidator.validate(
    value,
    [ValidatorType.isNotEmpty, ValidatorType.isEmail],
  ),
),
 */