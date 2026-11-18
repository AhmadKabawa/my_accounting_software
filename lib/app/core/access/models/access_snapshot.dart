import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/access/known_permission_codes.dart';
import 'package:accounting_software/app/core/access/permission.dart';

/// Immutable, in-memory representation of the exact get_my_access() contract.
class AccessSnapshot extends Equatable {
  const AccessSnapshot({
    required this.userId,
    required this.username,
    required this.email,
    required this.isSuperAdmin,
    required this.roles,
    required this.permissions,
    required this.branches,
    required this.warehouses,
    required this.posTerminals,
  });

  final String userId;
  final String username;
  final String? email;
  final bool isSuperAdmin;
  final List<AccessRole> roles;
  final Set<Permission> permissions;
  final List<AccessBranch> branches;
  final List<AccessWarehouse> warehouses;
  final List<AccessPosTerminal> posTerminals;

  factory AccessSnapshot.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.isEmpty) {
        throw FormatException('get_my_access: invalid $key');
      }
      return value;
    }

    bool requiredBool(Map<String, dynamic> source, String key) {
      final value = source[key];
      if (value is! bool) throw FormatException('get_my_access: invalid $key');
      return value;
    }

    int requiredInt(Map<String, dynamic> source, String key) {
      final value = source[key];
      if (value is! int) throw FormatException('get_my_access: invalid $key');
      return value;
    }

    String nestedString(Map<String, dynamic> source, String key) {
      final value = source[key];
      if (value is! String || value.isEmpty) {
        throw FormatException('get_my_access: invalid $key');
      }
      return value;
    }

    List<Map<String, dynamic>> objects(String key) {
      final value = json[key];
      if (value is! List) throw FormatException('get_my_access: invalid $key');
      return value
          .map((item) {
            if (item is! Map) {
              throw FormatException('get_my_access: invalid $key item');
            }
            return Map<String, dynamic>.from(item);
          })
          .toList(growable: false);
    }

    if (!json.containsKey('email')) {
      throw const FormatException('get_my_access: missing email');
    }
    final emailValue = json['email'];
    if (emailValue != null && emailValue is! String) {
      throw const FormatException('get_my_access: invalid email');
    }

    final rawPermissions = json['permissions'];
    if (rawPermissions is! List ||
        rawPermissions.any((value) => value is! String)) {
      throw const FormatException('get_my_access: invalid permissions');
    }

    final permissions = <Permission>{
      for (final value in rawPermissions.cast<String>())
        if (KnownPermissionCodes.values.contains(value)) Permission(value),
    };

    return AccessSnapshot(
      userId: requiredString('user_id'),
      username: requiredString('username'),
      email: emailValue as String?,
      isSuperAdmin: requiredBool(json, 'is_super_admin'),
      roles: objects('roles')
          .map(
            (item) => AccessRole(
              code: nestedString(item, 'code'),
              name: nestedString(item, 'name'),
            ),
          )
          .toList(growable: false),
      permissions: permissions,
      branches: objects('branches')
          .map(
            (item) => AccessBranch(
              id: requiredInt(item, 'branch_id'),
              code: nestedString(item, 'code'),
              name: nestedString(item, 'name'),
              canView: requiredBool(item, 'can_view'),
              canOperate: requiredBool(item, 'can_operate'),
            ),
          )
          .toList(growable: false),
      warehouses: objects('warehouses')
          .map((item) {
            if (!item.containsKey('branch_id')) {
              throw const FormatException('get_my_access: missing branch_id');
            }
            final branchId = item['branch_id'];
            if (branchId != null && branchId is! int) {
              throw const FormatException('get_my_access: invalid branch_id');
            }
            return AccessWarehouse(
              id: requiredInt(item, 'warehouse_id'),
              code: nestedString(item, 'code'),
              name: nestedString(item, 'name'),
              type: nestedString(item, 'type'),
              branchId: branchId as int?,
              isSellable: requiredBool(item, 'is_sellable'),
            );
          })
          .toList(growable: false),
      posTerminals: objects('pos_terminals')
          .map(
            (item) => AccessPosTerminal(
              id: requiredInt(item, 'pos_terminal_id'),
              code: nestedString(item, 'code'),
              name: nestedString(item, 'name'),
              branchId: requiredInt(item, 'branch_id'),
              isDefault: requiredBool(item, 'is_default'),
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  List<Object?> get props => [
    userId,
    username,
    email,
    isSuperAdmin,
    roles,
    permissions,
    branches,
    warehouses,
    posTerminals,
  ];
}

class AccessRole extends Equatable {
  const AccessRole({required this.code, required this.name});
  final String code;
  final String name;
  @override
  List<Object?> get props => [code, name];
}

class AccessBranch extends Equatable {
  const AccessBranch({
    required this.id,
    required this.code,
    required this.name,
    required this.canView,
    required this.canOperate,
  });
  final int id;
  final String code;
  final String name;
  final bool canView;
  final bool canOperate;
  @override
  List<Object?> get props => [id, code, name, canView, canOperate];
}

class AccessWarehouse extends Equatable {
  const AccessWarehouse({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.branchId,
    required this.isSellable,
  });
  final int id;
  final String code;
  final String name;
  final String type;
  final int? branchId;
  final bool isSellable;
  @override
  List<Object?> get props => [id, code, name, type, branchId, isSellable];
}

class AccessPosTerminal extends Equatable {
  const AccessPosTerminal({
    required this.id,
    required this.code,
    required this.name,
    required this.branchId,
    required this.isDefault,
  });
  final int id;
  final String code;
  final String name;
  final int branchId;
  final bool isDefault;
  @override
  List<Object?> get props => [id, code, name, branchId, isDefault];
}
