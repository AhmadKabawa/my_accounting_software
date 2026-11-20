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

Future<void> _pump(WidgetTester tester, AppSettingsManager settings) async {
  tester.view.physicalSize = const Size(1400, 900);
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
    initialLocation: '/first',
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
              GoRoute(path: '/first', builder: (_, _) => const Text('First')),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/second', builder: (_, _) => const Text('Second')),
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
}
