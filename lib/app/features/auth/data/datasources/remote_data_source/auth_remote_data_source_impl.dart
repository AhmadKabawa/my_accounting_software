import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/services/network/api_client_interface.dart';
import 'package:accounting_software/app/core/services/network/api_end_points.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/supabase_auth_mapper.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_result/auth_result_model.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Supabase Auth (GoTrue) adapter over the shared [IApiClient].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required IApiClient apiClient,
    required GoogleSignIn googleSignIn,
  }) : _apiClient = apiClient,
       _googleSignIn = googleSignIn;

  final IApiClient _apiClient;
  final GoogleSignIn _googleSignIn;

  Future<ApiResult<AuthResultModel>> _tokenGrant(
    String grantType,
    Map<String, dynamic> data,
  ) => _apiClient.post(
    AppEndpoints.auth.token,
    queryParameters: {'grant_type': grantType},
    data: data,
    requiresAuth: false,
    fromJson: sessionFromSupabase,
  );

  // ── Authentication ────────────────────────────────────────────

  @override
  Future<ApiResult<AuthResultModel>> login({
    required String email,
    required String password,
  }) => _tokenGrant('password', {'email': email, 'password': password});

  @override
  Future<ApiResult<AuthResultModel>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) => _apiClient.post(
    AppEndpoints.auth.signup,
    data: {
      'email': email,
      'password': password,
      'data': {'full_name': name, if (phone != null) 'phone': phone},
    },
    requiresAuth: false,
    fromJson: sessionFromSupabase,
  );

  @override
  Future<ApiResult<UserModel>> getCurrentUser() =>
      _apiClient.get(AppEndpoints.auth.user, fromJson: userFromSupabase);

  @override
  Future<ApiResult<AuthResultModel>> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) return ApiFailure(ApiException.cancelled());

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) return ApiFailure(ApiException.unknown());

      return _tokenGrant('id_token', {
        'provider': 'google',
        'id_token': idToken,
        if (auth.accessToken != null) 'access_token': auth.accessToken,
      });
    } catch (e) {
      return ApiFailure(ApiException.unknown(serverMessage: e.toString()));
    }
  }

  @override
  Future<ApiResult<Unit>> logout() => _apiClient.post<Unit>(
    AppEndpoints.auth.logout,
    fromJson: (_) => unit,
  );

  // ── Password Management ───────────────────────────────────────

  @override
  Future<ApiResult<Unit>> sendResetCode({required String email}) =>
      _apiClient.post<Unit>(
        AppEndpoints.auth.recover,
        data: {'email': email},
        requiresAuth: false,
        fromJson: (_) => unit,
      );

  /// Supabase cannot check a recovery code without consuming it: verifying it
  /// creates the session. Use [confirmNewPassword], which verifies the code and
  /// sets the new password in one step.
  @override
  Future<ApiResult<Unit>> verifyResetCode({
    required String email,
    required String code,
  }) async => ApiFailure<Unit>(
    ApiException.unknown(
      serverMessage: 'verifyResetCode is not supported; use confirmNewPassword',
    ),
  );

  /// [token] is the access token of a recovery session (for example the one
  /// delivered by the e-mail recovery link).
  @override
  Future<ApiResult<Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) => _updateUser(
    {'password': newPassword},
    options: Options(headers: {'Authorization': 'Bearer $token'}),
    requiresAuth: false,
  );

  @override
  Future<ApiResult<Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _updateUser({
    'password': newPassword,
    'current_password': currentPassword,
  });

  @override
  Future<ApiResult<Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final verified = await _apiClient.post<AuthResultModel>(
      AppEndpoints.auth.verify,
      data: {'type': 'recovery', 'email': email, 'token': code},
      requiresAuth: false,
      fromJson: sessionFromSupabase,
    );
    return switch (verified) {
      ApiSuccess(:final data) => await resetPassword(
        token: data.tokens.accessToken,
        newPassword: newPassword,
      ),
      ApiFailure(:final exception) => ApiFailure<Unit>(exception),
    };
  }

  // ── Profile Management ────────────────────────────────────────

  @override
  Future<ApiResult<UserModel>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) => _apiClient.put(
    AppEndpoints.auth.user,
    data: {
      'data': {
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (phone != null) 'phone': phone,
      },
    },
    fromJson: userFromSupabase,
  );

  Future<ApiResult<Unit>> _updateUser(
    Map<String, dynamic> data, {
    Options? options,
    bool requiresAuth = true,
  }) => _apiClient.put<Unit>(
    AppEndpoints.auth.user,
    data: data,
    options: options,
    requiresAuth: requiresAuth,
    fromJson: (_) => unit,
  );
}
