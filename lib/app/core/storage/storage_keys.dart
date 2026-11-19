import 'package:accounting_software/app/core/storage/storage_key.dart';

class StorageKeys {
  StorageKeys._();

  static const StorageKey themeMode = StorageKey('theme_mode');
  static const StorageKey language = StorageKey('language');
  static const StorageKey isLoggedIn = StorageKey('is_logged_in');
  static const StorageKey userData = StorageKey('user_data');
  static const StorageKey settings = StorageKey('app_settings');
  static const StorageKey onboardingKey = StorageKey('onboarding_completed');
  static const StorageKey sidebarCollapsed = StorageKey('sidebar_collapsed');
  static const StorageKey tokenKey = StorageKey('auth_token');
  static const StorageKey accessToken = StorageKey('auth_token');
  static const StorageKey refreshToken = StorageKey('refreshToken');
  static const StorageKey userId = StorageKey('userId');
}
