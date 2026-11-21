import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
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
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, AuthResultEntity>> login({
    required String email,
    required String password,
  }) => execute(
    () async => (await _remote.login(
      email: email,
      password: password,
    )).toEitherAsync(_startSession),
  );

  @override
  Future<Either<Failure, AuthResultEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) => execute(
    () async => (await _remote.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    )).toEitherAsync(_startSession),
  );

  @override
  Future<Either<Failure, AuthResultEntity>> signInWithGoogle() => execute(
    () async => (await _remote.signInWithGoogle()).toEitherAsync(_startSession),
  );

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remote.logout();
    } catch (e) {
      Logger.warning(
        'Logout: server revocation failed; clearing the local session anyway (${e.runtimeType})',
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

  @override
  Future<Either<Failure, Unit>> sendResetCode({required String email}) =>
      execute(
        () async => (await _remote.sendResetCode(email: email)).toEither(),
      );

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

  @override
  Future<Either<Failure, bool>> getMustChangePassword({
    required String userId,
  }) => execute(
    () async =>
        (await _remote.getMustChangePassword(userId: userId)).toEither(),
  );

  @override
  Future<Either<Failure, Unit>> forceChangePassword({
    required String newPassword,
  }) => execute(() async {
    final password = await _remote.setPasswordWithoutCurrent(
      newPassword: newPassword,
    );
    if (password is ApiFailure<Unit>) {
      return Left(ExceptionMapper.map(password.exception));
    }
    // Clear the server-owned flag only after Auth accepted the new password.
    return (await _remote.completePasswordChange()).toEither();
  });

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
      return Left(ExceptionMapper.map(ApiException.unknown()));
    }
  }

  Future<Either<Failure, UserEntity?>> _cacheRemoteUser(UserModel user) async {
    await _local.cacheUser(user);
    return Right(user.toEntity());
  }

  Future<Either<Failure, UserEntity?>> _onUserFetchFailed(
    AppException exception,
  ) async {
    if (exception.statusCode == 401 || exception.statusCode == 403) {
      await _local.clearAll();
      return const Right(null);
    }
    return Left(ExceptionMapper.map(exception));
  }

  Future<AuthResultEntity> _startSession(AuthResultModel authResult) async {
    await _local.saveToken(authResult.tokens);
    await _local.cacheUser(authResult.user);
    return AuthResultEntity(
      user: authResult.user.toEntity(),
      tokens: authResult.tokens.toEntity(),
    );
  }
}
