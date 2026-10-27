import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/services/network/dio/interceptors/retry_interceptor.dart';

import 'fake_adapter.dart';

void main() {
  Dio buildDio(FakeAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(RetryInterceptor(dio, baseDelay: Duration.zero));
    return dio;
  }

  test('GET is retried on 5xx and then succeeds', () async {
    final adapter = FakeAdapter([503, 200]);
    final res = await buildDio(adapter).get<dynamic>('/items');

    expect(res.statusCode, 200);
    expect(adapter.requests.length, 2);
  });

  test('GET stops after the configured maximum number of retries', () async {
    final adapter = FakeAdapter([500]);

    await expectLater(
      buildDio(adapter).get<dynamic>('/items'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests.length, AppConfig.maxRetries + 1);
  });

  test('POST is never retried, so a write cannot be duplicated', () async {
    final adapter = FakeAdapter([500, 200]);

    await expectLater(
      buildDio(adapter).post<dynamic>('/invoices', data: {'total': 1}),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests.length, 1);
  });

  test('POST can opt in to retry when explicitly idempotent', () async {
    final adapter = FakeAdapter([500, 200]);
    final res = await buildDio(adapter).post<dynamic>(
      '/invoices',
      options: Options(extra: {'idempotent': true}),
    );

    expect(res.statusCode, 200);
    expect(adapter.requests.length, 2);
  });

  test('client errors (4xx) are not retried', () async {
    final adapter = FakeAdapter([404, 200]);

    await expectLater(
      buildDio(adapter).get<dynamic>('/missing'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests.length, 1);
  });
}
