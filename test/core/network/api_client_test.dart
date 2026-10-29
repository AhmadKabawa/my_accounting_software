import 'package:accounting_software/app/core/error/error_handling/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/services/network/api_end_points.dart';
import 'package:accounting_software/app/core/services/network/dio/api_client.dart';
import 'package:accounting_software/app/core/services/network/dio/dio_service.dart';
import 'package:accounting_software/app/core/services/network/dio/interceptors/language_interceptor.dart';
import 'package:accounting_software/app/core/services/network/network_info/network_info.dart';
import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/memory_storage.dart';
import 'fake_adapter.dart';

class _Online implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _Lang implements LanguageProvider {
  @override
  String get currentLocale => 'ar';
}

const _endpoint = AppEndpoint('/rest/v1/items');

ApiClient clientFor(String body, {int status = 200}) {
  final service = DioService(
    tokenManager: TokenManager(storage: MemoryStorage()),
    networkInfoImpl: _Online(),
    languageProvider: _Lang(),
  );
  service.dio.httpClientAdapter = RoutedAdapter(
    (_) async => RoutedAdapter.json(status, body),
  );
  return ApiClient(dioService: service);
}

class _Item {
  _Item(this.id);
  final int id;
}

_Item _parse(Map<String, dynamic> json) => _Item(json['id'] as int);

void main() {
  group('objects and arrays', () {
    test('an object is parsed with fromJson', () async {
      final result = await clientFor('{"id":1}').get<_Item>(
        _endpoint,
        fromJson: _parse,
      );

      expect((result as ApiSuccess<_Item>).data.id, 1);
    });

    test('an array is parsed with fromJsonList', () async {
      final result = await clientFor('[{"id":1},{"id":2}]').get<List<_Item>>(
        _endpoint,
        fromJsonList: (list) =>
            list.map((e) => _parse(e as Map<String, dynamic>)).toList(),
      );

      expect(
        (result as ApiSuccess<List<_Item>>).data.map((e) => e.id),
        [1, 2],
      );
    });

    test('an array without fromJsonList is a failure, not a crash', () async {
      final result = await clientFor('[{"id":1}]').get<_Item>(
        _endpoint,
        fromJson: _parse,
      );

      expect(result, isA<ApiFailure<_Item>>());
    });

    test('an object without fromJson is a failure when only a list parser is given',
        () async {
      final result = await clientFor('{"id":1}').get<List<_Item>>(
        _endpoint,
        fromJsonList: (_) => [],
      );

      expect(result, isA<ApiFailure<List<_Item>>>());
    });
  });

  group('no parser', () {
    test('returns the data when it has the requested type', () async {
      final result = await clientFor('[1,2]').get<List<dynamic>>(_endpoint);

      expect((result as ApiSuccess<List<dynamic>>).data, [1, 2]);
    });

    test('a mismatched type is a failure instead of a TypeError', () async {
      final result = await clientFor('[1,2]').get<Map<String, dynamic>>(
        _endpoint,
      );

      expect(result, isA<ApiFailure<Map<String, dynamic>>>());
    });
  });

  group('connection problems', () {
    ApiClient failingWith(DioExceptionType type) {
      final service = DioService(
        tokenManager: TokenManager(storage: MemoryStorage()),
        networkInfoImpl: _Online(),
        languageProvider: _Lang(),
      );
      service.dio.httpClientAdapter = RoutedAdapter(
        (o) async => throw DioException(requestOptions: o, type: type),
      );
      return ApiClient(dioService: service);
    }

    // POST on purpose: GETs are retried with real delays by RetryInterceptor.
    ApiExceptionType typeOf(ApiResult<dynamic> r) =>
        ((r as ApiFailure<dynamic>).exception as ApiException).type;

    test('a connection timeout is reported as no internet', () async {
      final result = await failingWith(
        DioExceptionType.connectionTimeout,
      ).post<_Item>(_endpoint, fromJson: _parse);

      expect(typeOf(result), ApiExceptionType.noInternet);
    });

    test('a connection error is reported as no internet', () async {
      final result = await failingWith(
        DioExceptionType.connectionError,
      ).post<_Item>(_endpoint, fromJson: _parse);

      expect(typeOf(result), ApiExceptionType.noInternet);
    });

    test('a slow response on an open connection stays a timeout', () async {
      final result = await failingWith(
        DioExceptionType.receiveTimeout,
      ).post<_Item>(_endpoint, fromJson: _parse);

      expect(typeOf(result), ApiExceptionType.timeout);
    });
  });

  group('errors never escape', () {
    test('a throwing fromJson becomes an ApiFailure', () async {
      final result = await clientFor('{"id":1}').get<_Item>(
        _endpoint,
        fromJson: (_) => throw StateError('bad'),
      );

      expect(result, isA<ApiFailure<_Item>>());
    });

    test('a failing paginated parse becomes an ApiFailure', () async {
      final result = await clientFor('[1,2]').getPaginated<_Item>(
        _endpoint,
        fromJson: _parse,
      );

      expect(result, isA<ApiFailure<dynamic>>());
    });

    test('an HTTP error status is mapped', () async {
      final result = await clientFor('{"msg":"nope"}', status: 400).get<_Item>(
        _endpoint,
        fromJson: _parse,
      );

      expect(result, isA<ApiFailure<_Item>>());
    });
  });
}
