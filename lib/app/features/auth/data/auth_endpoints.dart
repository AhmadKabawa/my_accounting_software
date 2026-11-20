import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class AuthEndpoints {
  static const String base = '/auth/v1';
  static const token = AppEndpoint('$base/token');
  static const signup = AppEndpoint('$base/signup');
  static const logout = AppEndpoint('$base/logout');
  static const user = AppEndpoint('$base/user');
  static const recover = AppEndpoint('$base/recover');
  static const verify = AppEndpoint('$base/verify');
  static const users = AppEndpoint('/rest/v1/users');
  static const completePasswordChange = AppEndpoint('/rest/v1/rpc/complete_password_change');
}
