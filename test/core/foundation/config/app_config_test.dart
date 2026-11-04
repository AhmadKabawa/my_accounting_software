import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/config/env_config.dart';

void main() {
  group('AppConfig is the single entry to environment settings', () {
    test('exposes the EnvConfig values unchanged', () {
      expect(AppConfig.baseUrl, EnvConfig.supabaseUrl);
      expect(AppConfig.supabaseAnonKey, EnvConfig.supabaseAnonKey);
      expect(AppConfig.googleClientId, EnvConfig.googleClientId);
    });

    test('ensureConfigured behaves exactly like EnvConfig.ensureConfigured', () {
      Object? viaApp;
      Object? viaEnv;
      try {
        AppConfig.ensureConfigured();
      } catch (e) {
        viaApp = e;
      }
      try {
        EnvConfig.ensureConfigured();
      } catch (e) {
        viaEnv = e;
      }
      expect(viaApp.runtimeType, viaEnv.runtimeType);
      expect(viaApp?.toString(), viaEnv?.toString());
    });

    test('keeps the general constants', () {
      expect(AppConfig.defaultPageSize, 10);
      expect(AppConfig.supportedLanguages, containsAll(['ar', 'en']));
      expect(AppConfig.maxRetries, greaterThan(0));
    });
  });
}
