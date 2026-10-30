import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/access/access_cubit.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/access/role.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';

void main() {
  late AccessCubit cubit;

  setUp(() => cubit = AccessCubit());
  tearDown(() => cubit.close());

  test('starts with no permissions', () {
    expect(cubit.state.role, Role.none);
    expect(cubit.can(Permissions.sales.view), isFalse);
  });

  test('setRole grants that role permissions', () {
    cubit.setRole(SystemRoles.accountant);

    expect(cubit.can(Permissions.sales.post), isTrue);
    expect(cubit.can(Permissions.users.view), isFalse);
  });

  test('clear removes every permission', () {
    cubit
      ..setRole(SystemRoles.owner)
      ..clear();

    expect(cubit.can(Permissions.sales.view), isFalse);
  });

  test('canAny and canAll', () {
    cubit.setRole(SystemRoles.viewer);

    expect(
      cubit.canAny([Permissions.sales.view, Permissions.sales.edit]),
      isTrue,
    );
    expect(
      cubit.canAll([Permissions.sales.view, Permissions.sales.edit]),
      isFalse,
    );
  });

  test('require returns Right when allowed', () {
    cubit.setRole(SystemRoles.owner);

    expect(
      cubit.require(Permissions.roles.edit),
      const Right<Failure, Unit>(unit),
    );
  });

  test('require returns PermissionFailure when denied', () {
    final result = cubit.require(Permissions.roles.edit);

    expect(result.fold((f) => f, (_) => null), isA<PermissionFailure>());
  });

  test('emits only when the role actually changes', () async {
    final emitted = <Role>[];
    final sub = cubit.stream.listen((s) => emitted.add(s.role));

    cubit
      ..setRole(SystemRoles.cashier)
      ..setRole(SystemRoles.cashier)
      ..setRole(SystemRoles.viewer);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(emitted, [SystemRoles.cashier, SystemRoles.viewer]);
  });
}
