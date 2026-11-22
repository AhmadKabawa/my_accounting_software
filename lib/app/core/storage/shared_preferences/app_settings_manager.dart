// ─── AppSettingsManager: طبقة فوق SharedPreferences ─────────────────────────
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_language.dart';
import 'package:accounting_software/app/core/storage/storage_keys.dart';
import 'package:accounting_software/app/core/storage/storage_service.dart';

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

  // ─── Desktop navigation ───────────────────────────────────────────────────
  Future<void> setSidebarCollapsed(bool collapsed) async {
    await storage.write<bool>(StorageKeys.sidebarCollapsed, collapsed);
  }

  Future<bool> getSidebarCollapsed() async =>
      await storage.read<bool>(StorageKeys.sidebarCollapsed) ?? false;

  // ─── List view mode (per screen) ────────────────────────────────────────────
  Future<void> setViewMode(String screenId, String mode) async {
    await storage.write<String>(StorageKeys.viewMode(screenId), mode);
  }

  Future<String?> getViewMode(String screenId) =>
      storage.read<String>(StorageKeys.viewMode(screenId));

  // ─── Sidebar sections ──────────────────────────────────────────────────────
  Future<void> setSidebarOpenSections(Set<String> ids) async {
    await storage.write<String>(
      StorageKeys.sidebarOpenSections,
      (ids.toList()..sort()).join(','),
    );
  }

  Future<Set<String>> getSidebarOpenSections() async {
    final raw = await storage.read<String>(StorageKeys.sidebarOpenSections);
    if (raw == null || raw.isEmpty) return <String>{};
    return raw.split(',').where((id) => id.isNotEmpty).toSet();
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
