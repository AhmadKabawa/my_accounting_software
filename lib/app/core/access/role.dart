import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/permissions.dart';

/// دور = اسم + مجموعة صلاحيات ممنوحة.
///
/// الأدوار المخصصة تأتي من الخادم؛ الأدوار الجاهزة في [SystemRoles].
class Role extends Equatable {
  const Role({
    required this.id,
    required this.name,
    required this.permissions,
    this.isSystem = false,
  });

  /// بلا أي صلاحية: الحالة قبل تسجيل الدخول أو بعد الخروج.
  static const none = Role(id: 'none', name: 'none', permissions: {});

  final String id;
  final String name;
  final Set<Permission> permissions;

  /// دور جاهز لا يجوز حذفه أو تعديله من الواجهة.
  final bool isSystem;

  /// هل يملك هذا الدور [permission] (مع مراعاة `*` و`module.*`)؟
  bool allows(Permission permission) =>
      permissions.any((granted) => granted.covers(permission));

  bool allowsAny(Iterable<Permission> required) => required.any(allows);

  bool allowsAll(Iterable<Permission> required) => required.every(allows);

  @override
  List<Object?> get props => [id, name, permissions, isSystem];
}

/// أدوار جاهزة كنقطة بداية. هي سياسة افتراضية للواجهة فقط؛
/// المصدر الحاكم للصلاحيات هو الخادم (RLS) وليس هذه القيم.
abstract final class SystemRoles {
  static const owner = Role(
    id: 'owner',
    name: 'owner',
    permissions: {Permission.all},
    isSystem: true,
  );

  static final accountant = Role(
    id: 'accountant',
    name: 'accountant',
    isSystem: true,
    permissions: {
      Permissions.sales.all,
      Permissions.purchases.all,
      Permissions.customers.all,
      Permissions.suppliers.all,
      Permissions.payments.all,
      Permissions.journal.all,
      Permissions.inventory.view,
      Permissions.reports.view,
      Permissions.reports.export,
    },
  );

  static final cashier = Role(
    id: 'cashier',
    name: 'cashier',
    isSystem: true,
    permissions: {
      Permissions.sales.view,
      Permissions.sales.create,
      Permissions.customers.view,
      Permissions.customers.create,
      Permissions.payments.view,
      Permissions.payments.create,
      Permissions.inventory.view,
    },
  );

  static final viewer = Role(
    id: 'viewer',
    name: 'viewer',
    isSystem: true,
    permissions: {
      Permissions.sales.view,
      Permissions.purchases.view,
      Permissions.inventory.view,
      Permissions.customers.view,
      Permissions.suppliers.view,
      Permissions.payments.view,
      Permissions.journal.view,
      Permissions.reports.view,
    },
  );

  static final all = [owner, accountant, cashier, viewer];
}
