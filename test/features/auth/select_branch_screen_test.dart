import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/scope_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/pages/select_branch/select_branch_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/localized_app.dart';

class _Repo implements AccessRepository {
  _Repo(this.snapshot);
  final AccessSnapshot snapshot;

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async =>
      Right(snapshot);
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  const branches = [
    AccessBranch(
      id: 1,
      code: 'MAIN',
      name: 'Main branch',
      canView: true,
      canOperate: true,
    ),
    AccessBranch(
      id: 2,
      code: 'SEC',
      name: 'Second branch',
      canView: true,
      canOperate: false,
    ),
    AccessBranch(
      id: 3,
      code: 'HID',
      name: 'Hidden branch',
      canView: false,
      canOperate: false,
    ),
  ];

  late AccessCubit cubit;

  setUp(() async {
    cubit = AccessCubit(
      getMyAccess: GetMyAccessUseCase(
        _Repo(
          const AccessSnapshot(
            userId: 'u1',
            username: 'admin',
            email: null,
            isSuperAdmin: false,
            roles: [AccessRole(code: 'MANAGER', name: 'Manager')],
            permissions: {Permission('sales.view')},
            branches: branches,
            warehouses: [],
            posTerminals: [],
          ),
        ),
      ),
    );
    addTearDown(cubit.close);
    await cubit.load();
  });

  Future<void> pump(WidgetTester tester) async {
    setScreenSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      buildTestApp(
        home: BlocProvider<AccessCubit>.value(
          value: cubit,
          child: const SelectBranchScreen(),
        ),
      ),
    );
  }

  testWidgets('lists viewable branches only, with a view-only badge', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Main branch'), findsOneWidget);
    expect(find.text('Second branch'), findsOneWidget);
    expect(find.text('Hidden branch'), findsNothing);
    expect(find.text(ScopeKeys.viewOnly.en), findsOneWidget);
  });

  testWidgets('continue is disabled until a branch is chosen', (tester) async {
    await pump(tester);

    AppButton button() => tester.widget<AppButton>(find.byType(AppButton));
    expect(button().onPressed, isNull);

    await tester.tap(find.text('Second branch'));
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });

  testWidgets('continue selects the chosen branch', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Second branch'));
    await tester.pump();
    await tester.tap(find.text(AuthKeys.continueAction.en));
    await tester.pumpAndSettle();

    expect(cubit.state.selectedBranchId, 2);
  });
}
