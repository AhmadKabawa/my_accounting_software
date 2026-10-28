import 'package:accounting_software/app/core/foundation/localization/cubit/locale_cubit.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/enum_app_language.dart';
import 'package:accounting_software/app/core/services/local_storage/shared_storage/app_settings_manager_sorage.dart';
import 'package:accounting_software/app/core/services/network/dio/interceptors/language_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/memory_storage.dart';
import 'fake_adapter.dart';

class _FixedLanguage implements LanguageProvider {
  _FixedLanguage(this.currentLocale);
  @override
  final String currentLocale;
}

Dio dioWith(LanguageProvider provider, RoutedAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(LanguageInterceptor(languageProvider: provider));

void main() {

  test('adds Accept-Language to every request', () async {
    final adapter = RoutedAdapter((_) async => RoutedAdapter.json(200, '{}'));
    final dio = dioWith(_FixedLanguage('ar'), adapter);

    await dio.get<dynamic>('/a');
    await dio.post<dynamic>('/b');

    expect(
      adapter.requests.map((r) => r.headers['Accept-Language']),
      ['ar', 'ar'],
    );
  });

  test('follows LocaleCubit: a language change reaches the next request',
      () async {
    final cubit = LocaleCubit(
      appSettingsManager: AppSettingsManager(storage: MemoryStorage()),
    );
    final adapter = RoutedAdapter((_) async => RoutedAdapter.json(200, '{}'));
    final dio = dioWith(AppLanguageProvider(localeCubit: cubit), adapter);

    await cubit.changeLanguage(AppLanguage.en);
    await dio.get<dynamic>('/a');
    await cubit.changeLanguage(AppLanguage.ar);
    await dio.get<dynamic>('/b');

    expect(
      adapter.requests.map((r) => r.headers['Accept-Language']),
      ['en', 'ar'],
    );
    await cubit.close();
  });
}
