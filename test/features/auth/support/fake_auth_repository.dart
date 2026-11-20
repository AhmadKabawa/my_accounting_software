
import 'dart:async';

import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_tokens/auth_tokens.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

const testUser = UserEntity(id: 'u1', email: 'a@b.c');

/// Scriptable repository: set the result a test needs; calls are recorded.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.onLogout});

  final void Function()? onLogout;
  final calls = <String>[];

  /// The e-mail the last `login` call received (after username resolution).
  String? lastLoginEmail;

  Either<Failure, AuthResultEntity>? authResult;
  Either<Failure, UserEntity?> currentUser = const Right(null);
  Object? currentUserError;
  Object? logoutError;
  Either<Failure, Unit> unitResult = const Right(unit);
  bool mustChangePassword = false;
  Object? passwordFlagError;
  Completer<Either<Failure, UserEntity>>? profile;
  Completer<Either<Failure, Unit>>? forcedPassword;
  Either<Failure, UserEntity>? profileResult;

  static AuthResultEntity success() => const AuthResultEntity(
    user: testUser,
    tokens: AuthTokensEntity(accessToken: 'a', refreshToken: 'r'),
  );

  Future<Either<Failure, AuthResultEntity>> _auth(String name) async {
    calls.add(name);
    return authResult ?? Right(success());
  }

  Future<Either<Failure, Unit>> _unit(String name) async {
    calls.add(name);
    return unitResult;
  }

  @override
  Future<Either<Failure, AuthResultEntity>> login({
    required String email,
    required String password,
  }) {
    lastLoginEmail = email;
    return _auth('login');
  }

  @override
  Future<Either<Failure, AuthResultEntity>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) => _auth('register');

  @override
  Future<Either<Failure, AuthResultEntity>> signInWithGoogle() =>
      _auth('google');

  @override
  Future<Either<Failure, Unit>> logout() async {
    onLogout?.call();
    if (logoutError != null) throw logoutError!;
    return unitResult;
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (currentUserError != null) throw currentUserError!;
    return currentUser;
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) async {
    calls.add('updateProfile');
    return profile != null ? profile!.future : profileResult!;
  }

  @override
  Future<Either<Failure, Unit>> sendResetCode({required String email}) =>
      _unit('sendResetCode');

  @override
  Future<Either<Failure, Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _unit('confirmNewPassword');

  @override
  Future<Either<Failure, bool>> getMustChangePassword({
    required String userId,
  }) async {
    if (passwordFlagError != null) throw passwordFlagError!;
    return Right(mustChangePassword);
  }

  @override
  Future<Either<Failure, Unit>> forceChangePassword({
    required String newPassword,
  }) {
    calls.add('forceChangePassword');
    return forcedPassword?.future ?? Future.value(unitResult);
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _unit('changePassword');
}
