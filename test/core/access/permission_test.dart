import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/known_permission_codes.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/permissions.dart';

void main() {
  group('Permission.covers', () {
    test('exact permission covers itself only', () {
      expect(Permissions.sales.view.covers(Permissions.sales.view), isTrue);
      expect(Permissions.sales.view.covers(Permissions.sales.post), isFalse);
    });

    test('global wildcard does not cover a catalog permission', () {
      expect(const Permission('*').covers(Permissions.sales.view), isFalse);
    });

    test('module wildcard does not cover an action or a prefixed module', () {
      const wildcard = Permission('sales.*');
      expect(wildcard.covers(Permissions.sales.post), isFalse);
      expect(wildcard.covers(const Permission('salesman.view')), isFalse);
    });

    test('of() builds module.action', () {
      expect(Permission.of('sales', PermissionAction.post).value, 'sales.post');
    });
  });

  test('typed permission groups contain only server catalog codes', () {
    final used = {
      Permissions.sales.view,
      Permissions.sales.create,
      Permissions.sales.discount,
      Permissions.sales.post,
      Permissions.sales.returnDocument,
      Permissions.purchasing.view,
      Permissions.purchasing.create,
      Permissions.purchasing.post,
      Permissions.purchasing.returnDocument,
      Permissions.inventory.view,
      Permissions.inventory.adjust,
      Permissions.inventory.transfer,
      Permissions.inventory.transferApprove,
      Permissions.inventory.viewOtherBranches,
      Permissions.parties.view,
      Permissions.parties.manage,
      Permissions.parties.quickAdd,
      Permissions.finance.view,
      Permissions.finance.manage,
      Permissions.finance.payments,
      Permissions.finance.expenses,
      Permissions.accounting.view,
      Permissions.accounting.manage,
      Permissions.accounting.post,
      Permissions.reports.view,
      Permissions.settings.manage,
      Permissions.users.manage,
      Permissions.organization.manage,
      Permissions.catalog.manage,
      Permissions.costs.view,
      Permissions.costs.manage,
      Permissions.discounts.exceptional,
      Permissions.fxRates.manage,
      Permissions.fxRates.manual,
      Permissions.hr.view,
      Permissions.hr.manage,
      Permissions.pos.manage,
      Permissions.pos.session,
      Permissions.pricing.manage,
      Permissions.payment.cancel,
      Permissions.reconcile.cash,
      Permissions.audit.view,
      Permissions.balance.adjust,
      Permissions.owner.transactions,
      Permissions.masterData.manage,
      Permissions.warehouse.centralAccess,
    };

    final codes = used.map((permission) => permission.value).toSet();
    expect(KnownPermissionCodes.values.containsAll(codes), isTrue);
  });
}
