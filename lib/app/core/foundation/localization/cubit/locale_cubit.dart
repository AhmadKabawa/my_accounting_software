import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/enum_app_language.dart';
import 'package:accounting_software/app/core/services/local_storage/shared_storage/app_settings_manager_sorage.dart';
import 'package:accounting_software/app/core/utils/logger.dart';

import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  final AppSettingsManager appSettingsManager;

  LocaleCubit({required this.appSettingsManager})
    : super(LocaleState(locale: AppLanguage.ar.locale));

  /// تحميل اللغة من التخزين
  Future<void> loadSavedLanguage() async {
    try {
      final savedLang = await appSettingsManager.getLanguage();

      emit(LocaleState(locale: savedLang.locale));

      Logger.info('✅ locale loaded: ${savedLang.code}');
    } catch (e) {
      Logger.error('❌ Error loading locale:  ', error: e);
      emit(LocaleState(locale: AppLanguage.ar.locale));
    }
  }

  /// تغيير اللغة
  Future<void> changeLanguage(AppLanguage language) async {
    if (state.locale == language.locale) return;
    try {
      await appSettingsManager.setLanguage(language);
      emit(LocaleState(locale: language.locale));
      // context.setLocale(Locale(languageCode));
      Logger.info('✅ locale changed: ${language.locale}');
    } catch (e) {
      Logger.info('❌ Error changing locale: $e');
    }
  }

  /// تبديل اللغة
  Future<void> toggleLanguage() async {
    if (state.locale.languageCode == 'ar') {
      await changeLanguage(AppLanguage.en);
    } else {
      await changeLanguage(AppLanguage.ar);
    }
  }

  bool get isArabic => state.locale.languageCode == AppLanguage.ar.code;
  bool get isEnglish => state.locale.languageCode == AppLanguage.en.code;
  AppLanguage get currentLanguage =>
      AppLanguage.fromCode(state.locale.languageCode);

  TextDirection get textDirection =>
      isArabic ? TextDirection.RTL : TextDirection.LTR;

  /// الحصول على كود اللغة
  String get languageCode => state.locale.languageCode;

  static final fallbackLocale = AppLanguage.ar.locale;

  static final supportedLocales = AppLanguage.values
      .map((lang) => lang.locale)
      .toList();
}
