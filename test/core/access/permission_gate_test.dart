import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';

class _Repository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async =>
      Right(AccessSnapshot(
        userId: 'u1',
        username: 'admin',
        email: null,
        isSuperAdmin: false,
        roles: const [],
        permissions: const {Permission('sales.post')},
        branches: const [],
        warehouses: const [],
        posTerminals: const [],
      ));
}

void main() {
  testWidgets('remains closed while loading and opens only after server success', (tester) async {
    final cubit = AccessCubit(
      getMyAccess: GetMyAccessUseCase(_Repository()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const PermissionGate(
            permission: Permission('sales.post'),
            fallback: Text('denied'),
            child: Text('allowed'),
          ),
        ),
      ),
    );

    expect(find.text('denied'), findsOneWidget);
    await cubit.load();
    await tester.pump();
    expect(find.text('allowed'), findsOneWidget);

    cubit.clear();
    await tester.pump();
    expect(find.text('denied'), findsOneWidget);
  });
}
