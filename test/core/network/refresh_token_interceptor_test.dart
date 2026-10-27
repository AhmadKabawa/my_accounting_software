import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_service.dart';
import 'package:accounting_software/app/core/services/network/dio/interceptors/auth_interceptor.dart';
import 'package:accounting_software/app/core/services/network/dio/interceptors/refresh_token_interceptor.dart';

import 'fake_adapter.dart';

class _MemoryStorage implements StorageService {
  final Map<StorageKey, Object?> values = {};

  @override
  Future<void> write<T>(StorageKey key, T value) async => values[key] = value;

  @override
  Future<T?> read<T>(StorageKey key) async => values[key] as T?;

  @override
  Future<void> delete(StorageKey key) async => values.remove(key);

  @override
  Future<void> clearAll() async => values.clear();

  @override
  Future<bool> containsKey(StorageKey key) async => values.containsKey(key);
}

void main() {
  late TokenManager tokens;

  setUp(() async {
    tokens = TokenManager(storage: _MemoryStorage());
    await tokens.saveAuthTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      userId: 'u1',
    );
  });

  Dio buildDio(RoutedAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.addAll([
      AuthInterceptor(tokens),
      RefreshTokenInterceptor(dio, tokens),
    ]);
    return dio;
  }

  bool isRefresh(RequestOptions o) => o.path == '/auth/v1/token';

  Future<ResponseBody> serverWithRefresh(
    RequestOptions o, {
    int refreshStatus = 200,
  }) async {
    if (isRefresh(o)) {
      return refreshStatus == 200
          ? RoutedAdapter.json(
              200,
              '{"access_token":"new-access","refresh_token":"new-refresh"}',
            )
          : RoutedAdapter.json(refreshStatus, '{"error":"invalid_grant"}');
    }
    final auth = o.headers['Authorization'];
    return auth == 'Bearer new-access'
        ? RoutedAdapter.json(200, '{"ok":true}')
        : RoutedAdapter.json(401, '{"msg":"expired"}');
  }

  test('401 refreshes the session and replays the request', () async {
    final adapter = RoutedAdapter(serverWithRefresh);
    final res = await buildDio(adapter).get<dynamic>('/rest/v1/items');

    expect(res.statusCode, 200);
    final refresh = adapter.requests.firstWhere(isRefresh);
    expect(refresh.queryParameters['grant_type'], 'refresh_token');
    expect(refresh.data, {'refresh_token': 'old-refresh'});
  });

  test('stores access and refresh tokens in their own slots (F1)', () async {
    final adapter = RoutedAdapter(serverWithRefresh);
    await buildDio(adapter).get<dynamic>('/rest/v1/items');

    expect(await tokens.getAccessToken(), 'new-access');
    expect(await tokens.getRefreshToken(), 'new-refresh');
  });

  test('concurrent 401s trigger a single refresh', () async {
    final adapter = RoutedAdapter(serverWithRefresh);
    final dio = buildDio(adapter);

    final results = await Future.wait([
      dio.get<dynamic>('/rest/v1/a'),
      dio.get<dynamic>('/rest/v1/b'),
      dio.get<dynamic>('/rest/v1/c'),
    ]);

    expect(results.every((r) => r.statusCode == 200), isTrue);
    expect(adapter.requests.where(isRefresh).length, 1);
  });

  test('a rejected refresh token ends the session', () async {
    final adapter = RoutedAdapter(
      (o) => serverWithRefresh(o, refreshStatus: 401),
    );

    await expectLater(
      buildDio(adapter).get<dynamic>('/rest/v1/items'),
      throwsA(
        isA<DioException>().having((e) => e.response?.statusCode, 'status', 401),
      ),
    );
    expect(await tokens.getAccessToken(), isNull);
    expect(await tokens.getRefreshToken(), isNull);
  });

  test('a network failure during refresh keeps the session', () async {
    final adapter = RoutedAdapter((o) async {
      if (isRefresh(o)) {
        throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        );
      }
      return RoutedAdapter.json(401, '{"msg":"expired"}');
    });

    await expectLater(
      buildDio(adapter).get<dynamic>('/rest/v1/items'),
      throwsA(isA<DioException>()),
    );
    expect(await tokens.getRefreshToken(), 'old-refresh');
  });

  test('requests marked requiresAuth:false are not refreshed', () async {
    final adapter = RoutedAdapter(serverWithRefresh);

    await expectLater(
      buildDio(adapter).get<dynamic>(
        '/rest/v1/public',
        options: Options(extra: {'requiresAuth': false}),
      ),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests.where(isRefresh), isEmpty);
  });

  test('a replayed request that still gets 401 is not refreshed again', () async {
    final adapter = RoutedAdapter((o) async {
      if (isRefresh(o)) {
        return RoutedAdapter.json(
          200,
          '{"access_token":"new-access","refresh_token":"new-refresh"}',
        );
      }
      return RoutedAdapter.json(401, '{"msg":"still unauthorized"}');
    });

    await expectLater(
      buildDio(adapter).get<dynamic>('/rest/v1/items'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests.where(isRefresh).length, 1);
  });
}
