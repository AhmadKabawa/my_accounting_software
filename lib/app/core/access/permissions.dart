import 'package:accounting_software/app/core/access/permission.dart';

/// صلاحيات وحدة واحدة: `Permissions.sales.view`, `Permissions.sales.post` ...
final class ModulePermissions {
  const ModulePermissions(this.module);

  final String module;

  Permission get view => Permission.of(module, PermissionAction.view);
  Permission get create => Permission.of(module, PermissionAction.create);
  Permission get edit => Permission.of(module, PermissionAction.edit);
  Permission get delete => Permission.of(module, PermissionAction.delete);

  /// ترحيل المستند (يصبح غير قابل للتعديل المباشر).
  Permission get post => Permission.of(module, PermissionAction.post);

  /// عكس مستند مرحّل (بديل التعديل الصامت).
  Permission get reverse => Permission.of(module, PermissionAction.reverse);
  Permission get approve => Permission.of(module, PermissionAction.approve);
  Permission get export => Permission.of(module, PermissionAction.export);

  /// كل إجراءات الوحدة.
  Permission get all => Permission.module(module);
}

/// فهرس الصلاحيات المركزي (نفس نمط `AppKeys` و`StorageKeys`).
/// وحدة جديدة = سطر واحد هنا، ولا حاجة لتعديل أي منطق.
abstract final class Permissions {
  static const sales = ModulePermissions('sales');
  static const purchases = ModulePermissions('purchases');
  static const inventory = ModulePermissions('inventory');
  static const customers = ModulePermissions('customers');
  static const suppliers = ModulePermissions('suppliers');
  static const payments = ModulePermissions('payments');
  static const journal = ModulePermissions('journal');
  static const reports = ModulePermissions('reports');
  static const settings = ModulePermissions('settings');
  static const users = ModulePermissions('users');
  static const roles = ModulePermissions('roles');
}
