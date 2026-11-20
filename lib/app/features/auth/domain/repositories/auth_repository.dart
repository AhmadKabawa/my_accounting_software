
import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResultEntity>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, AuthResultEntity>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });
  Future<Either<Failure, AuthResultEntity>> signInWithGoogle();
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, Unit>> sendResetCode({required String email});
  Future<Either<Failure, Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Reads the user's server-owned force-change flag from public.users.
  Future<Either<Failure, bool>> getMustChangePassword({required String userId});

  /// Sets the Auth password, then clears public.users.must_change_password
  /// through the server-owned complete_password_change() RPC.
  Future<Either<Failure, Unit>> forceChangePassword({
    required String newPassword,
  });

  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  });
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
