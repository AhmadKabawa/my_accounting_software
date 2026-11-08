import 'package:accounting_software/app/core/network/api_end_points.dart';

/// Supabase Auth (GoTrue) endpoints, owned by the auth feature.
///
/// Flows that share a path are selected with a query parameter:
/// `token` → `grant_type=password | refresh_token | id_token`.
///
/// A path with a dynamic part must go through `encodePathSegment` (core) so a
/// value can never change the structure of the path.
abstract final class AuthEndpoints {
  static const String base = '/auth/v1';

  static const token = AppEndpoint('$base/token');
  static const signup = AppEndpoint('$base/signup');
  static const logout = AppEndpoint('$base/logout');
  static const user = AppEndpoint('$base/user');
  static const recover = AppEndpoint('$base/recover');
  static const verify = AppEndpoint('$base/verify');
}
