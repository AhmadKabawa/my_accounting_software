import 'package:easy_localization/easy_localization.dart';
import 'package:accounting_software/app/core/localization/keys/validation_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';

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
  async, // NOT IMPLEMENTED: reserved; validate() ignores it (no async path yet)
}

/// Reserved for a future async rule; nothing consumes it yet.
typedef AsyncValidator = Future<bool> Function(String value);

/// Class رئيسي للتحقق الديناميكي (نظام التحقق الوحيد في المشروع).
/// الرسائل عبر AppKey. أمثلة الاستخدام في docs/architecture/CORE_USAGE.md.
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
        return ValidationKeys.required;
      case ValidationRule.email:
        return ValidationKeys.emailInvalid;
      case ValidationRule.minLength:
        return ValidationKeys.fieldMinLength;
      case ValidationRule.maxLength:
        return ValidationKeys.fieldMaxLength;

      case ValidationRule.hasUppercase:
        return ValidationKeys.passwordNeedsUpper;
      case ValidationRule.hasNumber:
        return ValidationKeys.passwordNeedsNumber;
      case ValidationRule.hasSpecialChar:
        return ValidationKeys.passwordNeedsSpecial;
      case ValidationRule.phone:
        return ValidationKeys.phoneInvalid;
      case ValidationRule.match:
        return ValidationKeys.passwordsNotMatch;
      case ValidationRule.password:
      case ValidationRule.async:
        return ValidationKeys.required;
    }
  }
}
