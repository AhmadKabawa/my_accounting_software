import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/data/access_endpoints.dart';
import 'package:accounting_software/app/core/access/data/access_remote_data_source_impl.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';

class _ApiClient implements IApiClient {
  AppEndpoint? requestedPath;
  dynamic requestedData;
  bool? requestedAuth;

  @override
  Future<ApiResult<T>> post<T>(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    JsonListFactory<T>? fromJsonList,
    CancelToken? cancelToken,
    bool requiresAuth = false,
  }) async {
    requestedPath = path;
    requestedData = data;
    requestedAuth = requiresAuth;
    if (fromJson == null) {
      throw StateError('Access request must provide a JSON parser');
    }
    return ApiSuccess<T>(
      fromJson({
        'user_id': 'u1',
        'username': 'admin',
        'email': null,
        'is_super_admin': false,
        'roles': [],
        'permissions': [],
        'branches': [],
        'warehouses': [],
        'pos_terminals': [],
      }),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'requests the authenticated get_my_access RPC and parses its snapshot',
    () async {
    final client = _ApiClient();
    final source = AccessRemoteDataSourceImpl(apiClient: client);

    final result = await source.getMyAccess();

    expect(client.requestedPath, AccessEndpoints.getMyAccess);
    expect(client.requestedPath?.path, '/rest/v1/rpc/get_my_access');
    expect(client.requestedData, isEmpty);
    expect(client.requestedAuth, isTrue);
    expect(result, isA<ApiSuccess<AccessSnapshot>>());
      expect((result as ApiSuccess<AccessSnapshot>).data.userId, 'u1');
    },
  );
}
