// lib/core/network/interceptors/language_interceptor.dart

import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/localization/cubit/locale_cubit.dart';

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

/// Reads the live language from [LocaleCubit], so a language change is
/// reflected in the very next request.
class AppLanguageProvider implements LanguageProvider {
  const AppLanguageProvider({required LocaleCubit localeCubit})
    : _localeCubit = localeCubit;

  final LocaleCubit _localeCubit;

  @override
  String get currentLocale => _localeCubit.languageCode;
}
