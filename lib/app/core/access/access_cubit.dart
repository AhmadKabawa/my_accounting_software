import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/role.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';

part 'access_state.dart';

/// المصدر الوحيد لدور المستخدم الحالي وصلاحياته في التطبيق.
///
/// - الميزات (مثل auth) تستدعي [setRole] بعد تسجيل الدخول وجلب الدور.
/// - الواجهة تقرأ عبر `PermissionGate` أو `context.can(...)`.
/// - الـ use cases تتحقق عبر [require] وتعيد `PermissionFailure`.
///
/// تنبيه أمني: إخفاء عنصر في الواجهة ليس حماية. التحقق الحقيقي
/// يجب أن يتم في الخادم (RLS)؛ هذه الطبقة لتجربة المستخدم وفشل مبكر فقط.
class AccessCubit extends Cubit<AccessState> {
  AccessCubit() : super(const AccessState(Role.none));

  /// يعيّن دور المستخدم الحالي.
  void setRole(Role role) => emit(AccessState(role));

  /// يزيل أي صلاحيات (عند تسجيل الخروج).
  void clear() => setRole(Role.none);

  bool can(Permission permission) => state.role.allows(permission);

  bool canAny(Iterable<Permission> permissions) =>
      state.role.allowsAny(permissions);

  bool canAll(Iterable<Permission> permissions) =>
      state.role.allowsAll(permissions);

  /// للاستخدام داخل الـ use cases: `Right(unit)` أو `Left(PermissionFailure)`.
  Either<Failure, Unit> require(Permission permission) =>
      can(permission) ? const Right(unit) : Left(PermissionFailure());
}
