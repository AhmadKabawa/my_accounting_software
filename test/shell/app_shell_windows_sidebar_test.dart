import 'package:dartz/dartz.dart' hide State;
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
import 'package:accounting_software/app/core/localization/keys/shell_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_data.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/storage/storage_key.dart';
import 'package:accounting_software/app/core/storage/storage_service.dart';
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
      branches: const [
        AccessBranch(
          id: 1,
          code: 'MAIN',
          name: 'Main',
          canView: true,
          canOperate: true,
        ),
      ],
      warehouses: const [],
      posTerminals: const [],
    ),
  );
}

class _MemoryStorage implements StorageService {
  final Map<StorageKey, Object> values = {};

  @override
  Future<void> write<T>(StorageKey key, T value) async {
    values[key] = value as Object;
  }

  @override
  Future<T?> read<T>(StorageKey key) async => values[key] as T?;

  @override
  Future<void> delete(StorageKey key) async {
    values.remove(key);
  }

  @override
  Future<void> clearAll() async => values.clear();

  @override
  Future<bool> containsKey(StorageKey key) async => values.containsKey(key);
}

Future<void> _pump(
  WidgetTester tester,
  AppSettingsManager settings, {
  Size size = const Size(1400, 900),
  String initialLocation = '/first',
  bool secondHasChild = false,
}) async {
  tester.view.physicalSize = size;
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
      item: NavBarItem(
        icon: Icons.looks_two_outlined,
        label: NavKeys.home,
        children: secondHasChild
            ? [
                NavBarChild(
                  label: ShellKeys.more,
                  icon: MaterialIconData(Icons.circle_outlined),
                  path: '/second/child',
                ),
              ]
            : const [],
      ),
      branchIndex: 1,
    ),
  ];
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(
          navigationShell: shell,
          destinations: destinations,
          supportsCollapsibleSidebar: true,
          settingsManager: settings,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/first',
                builder: (_, _) => const Text('First'),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (_, _) => const Text('Detail'),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/second',
                builder: (_, _) => const Text('Second'),
                routes: [
                  GoRoute(
                    path: 'child',
                    builder: (_, _) => const Text('Child'),
                  ),
                ],
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
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('Windows sidebar collapses and restores its saved preference', (
    tester,
  ) async {
    final settings = AppSettingsManager(storage: _MemoryStorage());
    await _pump(tester, settings);

    expect(
      tester.widget<AppSidebar>(find.byType(AppSidebar)).collapsed,
      isFalse,
    );
    await tester.tap(find.byTooltip(ShellKeys.collapseSidebar.en));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppSidebar>(find.byType(AppSidebar)).collapsed,
      isTrue,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await _pump(tester, settings);
    expect(
      tester.widget<AppSidebar>(find.byType(AppSidebar)).collapsed,
      isTrue,
    );
    expect(find.byTooltip(ShellKeys.expandSidebar.en), findsOneWidget);
  });

  testWidgets('open sections are saved and restored', (tester) async {
    final settings = AppSettingsManager(storage: _MemoryStorage());
    await settings.setSidebarOpenSections({'nav.home'});
    expect(await settings.getSidebarOpenSections(), {'nav.home'});
    await _pump(tester, settings);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet sidebar starts icon-only and opens on demand', (
    tester,
  ) async {
    final settings = AppSettingsManager(storage: _MemoryStorage());
    await _pump(tester, settings, size: const Size(800, 900));
    expect(
      tester.widget<AppSidebar>(find.byType(AppSidebar)).collapsed,
      isTrue,
    );
    await tester.tap(find.byTooltip(ShellKeys.expandSidebar.en));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppSidebar>(find.byType(AppSidebar)).collapsed,
      isFalse,
    );
  });

  group('tapping the page already shown', () {
    bool collapsed(WidgetTester tester) =>
        tester.widget<AppSidebar>(find.byType(AppSidebar)).collapsed;

    Finder expandedItem(int index) => find
        .descendant(of: find.byType(AppSidebar), matching: find.text('home'))
        .at(index);

    Finder iconItem(int index) => find.byTooltip('home').at(index);

    testWidgets('folds an open sidebar and opens it again from the icon', (
      tester,
    ) async {
      final settings = AppSettingsManager(storage: _MemoryStorage());
      await _pump(tester, settings);
      expect(collapsed(tester), isFalse);

      await tester.tap(expandedItem(0));
      await tester.pumpAndSettle();
      expect(collapsed(tester), isTrue);
      expect(find.text('First'), findsOneWidget);

      await tester.tap(iconItem(0));
      await tester.pumpAndSettle();
      expect(collapsed(tester), isFalse);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsNothing);
    });

    testWidgets('the choice is saved like the toggle button', (tester) async {
      final settings = AppSettingsManager(storage: _MemoryStorage());
      await _pump(tester, settings);
      await tester.tap(expandedItem(0));
      await tester.pumpAndSettle();
      expect(await settings.getSidebarCollapsedOrNull(), isTrue);
    });

    testWidgets('another page navigates and keeps the sidebar as it is', (
      tester,
    ) async {
      final settings = AppSettingsManager(storage: _MemoryStorage());
      await _pump(tester, settings);
      await tester.tap(expandedItem(0));
      await tester.pumpAndSettle();
      expect(collapsed(tester), isTrue);

      await tester.tap(iconItem(1));
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsOneWidget);
      expect(collapsed(tester), isTrue);

      await tester.tap(find.byTooltip(ShellKeys.expandSidebar.en));
      await tester.pumpAndSettle();
      await tester.tap(expandedItem(0));
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(collapsed(tester), isFalse);
    });

    testWidgets('on a detail page it returns to the root instead', (
      tester,
    ) async {
      final settings = AppSettingsManager(storage: _MemoryStorage());
      await _pump(tester, settings, initialLocation: '/first/detail');
      expect(find.text('Detail'), findsOneWidget);

      await tester.tap(expandedItem(0));
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(collapsed(tester), isFalse);

      // Now at the root: the same tap folds it.
      await tester.tap(expandedItem(0));
      await tester.pumpAndSettle();
      expect(collapsed(tester), isTrue);
    });

    testWidgets('the tablet rail opens from the icon of the current page', (
      tester,
    ) async {
      final settings = AppSettingsManager(storage: _MemoryStorage());
      await _pump(tester, settings, size: const Size(800, 900));
      expect(collapsed(tester), isTrue);

      await tester.tap(iconItem(0));
      await tester.pumpAndSettle();
      expect(collapsed(tester), isFalse);

      await tester.tap(expandedItem(1));
      await tester.pumpAndSettle();
      expect(collapsed(tester), isFalse);
      expect(find.text('Second'), findsOneWidget);

      await tester.tap(expandedItem(1));
      await tester.pumpAndSettle();
      expect(collapsed(tester), isTrue);
    });
  });

  group('a section with sub-items', () {
    bool collapsed(WidgetTester tester) =>
        tester.widget<AppSidebar>(find.byType(AppSidebar)).collapsed;

    testWidgets('tapping the active sub-item folds and reopens the sidebar', (
      tester,
    ) async {
      final settings = AppSettingsManager(storage: _MemoryStorage());
      await _pump(
        tester,
        settings,
        initialLocation: '/second/child',
        secondHasChild: true,
      );
      expect(collapsed(tester), isFalse);

      await tester.tap(
        find.descendant(
          of: find.byType(AppSidebar),
          matching: find.text(ShellKeys.more.en),
        ),
      );
      await tester.pumpAndSettle();
      expect(collapsed(tester), isTrue);
      expect(find.text('Child'), findsOneWidget);

      await tester.tap(find.byTooltip(ShellKeys.more.en));
      await tester.pumpAndSettle();
      expect(collapsed(tester), isFalse);
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('the folded rail opens from the parent page icon', (
      tester,
    ) async {
      final settings = AppSettingsManager(storage: _MemoryStorage());
      await _pump(
        tester,
        settings,
        size: const Size(800, 900),
        initialLocation: '/second',
        secondHasChild: true,
      );
      expect(collapsed(tester), isTrue);

      await tester.tap(find.byTooltip('home').at(1));
      // A parent also listens for a double tap, so the single tap is
      // delivered after the double-tap window.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(collapsed(tester), isFalse);
      expect(find.text('Second'), findsOneWidget);
    });
  });
}
