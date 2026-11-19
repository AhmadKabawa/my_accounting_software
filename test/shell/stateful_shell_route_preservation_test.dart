import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/shell/app_shell.dart';
import 'package:accounting_software/app/shell/destinations.dart';
import '../helpers/localized_app.dart';

class _Repository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'test-user',
      username: 'test',
      email: null,
      isSuperAdmin: false,
      roles: const [],
      permissions: const {Permission('sales.view')},
      branches: const [],
      warehouses: const [],
      posTerminals: const [],
    ),
  );
}

class _FormBranch extends StatefulWidget {
  const _FormBranch();

  @override
  State<_FormBranch> createState() => _FormBranchState();
}

class _FormBranchState extends State<_FormBranch> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    key: const ValueKey('unsaved-form-field'),
    controller: controller,
  );
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('indexedStack preserves form state across branch switches', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final access = AccessCubit(getMyAccess: GetMyAccessUseCase(_Repository()));
    await access.load();
    addTearDown(access.close);

    final destinations = [
      AppDestination(
        item: NavBarItem(icon: Icons.looks_one_outlined, label: NavKeys.home),
        branchIndex: 0,
      ),
      AppDestination(
        item: NavBarItem(icon: Icons.looks_two_outlined, label: NavKeys.home),
        branchIndex: 1,
      ),
    ];
    final router = GoRouter(
      initialLocation: '/form',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(
            navigationShell: shell,
            destinations: destinations,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/form', builder: (_, _) => const _FormBranch()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/other',
                  builder: (_, _) => const Text('Other branch'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider.value(
        value: access,
        child: buildTestApp(router: router, theme: AppTheme.light()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('unsaved-form-field')),
      'unsaved value',
    );
    await tester.tap(find.byIcon(Icons.looks_two_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Other branch'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.looks_one_outlined));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('unsaved-form-field')))
          .controller!
          .text,
      'unsaved value',
    );
  });
}
