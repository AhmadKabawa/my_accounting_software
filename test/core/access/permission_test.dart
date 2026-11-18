import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/permissions.dart';

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
}
