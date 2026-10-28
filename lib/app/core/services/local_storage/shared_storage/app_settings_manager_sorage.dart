// ─── AppSettingsManager: طبقة فوق SharedPreferences ─────────────────────────
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/enum_app_language.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_keys.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_service.dart';

class AppSettingsManager {
  final StorageService storage;

  AppSettingsManager({required this.storage});
  bool? _isOnboardedCache;
  // ─── Theme ─────────────────────────────────────────────────────────────────
  Future<void> setThemeMode(ThemeMode mode) async {
    await storage.write<String>(StorageKeys.themeMode, mode.name);
  }

  Future<ThemeMode> getThemeMode() async {
    final mode = await storage.read<String>(StorageKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (e) => e.name == mode,
      orElse: () => ThemeMode.system,
    );
  }

  // ─── Language ──────────────────────────────────────────────────────────────
  Future<void> setLanguage(AppLanguage langCode) async {
    // 'ar', 'en'
    await storage.write<String>(StorageKeys.language, langCode.name);
  }

  Future<AppLanguage> getLanguage() async {
    final code = await storage.read<String>(StorageKeys.language);
    return AppLanguage.fromCode(code);
  }

  // ─── Onboarding ────────────────────────────────────────────────────────────
  Future<void> setOnboarded() async {
    await storage.write<bool>(StorageKeys.onboardingKey, true);
    _isOnboardedCache = true;
  }

  Future<bool> isOnboarded() async {
    if (_isOnboardedCache != null) {
      return _isOnboardedCache!;
    }

    _isOnboardedCache = await storage.read<bool>(StorageKeys.onboardingKey);
    return _isOnboardedCache ?? false;
  }
}
