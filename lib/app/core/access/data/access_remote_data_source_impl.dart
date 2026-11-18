import 'package:accounting_software/app/core/access/data/access_endpoints.dart';
import 'package:accounting_software/app/core/access/data/access_remote_data_source.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';

class AccessRemoteDataSourceImpl implements AccessRemoteDataSource {
  const AccessRemoteDataSourceImpl({required IApiClient apiClient})
    : _apiClient = apiClient;

  final IApiClient _apiClient;

  @override
  Future<ApiResult<AccessSnapshot>> getMyAccess() {
    return _apiClient.post<AccessSnapshot>(
      AccessEndpoints.getMyAccess,
      data: const <String, dynamic>{},
      fromJson: AccessSnapshot.fromJson,
      requiresAuth: true,
    );
  }
}
