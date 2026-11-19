import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import '../helpers/localized_app.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/localization/keys/shell_keys.dart';
import 'package:accounting_software/app/core/localization/keys/scope_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_scope_selector/scope_selector.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_rail/app_navigation_rail.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/shell/app_shell.dart';
import 'package:accounting_software/app/shell/destinations.dart';

const _secret = Permission('sales.view');

AccessSnapshot _snapshot(
  Set<Permission> permissions, {
  List<AccessBranch> branches = const [],
}) => AccessSnapshot(
  userId: 'u1',
  username: 'shell-test',
  email: null,
  isSuperAdmin: false,
  roles: const [],
  permissions: permissions,
  branches: branches,
  warehouses: const [],
  posTerminals: const [],
);

class _FakeAccessRepository implements AccessRepository {
  _FakeAccessRepository(
    Set<Permission> permissions, {
    List<AccessBranch> branches = const [],
  }) : result = Right(_snapshot(permissions, branches: branches));

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

Future<
  ({GoRouter router, AccessCubit access, _FakeAccessRepository repository})
>
_pump(
  WidgetTester tester,
  Size size, {
  Set<Permission> permissions = const {Permission('sales.view')},
  List<AppDestination>? destinations,
  int? routeBranchCount,
  List<AccessBranch> branches = const [],
  List<AppMenuEntry> userMenuEntries = const [],
  Future<bool> Function(ScopeOption)? beforeBranchChange,
  ThemeData? theme,
  TextDirection direction = TextDirection.rtl,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _FakeAccessRepository(permissions, branches: branches);
  final access = AccessCubit(getMyAccess: GetMyAccessUseCase(repository));
  await access.load();
  addTearDown(access.close);

  final selectedDestinations = destinations ?? _destinations;
  final branchCount = routeBranchCount ?? selectedDestinations.length;
  final paths = List.generate(branchCount, (index) => '/branch-$index');
  final router = GoRouter(
    initialLocation: paths.first,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(
          navigationShell: shell,
          destinations: selectedDestinations,
          userMenuEntries: userMenuEntries,
          beforeBranchChange: beforeBranchChange,
        ),
        branches: [
          for (final path in paths)
            StatefulShellBranch(
              routes: [GoRoute(path: path, builder: (_, _) => Text(path))],
            ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    BlocProvider.value(
      value: access,
      child: buildTestApp(
        router: router,
        theme: theme ?? AppTheme.light(),
        direction: direction,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, access: access, repository: repository);
}

String _location(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

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
      expect(_location(env.router), '/branch-0');

      await tester.tap(find.byIcon(Icons.looks_3_outlined));
      await tester.pumpAndSettle();

      expect(_location(env.router), '/branch-2');
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

      expect(_location(env.router), '/branch-2');
    });

    testWidgets('losing the permission of the selected tab moves away', (
      tester,
    ) async {
      final env = await _pump(tester, const Size(1400, 900));
      env.router.go('/branch-1');
      await tester.pumpAndSettle();
      expect(_location(env.router), '/branch-1');

      env.repository.result = Right(_snapshot(const <Permission>{}));
      await env.access.load();
      await tester.pumpAndSettle();

      expect(_location(env.router), '/branch-0');
      expect(find.byIcon(Icons.looks_two_outlined), findsNothing);
    });
  });

  group('destinations must match the branches', () {
    testWidgets('the assert fails when the counts differ', (tester) async {
      await _pump(
        tester,
        const Size(390, 844),
        destinations: [_dest(Icons.looks_one_outlined, 0)],
        routeBranchCount: 3,
      );

      expect(tester.takeException(), isA<AssertionError>());
    });
  });
  group('responsive shell breakpoints', () {
    testWidgets('360 width uses the mobile bottom bar', (tester) async {
      await _pump(tester, const Size(360, 800));

      expect(find.byType(AppNavigationBar), findsOneWidget);
      expect(find.byType(AppNavigationRail), findsNothing);
      expect(find.byType(AppSidebar), findsNothing);
    });

    testWidgets('600 width uses the tablet rail', (tester) async {
      await _pump(tester, const Size(600, 900));

      expect(find.byType(AppNavigationRail), findsOneWidget);
      expect(find.byType(AppNavigationBar), findsNothing);
      expect(find.byType(AppSidebar), findsNothing);
    });

    testWidgets('900 width uses the tablet rail', (tester) async {
      await _pump(tester, const Size(900, 1200));

      expect(find.byType(AppNavigationRail), findsOneWidget);
      expect(find.byType(AppNavigationBar), findsNothing);
      expect(find.byType(AppSidebar), findsNothing);
    });

    testWidgets('1200 width uses the desktop sidebar', (tester) async {
      await _pump(tester, const Size(1200, 900));

      expect(find.byType(AppSidebar), findsOneWidget);
      expect(find.byType(AppNavigationBar), findsNothing);
      expect(find.byType(AppNavigationRail), findsNothing);
    });
  });

  group('direction and appearance', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
        testWidgets(
          '${theme.brightness.name} theme with ${direction.name} direction',
          (tester) async {
            await _pump(
              tester,
              const Size(390, 844),
              theme: theme,
              direction: direction,
            );

            expect(find.byType(AppNavigationBar), findsOneWidget);
          },
        );
      }
    }
  });
  group('shell access context and actions', () {
    final branches = [
      const AccessBranch(
        id: 1,
        code: 'BRANCH-NORTH',
        name: 'North Regional Distribution and Administration Branch',
        canView: true,
        canOperate: true,
      ),
      const AccessBranch(
        id: 2,
        code: 'BRANCH-SOUTH',
        name: 'South Regional Distribution and Customer Operations Branch',
        canView: true,
        canOperate: false,
      ),
    ];

    testWidgets('all required widths build with long branch names', (
      tester,
    ) async {
      for (final size in [
        const Size(360, 800),
        const Size(600, 900),
        const Size(900, 1200),
        const Size(1200, 900),
      ]) {
        await _pump(tester, size, branches: branches);
        expect(tester.takeException(), isNull, reason: 'width $size');
      }
    });

    testWidgets('does not show ScopeSelector without accessible branches', (
      tester,
    ) async {
      await _pump(tester, const Size(1200, 900));
      expect(find.byType(ScopeSelector), findsNothing);
    });

    testWidgets('shows view-only badge for a non-operable branch', (
      tester,
    ) async {
      await _pump(tester, const Size(1200, 900), branches: [branches.last]);
      expect(find.text(ScopeKeys.viewOnly.en), findsOneWidget);
    });

    testWidgets('beforeBranchChange is called before selecting a branch', (
      tester,
    ) async {
      ScopeOption? requested;
      final env = await _pump(
        tester,
        const Size(1200, 900),
        branches: branches,
        beforeBranchChange: (next) async {
          requested = next;
          return false;
        },
      );
      await tester.tap(find.byTooltip('Branch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(branches.last.name));
      await tester.pumpAndSettle();
      expect(requested?.id, '2');
      expect(_location(env.router), '/branch-0');
    });

    testWidgets('notification icon remains disabled', (tester) async {
      await _pump(tester, const Size(1200, 900));
      final notification = tester.widget<AppIconButton>(
        find.byType(AppIconButton),
      );
      expect(notification.onPressed, isNull);
    });

    testWidgets('user menu entries invoke their action', (tester) async {
      var selected = false;
      await _pump(
        tester,
        const Size(1200, 900),
        userMenuEntries: [
          AppMenuEntry(
            label: TemplateKeys.save,
            onSelected: () => selected = true,
          ),
        ],
      );
      await tester.tap(find.byTooltip('User menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(TemplateKeys.save.en));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
    });

    testWidgets('six mobile destinations become four plus More', (
      tester,
    ) async {
      final destinations = [
        _dest(Icons.looks_one_outlined, 0),
        _dest(Icons.looks_two_outlined, 1),
        _dest(Icons.looks_3_outlined, 2),
        _dest(Icons.looks_4_outlined, 3),
        _dest(Icons.looks_5_outlined, 4),
        _dest(Icons.looks_6_outlined, 5),
      ];
      final env = await _pump(
        tester,
        const Size(360, 800),
        destinations: destinations,
      );
      final nav = tester.widget<AppNavigationBar>(
        find.byType(AppNavigationBar),
      );
      expect(nav.items, hasLength(5));
      expect(nav.items.last.label, ShellKeys.more);
      expect(tester.takeException(), isNull);
      nav.onIndexChanged(4);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.looks_6_outlined));
      await tester.pumpAndSettle();
      expect(_location(env.router), '/branch-5');
      expect(
        tester
            .widget<AppNavigationBar>(find.byType(AppNavigationBar))
            .activeIndex,
        4,
      );
    });
  });
}
