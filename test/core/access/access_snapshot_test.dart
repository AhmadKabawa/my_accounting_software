import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';

Map<String, dynamic> validResponse({Object? email = 'admin@example.test'}) => {
  'user_id': '00000000-0000-0000-0000-000000000001',
  'username': 'admin',
  'email': email,
  'is_super_admin': true,
  'roles': [
    {'code': 'SUPER_ADMIN', 'name': 'مدير النظام'},
  ],
  'permissions': ['sales.view', 'sales.post', 'future.permission'],
  'branches': [
    {
      'branch_id': 1,
      'code': 'MAIN',
      'name': 'الفرع الرئيسي',
      'can_view': true,
      'can_operate': true,
    },
  ],
  'warehouses': [
    {
      'warehouse_id': 3,
      'code': 'WH-CENTRAL',
      'name': 'المستودع المركزي',
      'type': 'CENTRAL',
      'branch_id': null,
      'is_sellable': false,
    },
  ],
  'pos_terminals': [
    {
      'pos_terminal_id': 2,
      'code': 'POS-01',
      'name': 'نقطة البيع 1',
      'branch_id': 1,
      'is_default': true,
    },
  ],
};

void main() {
  test(
    'parses the documented contract and ignores unknown permission codes',
    () {
      final snapshot = AccessSnapshot.fromJson(validResponse());

      expect(snapshot.userId, startsWith('00000000-'));
      expect(snapshot.roles.single.code, 'SUPER_ADMIN');
      expect(snapshot.permissions, {
        const Permission('sales.view'),
        const Permission('sales.post'),
      });
      expect(snapshot.branches.single.canOperate, isTrue);
      expect(snapshot.warehouses.single.branchId, isNull);
      expect(snapshot.posTerminals.single.isDefault, isTrue);
    },
  );

  test('accepts nullable email as defined by public.users', () {
    expect(AccessSnapshot.fromJson(validResponse(email: null)).email, isNull);
  });

  test('rejects a missing email key even though email may be null', () {
    final json = validResponse()..remove('email');
    expect(
      () => AccessSnapshot.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a missing nullable warehouse branch_id key', () {
    final json = validResponse();
    (json['warehouses'] as List).first.remove('branch_id');
    expect(
      () => AccessSnapshot.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a missing required field', () {
    final json = validResponse()..remove('branches');
    expect(
      () => AccessSnapshot.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'rejects a malformed nested field rather than granting partial access',
    () {
      final json = validResponse();
      (json['branches'] as List).first['can_operate'] = 'yes';
      expect(
        () => AccessSnapshot.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    },
  );
}
