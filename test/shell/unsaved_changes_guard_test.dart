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
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/keys/shell_keys.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_scope_selector/scope_selector.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_rail/app_navigation_rail.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/routing/unsaved_changes_guard.dart';
import 'package:accounting_software/app/shell/app_shell.dart';
import 'package:accounting_software/app/shell/destinations.dart';
import '../helpers/localized_app.dart';

class _Repository implements AccessRepository {
  _Repository({
    this.withBranches = false,
    this.failOnSecondCall = false,
  });

  final bool withBranches;
  final bool failOnSecondCall;
  int _calls = 0;

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async {
    _calls++;
    if (failOnSecondCall && _calls > 1) return Left(NetworkFailure());
    return Right(
      AccessSnapshot(
      userId: 'guard-test',
      username: 'guard-test',
      email: null,
      isSuperAdmin: false,
      roles: const [],
      permissions: const {Permission('sales.view')},
      branches: withBranches
          ? const [
              AccessBranch(
                id: 1,
                code: 'ONE',
                name: 'First branch',
                canView: true,
                canOperate: true,
              ),
              AccessBranch(
                id: 2,
                code: 'TWO',
                name: 'Second branch',
                canView: true,
                canOperate: true,
              ),
            ]
          : const [
              AccessBranch(
                id: 1,
                code: 'ONE',
                name: 'First branch',
                canView: true,
                canOperate: true,
              ),
            ],
      warehouses: const [],
      posTerminals: const [],
      ),
    );
  }
}

const _icons = [
  Icons.looks_one_outlined,
  Icons.looks_two_outlined,
  Icons.looks_3_outlined,
  Icons.looks_4_outlined,
  Icons.looks_5_outlined,
  Icons.looks_6_outlined,
];

final _destinations = [
  for (var index = 0; index < _icons.length; index++)
    AppDestination(
      item: NavBarItem(
        icon: _icons[index],
        label: index == 5 ? ShellKeys.branch : NavKeys.home,
      ),
      branchIndex: index,
    ),
];

