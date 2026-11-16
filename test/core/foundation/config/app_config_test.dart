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

    test(
      'ensureConfigured behaves exactly like EnvConfig.ensureConfigured',
      () {
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
      },
    );

    test('keeps the general constants', () {
      expect(AppConfig.defaultPageSize, 25);
      expect(AppConfig.supportedLanguages, containsAll(['ar', 'en']));
      expect(AppConfig.maxRetries, greaterThan(0));
    });

    group('page size', () {
      test('offers exactly 10, 25, 50 and 100 and defaults to 25', () {
        expect(AppConfig.pageSizeOptions, [10, 25, 50, 100]);
        expect(AppConfig.defaultPageSize, 25);
        expect(AppConfig.pageSizeOptions, contains(AppConfig.defaultPageSize));
      });

      test('resolvePageSize keeps a supported size', () {
        for (final size in AppConfig.pageSizeOptions) {
          expect(AppConfig.resolvePageSize(size), size);
        }
      });

      test('resolvePageSize falls back to the default otherwise', () {
        expect(AppConfig.resolvePageSize(null), AppConfig.defaultPageSize);
        expect(AppConfig.resolvePageSize(0), AppConfig.defaultPageSize);
        expect(AppConfig.resolvePageSize(-25), AppConfig.defaultPageSize);
        expect(AppConfig.resolvePageSize(30), AppConfig.defaultPageSize);
        expect(AppConfig.resolvePageSize(1000), AppConfig.defaultPageSize);
      });
    });
  });
}
