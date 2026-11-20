import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/auth/data/auth_endpoints.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/supabase_auth_mapper.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_result/auth_result_model.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    AuthEndpoints.token,
    queryParameters: {'grant_type': grantType},
    data: data,
    requiresAuth: false,
    fromJson: sessionFromSupabase,
  );

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
    AuthEndpoints.signup,
    data: {
      'email': email,
      'password': password,
      'data': {'full_name': name, 'phone': ?phone},
    },
    requiresAuth: false,
    fromJson: sessionFromSupabase,
  );

  @override
  Future<ApiResult<UserModel>> getCurrentUser() =>
      _apiClient.get(AuthEndpoints.user, fromJson: userFromSupabase);

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
  Future<ApiResult<Unit>> logout() =>
      _apiClient.post<Unit>(AuthEndpoints.logout, fromJson: (_) => unit);

  @override
  Future<ApiResult<Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _updateUser({
    'password': newPassword,
    'current_password': currentPassword,
  });

  @override
  Future<ApiResult<bool>> getMustChangePassword({required String userId}) =>
      _apiClient.get<bool>(
        AuthEndpoints.users,
        queryParameters: {'select': 'must_change_password', 'id': 'eq.$userId'},
        fromJsonList: (rows) {
          if (rows.length != 1 || rows.single is! Map<String, dynamic>) {
            throw const FormatException('public.users password flag missing');
          }
          final value =
              (rows.single as Map<String, dynamic>)['must_change_password'];
          if (value is! bool)
            throw const FormatException('public.users password flag invalid');
          return value;
        },
        requiresAuth: true,
      );

  @override
  Future<ApiResult<Unit>> setPasswordWithoutCurrent({
    required String newPassword,
  }) => _updateUser({'password': newPassword});

  @override
  Future<ApiResult<Unit>> completePasswordChange() => _apiClient.post<Unit>(
    AuthEndpoints.completePasswordChange,
    data: const <String, dynamic>{},
    requiresAuth: true,
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<Unit>> sendResetCode({required String email}) =>
      _apiClient.post<Unit>(
        AuthEndpoints.recover,
        data: {'email': email},
        requiresAuth: false,
        fromJson: (_) => unit,
      );

  Future<ApiResult<Unit>> _setPasswordWithRecoveryToken({
    required String token,
    required String newPassword,
  }) => _updateUser(
    {'password': newPassword},
    options: Options(headers: {'Authorization': '***'}),
    requiresAuth: false,
  );

  @override
  Future<ApiResult<Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final verified = await _apiClient.post<AuthResultModel>(
      AuthEndpoints.verify,
      data: {'type': 'recovery', 'email': email, 'token': code},
      requiresAuth: false,
      fromJson: sessionFromSupabase,
    );
    return switch (verified) {
      ApiSuccess(:final data) => await _setPasswordWithRecoveryToken(
        token: data.tokens.accessToken,
        newPassword: newPassword,
      ),
      ApiFailure(:final exception) => ApiFailure<Unit>(exception),
    };
  }

  @override
  Future<ApiResult<UserModel>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) => _apiClient.put(
    AuthEndpoints.user,
    data: {
      'data': {
        'full_name': ?fullName,
        'avatar_url': ?avatarUrl,
        'phone': ?phone,
      },
    },
    fromJson: userFromSupabase,
  );

  Future<ApiResult<Unit>> _updateUser(
    Map<String, dynamic> data, {
    Options? options,
    bool requiresAuth = true,
  }) => _apiClient.put<Unit>(
    AuthEndpoints.user,
    data: data,
    options: options,
    requiresAuth: requiresAuth,
    fromJson: (_) => unit,
  );
}
