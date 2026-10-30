import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/access/access_cubit.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/access/role.dart';
import 'package:accounting_software/app/core/presentation/widgets/permission_gate/permission_gate.dart';

void main() {
  Future<AccessCubit> pump(WidgetTester tester) async {
    final cubit = AccessCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: PermissionGate(
            permission: Permissions.sales.post,
            fallback: const Text('denied'),
            child: const Text('allowed'),
          ),
        ),
      ),
    );
    return cubit;
  }

  testWidgets('shows fallback without the permission', (tester) async {
    await pump(tester);

    expect(find.text('denied'), findsOneWidget);
    expect(find.text('allowed'), findsNothing);
  });

  testWidgets('switches to child when the role gains the permission', (
    tester,
  ) async {
    final cubit = await pump(tester);

    cubit.setRole(SystemRoles.accountant);
    await tester.pump();

    expect(find.text('allowed'), findsOneWidget);
  });

  testWidgets('goes back to fallback after clear', (tester) async {
    final cubit = await pump(tester);
    cubit.setRole(SystemRoles.owner);
    await tester.pump();

    cubit.clear();
    await tester.pump();

    expect(find.text('denied'), findsOneWidget);
  });
}
