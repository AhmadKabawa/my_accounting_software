// lib/features/auth/data/repositories/auth_repository_impl.dart
// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/exceptions.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/error/error_handling/mapper/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/auth/data/datasources/local_data_source/auth_local_data_source.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_result/auth_result_model.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  // ─── Helper مشترك ───────────────────────────────────
  Future<Either<Failure, T>> _execute<T>(
    Future<Either<Failure, T>> Function() action,
  ) async {
    try {
      return await action();
    } on AppException catch (e) {
      return Left(ExceptionMapper.map(e));
    } catch (e) {
      final exception = ApiException.unknown(serverMessage: e.toString());

      return Left(ExceptionMapper.map(exception));
    }
  }

  // ─── Login ──────────────────────────────────────────
  @override
  Future<Either<Failure, AuthResultEntity>> login({
    required String email,
    required String password,
  }) => _execute(() async {
    final result = await _remote.login(email: email, password: password);
    return result.toEitherAsync(_startSession);
  });

  // ─── Register ───────────────────────────────────────
  @override
  Future<Either<Failure, AuthResultEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) => _execute(() async {
    final result = await _remote.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    return result.toEitherAsync(_startSession);
  });

  // ─── Google Sign-In ─────────────────────────────────
  @override
  Future<Either<Failure, AuthResultEntity>> signInWithGoogle() =>
      _execute(() async {
        final result = await _remote.signInWithGoogle();
        return result.toEitherAsync(_startSession);
      });

  // ─── Logout ─────────────────────────────────────────
  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      // حاول تعلم السيرفر — لو فشل (مافي نت) اكمل
      await _remote.logout();
    } catch (_) {}

    try {
      await _local.clearAll();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(ExceptionMapper.map(e));
    }
  }

  // ─── Send Reset Code ────────────────────────────────
  @override
  Future<Either<Failure, Unit>> sendResetCode({required String email}) =>
      _execute(() async => (await _remote.sendResetCode(email: email)).toEither());

  // ─── Verify Reset Code ──────────────────────────────
  @override
  Future<Either<Failure, Unit>> verifyResetCode({
    required String email,
    required String code,
  }) => _execute(
    () async =>
        (await _remote.verifyResetCode(email: email, code: code)).toEither(),
  );

  // ─── Confirm New Password ───────────────────────────
  @override
  Future<Either<Failure, Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _execute(
    () async => (await _remote.confirmNewPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    )).toEither(),
  );

  // ─── Reset Password ─────────────────────────────────
  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) => _execute(
    () async => (await _remote.resetPassword(
      token: token,
      newPassword: newPassword,
    )).toEither(),
  );

  // ─── Change Password ────────────────────────────────
  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _execute(
    () async => (await _remote.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    )).toEither(),
  );

  // ─── Update Profile ─────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) => _execute(() async {
    final result = await _remote.updateProfile(
      fullName: fullName,
      avatarUrl: avatarUrl,
      phone: phone,
    );
    return result.toEitherAsync((userModel) async {
      await _local.cacheUser(userModel);
      return userModel.toEntity();
    });
  });

  // ─── Get Current User ───────────────────────────────
  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final tokens = await _local.getTokens();
      if (tokens == null) return const Right(null);

      final cachedUser = await _local.getCachedUser();
      if (cachedUser != null) return Right(cachedUser.toEntity());

      final apiResult = await _remote.getCurrentUser();
      return apiResult.when(
        success: (remoteUser) async {
          await _local.cacheUser(remoteUser);
          return Right(remoteUser.toEntity());
        },
        failure: (exception) async {
          // await _local.clearTokens();
          await _local.clearAll();
          return const Right(null);
        },
      );
    } on CacheException catch (e) {
      return Left(ExceptionMapper.map(e));
    } catch (_) {
      return Left(ExceptionMapper.map(ApiException.unknown())); // ✅
    }
  }

  // ─── Private: Start Session ─────────────────────────
  Future<AuthResultEntity> _startSession(AuthResultModel authResult) async {
    await _local.cacheUser(authResult.user);
    await _local.saveToken(authResult.tokens);
    return AuthResultEntity(
      user: authResult.user.toEntity(),
      tokens: authResult.tokens.toEntity(),
    );
  }
}
