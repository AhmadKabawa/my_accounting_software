import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';

abstract interface class AccessRemoteDataSource {
  Future<ApiResult<AccessSnapshot>> getMyAccess();
}
