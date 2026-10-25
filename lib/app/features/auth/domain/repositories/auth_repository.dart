import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_tokens/auth_tokens.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';

/// Authentication repository interface
/// This is implemented in the data layer
abstract class AuthRepository {
  // ============ المصادقة الأساسية ============

  /// تسجيل الدخول بالإيميل وكلمة المرور
  Future<Either<Failure, AuthResultEntity>> login({
    required String email,
    required String password,
  });

  /// إنشاء حساب جديد
  Future<Either<Failure, AuthResultEntity>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });

  /// تسجيل الدخول بـ Google
  Future<Either<Failure, AuthResultEntity>> signInWithGoogle();

  /// تسجيل الخروج
  Future<Either<Failure, Unit>> logout();

  // ============ إدارة كلمة المرور ============

  /// إرسال كود إعادة تعيين كلمة المرور
  Future<Either<Failure, Unit>> sendResetCode({required String email});

  /// التحقق من كود إعادة تعيين كلمة المرور
  Future<Either<Failure, Unit>> verifyResetCode({
    required String email,
    required String code,
  });

  /// تأكيد كلمة المرور الجديدة
  Future<Either<Failure, Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// إعادة تعيين كلمة المرور (باستخدام token)
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// تغيير كلمة المرور (للمستخدم المسجل)
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // ============ إدارة الملف الشخصي ============

  //   ممكن تكو لال UserRepository اذا عملناه feature

  /// تحديث الملف الشخصي
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  });

  // ============ إدارة الجلسة والتخزين المؤقت ============

  /// جلب المستخدم المحفوظ محلياً
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  // /// حفظ التوكنات
  // Future<void> saveTokens(AuthTokens tokens);

  // /// التحقق من حالة المصادقة
  // Future<bool> isAuthenticated();
}
