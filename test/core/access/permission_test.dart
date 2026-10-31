import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/access/role.dart';

void main() {
  group('Permission.covers', () {
    test('exact permission covers itself only', () {
      expect(Permissions.sales.view.covers(Permissions.sales.view), isTrue);
      expect(Permissions.sales.view.covers(Permissions.sales.edit), isFalse);
    });

    test('module wildcard covers its module but not others', () {
      expect(Permissions.sales.all.covers(Permissions.sales.post), isTrue);
      expect(Permissions.sales.all.covers(Permissions.purchases.view), isFalse);
    });

    test('module wildcard does not match a module with the same prefix', () {
      expect(
        const Permission('sales.*').covers(const Permission('salesman.view')),
        isFalse,
      );
    });

    test('global wildcard covers everything', () {
      expect(Permission.all.covers(Permissions.journal.reverse), isTrue);
    });

    test('of() builds module.action', () {
      expect(Permission.of('sales', PermissionAction.post).value, 'sales.post');
    });
  });

  group('Role', () {
    test('none allows nothing', () {
      expect(Role.none.allows(Permissions.sales.view), isFalse);
    });

    test('owner allows everything', () {
      expect(SystemRoles.owner.allows(Permissions.roles.delete), isTrue);
    });

    test('cashier cannot post or reverse documents', () {
      expect(SystemRoles.cashier.allows(Permissions.sales.create), isTrue);
      expect(SystemRoles.cashier.allows(Permissions.sales.post), isFalse);
      expect(SystemRoles.cashier.allows(Permissions.journal.reverse), isFalse);
    });

    test('allowsAny / allowsAll', () {
      final role = SystemRoles.viewer;
      final view = Permissions.sales.view;
      final edit = Permissions.sales.edit;

      expect(role.allowsAny([view, edit]), isTrue);
      expect(role.allowsAll([view, edit]), isFalse);
    });

    test('roles with the same data are equal', () {
      const a = Role(id: 'r', name: 'r', permissions: {Permission.all});
      const b = Role(id: 'r', name: 'r', permissions: {Permission.all});

      expect(a, b);
    });
  });
}
