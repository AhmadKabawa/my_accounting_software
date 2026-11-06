import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/role.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_rail/app_navigation_rail.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/shell/app_shell.dart';
import 'package:accounting_software/app/shell/destinations.dart';

const _secret = Permission('shell_test.view');

AppDestination _dest(IconData icon, int branch, {Permission? permission}) =>
    AppDestination(
      item: NavBarItem(icon: icon, label: NavKeys.home),
      branchIndex: branch,
      permission: permission,
    );

// Three destinations: a (everyone), b (needs [_secret]), c (everyone).
final _destinations = [
  _dest(Icons.looks_one_outlined, 0),
  _dest(Icons.looks_two_outlined, 1, permission: _secret),
  _dest(Icons.looks_3_outlined, 2),
];

const _owner = Role(id: 'o', name: 'o', permissions: {Permission.all});

/// A mini shell route with three branches: /a, /b, /c.
GoRouter _router() => GoRouter(
  initialLocation: '/a',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          AppShell(navigationShell: shell, destinations: _destinations),
      branches: [
        for (final path in ['/a', '/b', '/c'])
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: path,
                builder: (_, _) => Text(path, textDirection: TextDirection.ltr),
              ),
            ],
          ),
      ],
    ),
  ],
);

Future<({GoRouter router, AccessCubit access})> _pump(
  WidgetTester tester,
  Size size, {
  Role role = _owner,
  List<AppDestination>? destinations,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final access = AccessCubit()..setRole(role);
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

  await tester.pumpWidget(
    BlocProvider.value(
      value: access,
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, access: access);
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
      await _pump(tester, const Size(1400, 900), role: Role.none);

      expect(find.byIcon(Icons.looks_one_outlined), findsOneWidget);
      expect(find.byIcon(Icons.looks_two_outlined), findsNothing);
      expect(find.byIcon(Icons.looks_3_outlined), findsOneWidget);
    });

    testWidgets('filtering does not shift the branch of later tabs', (
      tester,
    ) async {
      // c is the 2nd visible item but branch 2.
      final env = await _pump(tester, const Size(1400, 900), role: Role.none);

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

      env.access.setRole(Role.none);
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
