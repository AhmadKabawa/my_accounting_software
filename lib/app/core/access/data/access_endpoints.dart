import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class AccessEndpoints {
  static const getMyAccess = AppEndpoint('/rest/v1/rpc/get_my_access');
}
