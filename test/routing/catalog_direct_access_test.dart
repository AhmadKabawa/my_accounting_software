import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/access/presentation/routing/access_routes.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_routes.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_go_routes.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_route_guard.dart';

class _FakeSessionGate implements SessionGate {
  @override
  SessionStatus get current => const SessionAuthenticated(
    UserEntity(id: 'test-user', email: 'test@example.com'),
  );

  @override
  Stream<SessionStatus> get changes => const Stream<SessionStatus>.empty();
}

class _FakeAccessRepository implements AccessRepository {
  _FakeAccessRepository(this.permissions);

  final Set<Permission> permissions;

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'test-user',
      username: 'test',
      email: null,
      isSuperAdmin: false,
      roles: const [],
      permissions: permissions,
      branches: const [],
      warehouses: const [],
      posTerminals: const [],
    ),
  );
}

void main() {
  Future<void> openCatalogDirectly(
    WidgetTester tester, {
    required Set<Permission> permissions,
    required String expectedPath,
  }) async {
    final accessCubit = AccessCubit(
      getMyAccess: GetMyAccessUseCase(_FakeAccessRepository(permissions)),
    );
    final router = GoRouter(
      initialLocation: BrandsRoutes.brands.path,
      routes: [
        ...buildCatalogRoutes(
          accessCubit: accessCubit,
          session: _FakeSessionGate(),
        ),
        GoRoute(
          path: AccessRoutes.denied.path,
          builder: (context, state) =>
              const Scaffold(body: Text('access denied test destination')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, expectedPath);

    router.dispose();
    await accessCubit.close();
  }

  test('masterdata.manage preserves access to reference-data routes', () async {
    final accessCubit = AccessCubit(
      getMyAccess: GetMyAccessUseCase(
        _FakeAccessRepository(const {Permission('masterdata.manage')}),
      ),
    );
    await accessCubit.load();

    expect(hasCatalogRouteAccess(accessCubit), isTrue);

    await accessCubit.close();
  });

  testWidgets(
    'direct catalog URL redirects to access denied without catalog.manage',
    (tester) async {
      await openCatalogDirectly(
        tester,
        permissions: const {},
        expectedPath: AccessRoutes.denied.path,
      );
    },
  );
}
