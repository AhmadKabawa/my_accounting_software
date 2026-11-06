import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/utils/logger.dart';
import 'package:accounting_software/app/features/auth/data/datasources/local_data_source/auth_local_data_source.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_result/auth_result_model.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl with RepositoryExecutor implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  // ─── Login ──────────────────────────────────────────
  @override
  Future<Either<Failure, AuthResultEntity>> login({
    required String email,
    required String password,
  }) => execute(() async {
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
  }) => execute(() async {
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
      execute(() async {
        final result = await _remote.signInWithGoogle();
        return result.toEitherAsync(_startSession);
      });

  // ─── Logout ─────────────────────────────────────────
  @override
  Future<Either<Failure, Unit>> logout() async {
    // Security decision (documented in docs/architecture/SECURITY_DECISIONS.md):
    // the user always leaves locally, even when the server cannot be told, so
    // the refresh token may stay valid server-side until it expires.
    try {
      await _remote.logout();
    } catch (e) {
      Logger.warning(
        'Logout: server revocation failed; clearing the local session anyway '
        '(${e.runtimeType})',
        name: 'AuthRepository',
      );
    }

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
      execute(() async => (await _remote.sendResetCode(email: email)).toEither());

  // ─── Confirm New Password ───────────────────────────
  @override
  Future<Either<Failure, Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => execute(
    () async => (await _remote.confirmNewPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    )).toEither(),
  );

  // ─── Change Password ────────────────────────────────
  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => execute(
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
  }) => execute(() async {
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

      return switch (await _remote.getCurrentUser()) {
        ApiSuccess(:final data) => await _cacheRemoteUser(data),
        ApiFailure(:final exception) => await _onUserFetchFailed(exception),
      };
    } on CacheException catch (e) {
      return Left(ExceptionMapper.map(e));
    } catch (_) {
      return Left(ExceptionMapper.map(ApiException.unknown())); // ✅
    }
  }

  Future<Either<Failure, UserEntity?>> _cacheRemoteUser(UserModel user) async {
    await _local.cacheUser(user);
    return Right(user.toEntity());
  }

  /// The session is dropped only when the server rejects it (401/403);
  /// a network or server failure must not log the user out.
  Future<Either<Failure, UserEntity?>> _onUserFetchFailed(
    AppException exception,
  ) async {
    if (exception.statusCode == 401 || exception.statusCode == 403) {
      await _local.clearAll();
      return const Right(null);
    }
    return Left(ExceptionMapper.map(exception));
  }

  // ─── Private: Start Session ─────────────────────────
  Future<AuthResultEntity> _startSession(AuthResultModel authResult) async {
    // Token first: if the second write fails, a token without a cached user is
    // harmless (getCurrentUser fetches the user from the server), whereas a
    // cached user without a token would look like a half-open session.
    await _local.saveToken(authResult.tokens);
    await _local.cacheUser(authResult.user);
    return AuthResultEntity(
      user: authResult.user.toEntity(),
      tokens: authResult.tokens.toEntity(),
    );
  }
}