Future<({GoRouter router, AccessCubit access, UnsavedChangesGuard guard})>
_pump(
  WidgetTester tester, {
  required Size size,
  required bool dirty,
  bool withBranches = false,
  bool failOnSecondAccess = false,
  List<AppMenuEntry> userMenuEntries = const [],
  Future<bool> Function(ScopeOption)? beforeBranchChange,
  Future<bool> Function(int)? beforeDestinationChange,
  void Function()? onDiscard,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final access = AccessCubit(
    getMyAccess: GetMyAccessUseCase(
      _Repository(
        withBranches: withBranches,
        failOnSecondCall: failOnSecondAccess,
      ),
    ),
  );
  await access.load();
  addTearDown(access.close);

  final guard = UnsavedChangesGuard();
  addTearDown(guard.dispose);
  final router = GoRouter(
    initialLocation: '/branch-0',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(
          navigationShell: shell,
          destinations: _destinations,
          userMenuEntries: userMenuEntries,
          beforeBranchChange: beforeBranchChange,
          beforeDestinationChange: beforeDestinationChange,
          unsavedChangesGuard: guard,
        ),
        branches: [
          for (var index = 0; index < _destinations.length; index++)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/branch-$index',
                  builder: (_, _) => index == 0
                      ? FormPageTemplate(
                          titleKey: NavKeys.home,
                          dirty: dirty,
                          onDiscard: onDiscard,
                          child: const Text('Dirty form'),
                        )
                      : Text('Branch $index'),
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
  return (router: router, access: access, guard: guard);
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.text(CommonKeys.confirm.en));
  await tester.pumpAndSettle();
}

Future<void> _cancel(WidgetTester tester) async {
  await tester.tap(find.text(CommonKeys.cancel.en));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('switching to an inactive bottom tab keeps the dirty form', (
    tester,
  ) async {
    var discarded = 0;
    final env = await _pump(
      tester,
      size: const Size(390, 844),
      dirty: true,
      onDiscard: () => discarded++,
    );

    await tester.tap(find.byIcon(_icons[1]));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-1',
    );
    expect(discarded, 0);
    await tester.tap(find.byIcon(_icons[0]));
    await tester.pumpAndSettle();
    expect(find.text('Dirty form'), findsOneWidget);
    expect(discarded, 0);
  });

  testWidgets('rejecting confirmation keeps the current branch', (
    tester,
  ) async {
    final env = await _pump(tester, size: const Size(390, 844), dirty: true);

    await tester.tap(find.byIcon(_icons[0]));
    await tester.pumpAndSettle();
    await _cancel(tester);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-0',
    );
    expect(find.text('Dirty form'), findsOneWidget);
  });

  testWidgets('a clean form changes branch without showing a dialog', (
    tester,
  ) async {
    final env = await _pump(tester, size: const Size(390, 844), dirty: false);

    await tester.tap(find.byIcon(_icons[1]));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-1',
    );
  });

  testWidgets('rapid repeated navigation opens only one confirmation', (
    tester,
  ) async {
    final env = await _pump(tester, size: const Size(390, 844), dirty: true);
    final navigation = tester.widget<AppNavigationBar>(
      find.byType(AppNavigationBar),
    );

    navigation.onIndexChanged(0);
    navigation.onIndexChanged(0);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await _cancel(tester);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-0',
    );
  });

  testWidgets('switching to an inactive rail destination keeps the form', (
    tester,
  ) async {
    var discarded = 0;
    final env = await _pump(
      tester,
      size: const Size(900, 1000),
      dirty: true,
      onDiscard: () => discarded++,
    );
    expect(find.byType(AppNavigationRail), findsOneWidget);
    await tester.tap(find.byIcon(_icons[1]));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-1',
    );
    expect(discarded, 0);
    await tester.tap(find.byIcon(_icons[0]));
    await tester.pumpAndSettle();
    expect(find.text('Dirty form'), findsOneWidget);
    expect(discarded, 0);
  });

  testWidgets('switching to an inactive sidebar destination keeps the form', (
    tester,
  ) async {
    var discarded = 0;
    final env = await _pump(
      tester,
      size: const Size(1400, 900),
      dirty: true,
      onDiscard: () => discarded++,
    );
    expect(find.byType(AppSidebar), findsOneWidget);
    await tester.tap(find.byIcon(_icons[1]));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-1',
    );
    expect(discarded, 0);
    await tester.tap(find.byIcon(_icons[0]));
    await tester.pumpAndSettle();
    expect(find.text('Dirty form'), findsOneWidget);
    expect(discarded, 0);
  });

  testWidgets('rapid More taps open only one sheet', (tester) async {
    await _pump(tester, size: const Size(390, 844), dirty: true);
    final navigation = tester.widget<AppNavigationBar>(
      find.byType(AppNavigationBar),
    );
    navigation.onIndexChanged(4);
    navigation.onIndexChanged(4);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('More sheet inactive destination does not ask the guard', (
    tester,
  ) async {
    var discarded = 0;
    final env = await _pump(
      tester,
      size: const Size(390, 844),
      dirty: true,
      onDiscard: () => discarded++,
    );
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ShellKeys.branch.en));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-5',
    );
    expect(discarded, 0);
  });

  testWidgets('guarded user-menu action runs only after confirmation', (
    tester,
  ) async {
    var selected = false;
    await _pump(
      tester,
      size: const Size(390, 844),
      dirty: true,
      userMenuEntries: [
        AppMenuEntry(
          label: TemplateKeys.save,
          onSelected: () => selected = true,
          requiresUnsavedChangesCheck: true,
        ),
      ],
    );
    await tester.tap(find.byTooltip(ShellKeys.userMenu.en));
    await tester.pumpAndSettle();
    await tester.tap(find.text(TemplateKeys.save.en));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(selected, isFalse);
    await _confirm(tester);
    expect(selected, isTrue);
  });

  testWidgets('scope change runs owner callback before unsaved guard', (
    tester,
  ) async {
    var ownerCallbackCalled = false;
    var discarded = 0;
    final env = await _pump(
      tester,
      size: const Size(1400, 900),
      dirty: true,
      withBranches: true,
      onDiscard: () => discarded++,
      beforeBranchChange: (_) async {
        ownerCallbackCalled = true;
        return true;
      },
    );
    await tester.tap(find.byTooltip('Branch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Second branch'));
    await tester.pumpAndSettle();
    expect(ownerCallbackCalled, isTrue);
    expect(find.byType(Dialog), findsOneWidget);
    await _cancel(tester);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-0',
    );
    expect(discarded, 0);
    expect(find.text('Dirty form'), findsOneWidget);
  });

  testWidgets('owner and guard approval changes scope and discards once', (
    tester,
  ) async {
    var discarded = 0;
    final env = await _pump(
      tester,
      size: const Size(1400, 900),
      dirty: true,
      withBranches: true,
      onDiscard: () => discarded++,
      beforeBranchChange: (_) async => true,
    );
    await tester.tap(find.byTooltip('Branch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Second branch'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await _confirm(tester);
    await tester.pumpAndSettle();
    expect(env.access.state.selectedBranchId, 2);
    expect(discarded, 1);
  });

  testWidgets('failed branch refresh does not discard dirty forms', (
    tester,
  ) async {
    var discarded = 0;
    final env = await _pump(
      tester,
      size: const Size(1400, 900),
      dirty: true,
      withBranches: true,
      failOnSecondAccess: true,
      onDiscard: () => discarded++,
      beforeBranchChange: (_) async => true,
    );

    await tester.tap(find.byTooltip('Branch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Second branch'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await _confirm(tester);

    expect(env.access.state.status, AccessStatus.failure);
    expect(discarded, 0);
  });

  testWidgets('owner rejection blocks scope change without guard dialog', (
    tester,
  ) async {
    var discarded = 0;
    await _pump(
      tester,
      size: const Size(1400, 900),
      dirty: true,
      withBranches: true,
      onDiscard: () => discarded++,
      beforeBranchChange: (_) async => false,
    );
    await tester.tap(find.byTooltip('Branch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Second branch'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(discarded, 0);
    expect(find.text('Dirty form'), findsOneWidget);
  });

  testWidgets('clicking the active bottom destination asks the guard', (
    tester,
  ) async {
    final env = await _pump(tester, size: const Size(390, 844), dirty: true);
    await tester.tap(find.byIcon(_icons[0]));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await _cancel(tester);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-0',
    );
  });

  testWidgets('clicking the active rail destination asks the guard', (
    tester,
  ) async {
    final env = await _pump(tester, size: const Size(900, 1000), dirty: true);
    await tester.tap(find.byIcon(_icons[0]));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await _cancel(tester);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-0',
    );
  });

  testWidgets('clicking the active sidebar destination asks the guard', (
    tester,
  ) async {
    final env = await _pump(tester, size: const Size(1400, 900), dirty: true);
    await tester.tap(find.byIcon(_icons[0]));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await _cancel(tester);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-0',
    );
  });

  testWidgets('owner rejection blocks navigation without asking the guard', (
    tester,
  ) async {
    final env = await _pump(
      tester,
      size: const Size(390, 844),
      dirty: true,
      beforeDestinationChange: (_) async => false,
    );
    await tester.tap(find.byIcon(_icons[1]));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(
      env.router.routerDelegate.currentConfiguration.uri.path,
      '/branch-0',
    );
    expect(find.text('Dirty form'), findsOneWidget);
  });
  test(
    'confirmAll checks dirty forms in every branch and discardAll clears them',
    () async {
      final guard = UnsavedChangesGuard();
      addTearDown(guard.dispose);
      final confirmed = <int>[];
      final discarded = <int>[];

      for (final branch in [0, 1]) {
        guard.updateForm(
          key: 'form-$branch',
          branchIndex: branch,
          dirty: true,
          confirm: () async {
            confirmed.add(branch);
            return true;
          },
          discard: () {
            discarded.add(branch);
            guard.unregister('form-$branch');
          },
        );
      }

      expect(await guard.confirmAll(), isTrue);
      expect(confirmed, [0, 1]);
      expect(discarded, isEmpty);

      guard.discardAll();
      expect(discarded, [0, 1]);
      expect(await guard.confirmAll(), isTrue);
      expect(confirmed, [0, 1]);
    },
  );

  test(
    'confirmAll stops on rejection and does not discard any form',
    () async {
      final guard = UnsavedChangesGuard();
      addTearDown(guard.dispose);
      final confirmed = <int>[];
      final discarded = <int>[];

      for (final branch in [0, 1]) {
        guard.updateForm(
          key: 'form-$branch',
          branchIndex: branch,
          dirty: true,
          confirm: () async {
            confirmed.add(branch);
            return branch == 0;
          },
          discard: () => discarded.add(branch),
        );
      }

      expect(await guard.confirmAll(), isFalse);
      expect(confirmed, [0]);
      expect(discarded, isEmpty);
    },
  );
}
