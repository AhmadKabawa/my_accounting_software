import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/keys/access_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import '../../helpers/localized_app.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/presentation/access_status_gate.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';

class _Repository implements AccessRepository {
  Either<Failure, AccessSnapshot> result = Left(NetworkFailure());

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => result;
}

AccessSnapshot _snapshot() => const AccessSnapshot(
  userId: 'u1',
  username: 'admin',
  email: null,
  isSuperAdmin: false,
  roles: [],
  permissions: {},
  branches: [
    AccessBranch(
      id: 1,
      code: 'MAIN',
      name: 'Main',
      canView: true,
      canOperate: true,
    ),
  ],
  warehouses: [],
  posTerminals: [],
);

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets(
    'blocks shell during loading and after failure; retry can unlock it',
    (tester) async {
      final repository = _Repository();
      final access = AccessCubit(getMyAccess: GetMyAccessUseCase(repository));
      addTearDown(access.close);
      await tester.pumpWidget(
        BlocProvider.value(
          value: access,
          child: buildTestApp(
            home: const AccessStatusGate(
              signOutLabel: AuthKeys.signOut,
              child: Text('protected shell'),
            ),
          ),
        ),
      );

      expect(find.text('protected shell'), findsNothing);

      await access.load();
      await tester.pump();
      expect(find.text('protected shell'), findsNothing);

      repository.result = Right(_snapshot());
      await access.retry();
      await tester.pump();
      expect(find.text('protected shell'), findsOneWidget);
    },
  );
  testWidgets('shows a dedicated no-branches state without retry or shell', (
    tester,
  ) async {
    final repository = _Repository()
      ..result = Right(
        const AccessSnapshot(
          userId: 'u1',
          username: 'admin',
          email: null,
          isSuperAdmin: false,
          roles: [],
          permissions: {Permission('sales.view')},
          branches: [
            AccessBranch(
              id: 1,
              code: 'HIDDEN',
              name: 'Hidden',
              canView: false,
              canOperate: false,
            ),
          ],
          warehouses: [],
          posTerminals: [],
        ),
      );
    final access = AccessCubit(getMyAccess: GetMyAccessUseCase(repository));
    addTearDown(access.close);
    await access.load();

    await tester.pumpWidget(
      BlocProvider.value(
        value: access,
        child: buildTestApp(
          home: const AccessStatusGate(
            signOutLabel: AuthKeys.signOut,
            onSignOut: () async => true,
            child: Text('protected shell'),
          ),
        ),
      ),
    );

    expect(find.text(AccessKeys.noAvailableBranches.en), findsOneWidget);
    expect(find.text('protected shell'), findsNothing);
    expect(find.text('Retry'), findsNothing);
    expect(find.text('Sign out'), findsOneWidget);
  });
}
