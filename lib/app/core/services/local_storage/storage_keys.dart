import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';

class StorageKeys {
  // منع إنشاء instance
  StorageKeys._();

  /// مفتاح حفظ ThemeMode
  static const StorageKey themeMode = StorageKey('theme_mode');

  /// مفتاح حفظ اللغة
  static const StorageKey language = StorageKey('language');

  /// مفتاح حفظ حالة تسجيل الدخول
  static const StorageKey isLoggedIn = StorageKey('is_logged_in');

  /// مفتاح حفظ بيانات المستخدم
  static const StorageKey userData = StorageKey('user_data');

  /// مفتاح حفظ الإعدادات العامة
  static const StorageKey settings = StorageKey('app_settings');

  static const StorageKey onboardingKey = StorageKey('onboarding_completed');

  static const StorageKey tokenKey = StorageKey('auth_token');
  static const StorageKey accessToken = StorageKey('auth_token');
  static const StorageKey refreshToken = StorageKey('refreshToken');
  static const StorageKey userId = StorageKey('userId');
}
