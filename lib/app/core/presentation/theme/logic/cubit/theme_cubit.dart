import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/services/local_storage/shared_storage/app_settings_manager_sorage.dart';
import 'package:accounting_software/app/core/utils/logger.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final AppSettingsManager _appSettingsManager;

  ThemeCubit({required AppSettingsManager appSettingsManager})
    : _appSettingsManager = appSettingsManager,
      super(ThemeState(ThemeMode.system));

  /// تحميل الثيم المحفوظ
  Future<void> loadSavedTheme() async {
    try {
      final savedTheme = await _appSettingsManager.getThemeMode();
      final themeMode = savedTheme;

      emit(ThemeState(themeMode));
      Logger.info('✅ Theme loaded: $themeMode');
    } catch (e) {
      Logger.error('❌ Error loading theme', error: e);
      emit(ThemeState(ThemeMode.system));
    }
  }

  /// تغيير الثيم
  Future<void> changeTheme(ThemeMode mode) async {
    if (state.themeMode == mode) return;

    try {
      await _appSettingsManager.setThemeMode(mode);
      emit(ThemeState(mode));
      Logger.info('✅ Theme changed to: $mode');
    } catch (e) {
      Logger.error('❌ Error changing theme:', error: e);
    }
  }

  /// التبديل بين الفاتح والداكن
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await changeTheme(newMode);
  }

  /// ==================== Set Light Theme ====================
  /// تعيين الثيم الفاتح مباشرة
  Future<void> setLightTheme() async {
    await changeTheme(ThemeMode.light);
  }

  /// ==================== Set Dark Theme ====================
  /// تعيين الثيم الداكن مباشرة
  Future<void> setDarkTheme() async {
    await changeTheme(ThemeMode.dark);
  }

  /// ==================== Set System Theme ====================
  /// تعيين الثيم التلقائي (حسب النظام)
  Future<void> setSystemTheme() async {
    await changeTheme(ThemeMode.system);
  }

  /// ==================== Getters ====================
  /// للوصول السريع لحالة الثيم

  /// هل الثيم الحالي داكن؟
  bool get isDarkMode => state.themeMode == ThemeMode.dark;

  /// هل الثيم الحالي فاتح؟
  bool get isLightMode => state.themeMode == ThemeMode.light;

  /// هل الثيم الحالي تلقائي؟
  bool get isSystemMode => state.themeMode == ThemeMode.system;

  /// الحصول على ThemeMode الحالي
  ThemeMode get currentThemeMode => state.themeMode;

  /// الحصول على اسم الثيم الحالي
  String get currentThemeName => state.themeMode.toString();
}
