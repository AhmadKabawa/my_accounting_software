import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/localization/translations/asset_loader.dart';
import 'package:accounting_software/app/localization/key_registry.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_rail/app_navigation_rail.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/shell/app_shell.dart';
import 'package:accounting_software/app/shell/destinations.dart';

const _secret = Permission('shell_test.view');

AccessSnapshot _snapshot(Set<Permission> permissions) => AccessSnapshot(
  userId: 'u1',
  username: 'shell-test',
  email: null,
  isSuperAdmin: false,
  roles: const [],
  permissions: permissions,
  branches: const [],
  warehouses: const [],
  posTerminals: const [],
);

class _FakeAccessRepository implements AccessRepository {
  _FakeAccessRepository(Set<Permission> permissions)
    : result = Right(_snapshot(permissions));

  Either<Failure, AccessSnapshot> result;

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => result;
}

AppDestination _dest(IconData icon, int branch, {Permission? permission}) =>
    AppDestination(
      item: NavBarItem(icon: icon, label: NavKeys.home),
      branchIndex: branch,
      permission: permission,
    );

final _destinations = [
  _dest(Icons.looks_one_outlined, 0),
  _dest(Icons.looks_two_outlined, 1, permission: _secret),
  _dest(Icons.looks_3_outlined, 2),
];

GoRouter _router() => GoRouter(
  initialLocation: '/a',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          AppShell(navigationShell: shell, destinations: _destinations),
      branches: [
        for (final path in ['/a', '/b', '/c'])
          StatefulShellBranch(
            routes: [GoRoute(path: path, builder: (_, _) => Text(path))],
          ),
      ],
    ),
  ],
);

Future<
  ({GoRouter router, AccessCubit access, _FakeAccessRepository repository})
>
_pump(
  WidgetTester tester,
  Size size, {
  Set<Permission> permissions = const {Permission.all},
  List<AppDestination>? destinations,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _FakeAccessRepository(permissions);
  final access = AccessCubit(getMyAccess: GetMyAccessUseCase(repository));
  await access.load();
  addTearDown(access.close);

  final router = destinations == null
      ? _router()
      : GoRouter(
          initialLocation: '/a',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, shell) =>
                  AppShell(navigationShell: shell, destinations: destinations),
              branches: [
                for (final path in ['/a', '/b', '/c'])
                  StatefulShellBranch(
                    routes: [
                      GoRoute(path: path, builder: (_, _) => const SizedBox()),
                    ],
                  ),
              ],
            ),
          ],
        );
  addTearDown(router.dispose);

  await EasyLocalization.ensureInitialized();
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      assetLoader: MyDartLoader(allKeys),
      child: Builder(
        builder: (context) => BlocProvider.value(
          value: access,
          child: MaterialApp.router(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, access: access, repository: repository);
}

String _location(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

void main() {
  group('the navigation follows the device', () {
    testWidgets('phone → bottom bar only', (tester) async {
      await _pump(tester, const Size(390, 844));

      expect(find.byType(AppNavigationBar), findsOneWidget);
      expect(find.byType(AppNavigationRail), findsNothing);
      expect(find.byType(AppSidebar), findsNothing);
    });

    testWidgets('the bottom bar is in bottomNavigationBar, not a FAB', (
      tester,
    ) async {
      await _pump(tester, const Size(390, 844));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomNavigationBar, isA<AppNavigationBar>());
      expect(scaffold.floatingActionButton, isNull);
    });

    testWidgets('tablet → rail only', (tester) async {
      await _pump(tester, const Size(800, 1280));

      expect(find.byType(AppNavigationRail), findsOneWidget);
      expect(find.byType(AppNavigationBar), findsNothing);
      expect(find.byType(AppSidebar), findsNothing);
    });

    testWidgets('desktop → sidebar only', (tester) async {
      await _pump(tester, const Size(1400, 900));

      expect(find.byType(AppSidebar), findsOneWidget);
      expect(find.byType(AppNavigationBar), findsNothing);
      expect(find.byType(AppNavigationRail), findsNothing);
    });

    testWidgets('phone landscape (844×390) keeps the bottom bar', (
      tester,
    ) async {
      await _pump(tester, const Size(844, 390));

      expect(find.byType(AppNavigationBar), findsOneWidget);
      expect(find.byType(AppNavigationRail), findsNothing);
    });

    testWidgets('the shell adds no SafeArea around the screens', (
      tester,
    ) async {
      await _pump(tester, const Size(1400, 900));

      final shellSafeArea = find.ancestor(
        of: find.byType(Scaffold),
        matching: find.byType(SafeArea),
      );
      expect(shellSafeArea, findsNothing);
    });
  });

  group('taps go to the right branch', () {
    testWidgets('tapping a destination calls goBranch with its index', (
      tester,
    ) async {
      final env = await _pump(tester, const Size(1400, 900));
      expect(_location(env.router), '/a');

      await tester.tap(find.byIcon(Icons.looks_3_outlined));
      await tester.pumpAndSettle();

      expect(_location(env.router), '/c');
    });
  });

  group('permissions', () {
    testWidgets('a hidden destination is not shown', (tester) async {
      await _pump(
        tester,
        const Size(1400, 900),
        permissions: const <Permission>{},
      );

      expect(find.byIcon(Icons.looks_one_outlined), findsOneWidget);
      expect(find.byIcon(Icons.looks_two_outlined), findsNothing);
      expect(find.byIcon(Icons.looks_3_outlined), findsOneWidget);
    });

    testWidgets('filtering does not shift the branch of later tabs', (
      tester,
    ) async {
      final env = await _pump(
        tester,
        const Size(1400, 900),
        permissions: const <Permission>{},
      );

      await tester.tap(find.byIcon(Icons.looks_3_outlined));
      await tester.pumpAndSettle();

      expect(_location(env.router), '/c');
    });

    testWidgets('losing the permission of the selected tab moves away', (
      tester,
    ) async {
      final env = await _pump(tester, const Size(1400, 900));
      env.router.go('/b');
      await tester.pumpAndSettle();
      expect(_location(env.router), '/b');

      env.repository.result = Right(_snapshot(const <Permission>{}));
      await env.access.load();
      await tester.pumpAndSettle();

      expect(_location(env.router), '/a');
      expect(find.byIcon(Icons.looks_two_outlined), findsNothing);
    });
  });

  group('destinations must match the branches', () {
    testWidgets('the assert fails when the counts differ', (tester) async {
      await _pump(
        tester,
        const Size(390, 844),
        destinations: [_dest(Icons.looks_one_outlined, 0)],
      );

      expect(tester.takeException(), isA<AssertionError>());
    });
  });
}
