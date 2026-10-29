import 'package:accounting_software/app/core/error/error_handling/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/auth/data/datasources/local_data_source/auth_local_data_source.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_result/auth_result_model.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_tokens/auth_tokens_model.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';
import 'package:accounting_software/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dartz/dartz.dart' show Unit;
import 'package:flutter_test/flutter_test.dart';

const _user = UserModel(id: 'u1', email: 'a@b.c');

class _FakeRemote implements AuthRemoteDataSource {
  _FakeRemote(this.result);
  final ApiResult<UserModel> result;

  @override
  Future<ApiResult<UserModel>> getCurrentUser() async => result;

  // Everything this test does not drive fails loudly.
  @override
  Future<ApiResult<AuthResultModel>> login({
    required String email,
    required String password,
  }) => throw UnimplementedError('login');

  @override
  Future<ApiResult<AuthResultModel>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) => throw UnimplementedError('register');

  @override
  Future<ApiResult<AuthResultModel>> signInWithGoogle() =>
      throw UnimplementedError('signInWithGoogle');

  @override
  Future<ApiResult<Unit>> logout() => throw UnimplementedError('logout');

  @override
  Future<ApiResult<Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) => throw UnimplementedError('resetPassword');

  @override
  Future<ApiResult<Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => throw UnimplementedError('changePassword');

  @override
  Future<ApiResult<UserModel>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) => throw UnimplementedError('updateProfile');

  @override
  Future<ApiResult<Unit>> sendResetCode({required String email}) =>
      throw UnimplementedError('sendResetCode');

  @override
  Future<ApiResult<Unit>> verifyResetCode({
    required String email,
    required String code,
  }) => throw UnimplementedError('verifyResetCode');

  @override
  Future<ApiResult<Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => throw UnimplementedError('confirmNewPassword');
}

class _FakeLocal implements AuthLocalDataSource {
  UserModel? cached;
  bool clearedAll = false;

  @override
  Future<AuthTokensModel?> getTokens() async =>
      const AuthTokensModel(accessToken: 'a', refreshToken: 'r');

  @override
  Future<UserModel?> getCachedUser() async => cached;

  @override
  Future<void> cacheUser(UserModel user) async => cached = user;

  @override
  Future<void> clearAll() async => clearedAll = true;

  @override
  Future<void> clearUser() => throw UnimplementedError('clearUser');

  @override
  Future<void> saveToken(AuthTokensModel tokens) =>
      throw UnimplementedError('saveToken');

  @override
  Future<void> clearTokens() => throw UnimplementedError('clearTokens');

  @override
  Future<bool> isLoggedIn() => throw UnimplementedError('isLoggedIn');
}

void main() {
  late _FakeLocal local;

  AuthRepositoryImpl repo(ApiResult<UserModel> result) =>
      AuthRepositoryImpl(remote: _FakeRemote(result), local: local);

  setUp(() => local = _FakeLocal());

  test('success caches the user and returns it', () async {
    final result = await repo(const ApiSuccess(_user)).getCurrentUser();

    expect(result.isRight(), isTrue);
    expect(local.cached, _user);
    expect(local.clearedAll, isFalse);
  });

  for (final exception in [
    ApiException.unauthorized(),
    ApiException.forbidden(),
  ]) {
    test('${exception.statusCode} clears the session', () async {
      final result = await repo(ApiFailure(exception)).getCurrentUser();

      expect(result.getOrElse(() => _user.toEntity()), isNull);
      expect(local.clearedAll, isTrue);
    });
  }

  for (final exception in [
    ApiException.noInternet(),
    ApiException.timeout(),
    ApiException.server(),
  ]) {
    test('${exception.statusCode ?? exception.message} keeps the session', () async {
      final result = await repo(ApiFailure(exception)).getCurrentUser();

      expect(result.isLeft(), isTrue);
      expect(local.clearedAll, isFalse);
    });
  }
}
