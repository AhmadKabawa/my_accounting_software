// lib/core/network/interceptors/language_interceptor.dart

import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/services/local_storage/shared_storage/app_settings_manager_sorage.dart';

/// يضيف Accept-Language header لكل request
/// يقرأ اللغة الحالية من AppLocale أو SharedPreferences
class LanguageInterceptor extends Interceptor {
  const LanguageInterceptor({required LanguageProvider languageProvider})
    : _provider = languageProvider;

  final LanguageProvider _provider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _provider.currentLocale;
    handler.next(options);
  }
}

// ── LanguageProvider interface ─────────────────────────────
abstract interface class LanguageProvider {
  String get currentLocale; // 'ar', 'en', 'ar-SA'
}

class AppLanguageProvider implements LanguageProvider {
  AppLanguageProvider({required this.storageService});

  final AppSettingsManager storageService;

  String _locale_code = 'en';

  Future<void> init() async {
    final _locale = await storageService.getLanguage(); // 'en', 'ar';
    _locale_code = _locale.code; // 'en', 'ar';
  }

  @override
  String get currentLocale => _locale_code;
}
