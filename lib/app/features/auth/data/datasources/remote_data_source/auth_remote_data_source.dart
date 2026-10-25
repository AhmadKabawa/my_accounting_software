import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_result/auth_result_model.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResult<AuthResultModel>> login({
    required String email,
    required String password,
  });

  Future<ApiResult<AuthResultModel>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<ApiResult<UserModel>> getCurrentUser();

  Future<ApiResult<AuthResultModel>> signInWithGoogle();

  Future<ApiResult<Unit>> logout();

  Future<ApiResult<Unit>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<ApiResult<Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<ApiResult<UserModel>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  });

  Future<ApiResult<Unit>> sendResetCode({required String email});

  Future<ApiResult<Unit>> verifyResetCode({
    required String email,
    required String code,
  });

  Future<ApiResult<Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
