import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/routing/route_item.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/features/home/presentation/model/dashboard_card_definition.dart';
import 'package:accounting_software/app/features/home/presentation/pages/home_screen.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/dashboard_card.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import '../../helpers/localized_app.dart';

class _AccessRepository implements AccessRepository {
  _AccessRepository(this.permissions);

  final Set<Permission> permissions;

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'u1',
      username: 'tester',
      email: null,
      isSuperAdmin: false,
      roles: const [],
      permissions: permissions,
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

const _target = RouteItem('/dashboard-test-target', 'dashboardTestTarget');

DashboardCardDefinition _definition() => const DashboardCardDefinition(
  id: 'reports',
  titleKey: HomeKeys.dashboardTitle,
  descriptionKey: HomeKeys.noAvailableCardsDescription,
  icon: AppIcons.home,
  permission: Permission('reports.view'),
  destination: _target,
);

Future<AccessCubit> _createAccessCubit(Set<Permission> permissions) async {
  final cubit = AccessCubit(
    getMyAccess: GetMyAccessUseCase(_AccessRepository(permissions)),
  );
  await cubit.load();
  return cubit;
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('shows a destination only when its permission is granted', (
    tester,
  ) async {
    final cubit = await _createAccessCubit({
      const Permission('reports.view'),
    });
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: buildTestApp(
          home: HomeScreen(
            registeredRoutes: [HomeRoutes.home, _target],
            definitions: [_definition()],
          ),
        ),
      ),
    );

    expect(find.byType(DashboardCard), findsOneWidget);
    final cardContext = tester.element(find.byType(DashboardCard));
    expect(
      tester.getSize(find.byType(DashboardCard)).height,
      greaterThanOrEqualTo(AppComponentSize.hitArea.of(cardContext)),
    );
    expect(find.byType(AppEmptyState), findsNothing);
  });

  testWidgets('shows the empty state when the user has no permission', (
    tester,
  ) async {
    final cubit = await _createAccessCubit({});
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: buildTestApp(
          home: HomeScreen(
            registeredRoutes: [HomeRoutes.home, _target],
            definitions: [_definition()],
          ),
        ),
      ),
    );

    expect(find.byType(DashboardCard), findsNothing);
    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text(HomeKeys.noAvailableCardsTitle.en), findsOneWidget);
  });

  testWidgets('hides a destination whose route is not registered', (
    tester,
  ) async {
    final cubit = await _createAccessCubit({
      const Permission('reports.view'),
    });
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: buildTestApp(
          home: HomeScreen(
            registeredRoutes: [HomeRoutes.home],
            definitions: [_definition()],
          ),
        ),
      ),
    );

    expect(find.byType(DashboardCard), findsNothing);
    expect(find.byType(AppEmptyState), findsOneWidget);
  });

  testWidgets('opens the registered destination when a card is tapped', (
    tester,
  ) async {
    final cubit = await _createAccessCubit({
      const Permission('reports.view'),
    });
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: HomeRoutes.home.path,
      routes: [
        GoRoute(
          path: HomeRoutes.home.path,
          name: HomeRoutes.home.name,
          builder: (context, state) => HomeScreen(
            registeredRoutes: [HomeRoutes.home, _target],
            definitions: [_definition()],
          ),
        ),
        GoRoute(
          path: _target.path,
          name: _target.name,
          builder: (_, _) => const Text('target reached'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: buildTestApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DashboardCard));
    await tester.pumpAndSettle();

    expect(find.text('target reached'), findsOneWidget);
  });

  testWidgets('dashboard cards expose button semantics and keyboard activation', (
    tester,
  ) async {
    final cubit = await _createAccessCubit({
      const Permission('reports.view'),
    });
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: HomeRoutes.home.path,
      routes: [
        GoRoute(
          path: HomeRoutes.home.path,
          name: HomeRoutes.home.name,
          builder: (_, _) => HomeScreen(
            registeredRoutes: [HomeRoutes.home, _target],
            definitions: [_definition()],
          ),
        ),
        GoRoute(
          path: _target.path,
          name: _target.name,
          builder: (_, _) => const Text('keyboard target'),
        ),
      ],
    );
    addTearDown(router.dispose);
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: buildTestApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    final node = tester.getSemantics(find.byType(DashboardCard));
    expect(node.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(node.hasAction(SemanticsAction.tap), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('keyboard target'), findsOneWidget);

    router.go(HomeRoutes.home.path);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.text('keyboard target'), findsOneWidget);
  });

  testWidgets('empty dashboard adapts to widths, directions and themes', (
    tester,
  ) async {
    final cubit = await _createAccessCubit({});
    addTearDown(cubit.close);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final size in [
      const Size(360, 800),
      const Size(600, 900),
      const Size(900, 900),
      const Size(1200, 900),
    ]) {
      tester.view.physicalSize = size;
      for (final direction in [TextDirection.rtl, TextDirection.ltr]) {
        for (final theme in [AppTheme.light(), AppTheme.dark()]) {
          await tester.pumpWidget(
            BlocProvider.value(
              value: cubit,
              child: buildTestApp(
                theme: theme,
                direction: direction,
                home: const HomeScreen(registeredRoutes: [HomeRoutes.home]),
              ),
            ),
          );
          expect(find.byType(AppEmptyState), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    }
  });
}
