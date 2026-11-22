import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import '../../../../../helpers/memory_storage.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brand_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/pages/brands_screen.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brands_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';
import '../../../../../helpers/localized_app.dart';
import '../../support/fake_brands_repository.dart';

class _AccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'test-user',
      username: 'test',
      email: null,
      isSuperAdmin: false,
      roles: [],
      permissions: {Permissions.masterData.manage},
      branches: [],
      warehouses: [],
      posTerminals: [],
    ),
  );
}

Future<void> _pumpScreen(
  WidgetTester tester,
  FakeBrandsRepository repository, {
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  sl.registerFactory<FlashMessages>(FlashMessages.new);
  sl.registerSingleton<AppSettingsManager>(
    AppSettingsManager(storage: MemoryStorage()),
  );
  sl.registerFactory<BrandStatsCubit>(
    () => BrandStatsCubit(getBrandStats: GetBrandStatsUseCase(repository)),
  );
  sl.registerFactory<BrandsListCubit>(
    () => BrandsListCubit(
      getBrands: GetBrandsUseCase(repository),
      setBrandActive: SetBrandActiveUseCase(repository),
      deleteBrand: DeleteBrandUseCase(repository),
      flashMessages: sl(),
    ),
  );
  addTearDown(() async => sl.reset());

  await tester.pumpWidget(
    buildTestApp(
      home: BlocProvider<AccessCubit>(
        create: (_) =>
            AccessCubit(getMyAccess: GetMyAccessUseCase(_AccessRepository()))
              ..load(),
        child: const Scaffold(body: BrandsScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<Brand> _brands() => const [
  Brand(
    id: 1,
    name: 'Can delete',
    slug: 'can-delete',
    isActive: true,
    productCount: 0,
  ),
  Brand(
    id: 2,
    name: 'In use',
    slug: 'in-use',
    isActive: false,
    productCount: 3,
  ),
  Brand(
    id: 3,
    name: 'Unknown usage',
    slug: 'unknown-usage',
    isActive: true,
    productCount: null,
  ),
];

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  for (final size in [const Size(1280, 900), const Size(360, 800)]) {
    testWidgets('row actions respect canDelete at $size', (tester) async {
      final repository = FakeBrandsRepository()
        ..onGetBrands = (_) async => Right(
          PaginatedResult<Brand>(
            items: _brands(),
            totalCount: 3,
            currentPage: 1,
            totalPages: 1,
          ),
        );
      await _pumpScreen(tester, repository, size: size);

      expect(find.byType(AppRowActions), findsNWidgets(3));
      // Every row keeps its menu; delete is disabled while products exist.
      expect(find.byType(AppMenu), findsNWidgets(3));
      await tester.tap(find.byType(AppMenu).first);
      await tester.pumpAndSettle();
      expect(find.text(BrandsKeys.delete.en), findsOneWidget);
    });
  }

  testWidgets('deactivation confirms while activation is direct', (
    tester,
  ) async {
    final repository = FakeBrandsRepository()
      ..onGetBrands = (_) async => Right(
        PaginatedResult<Brand>(
          items: _brands(),
          totalCount: 3,
          currentPage: 1,
          totalPages: 1,
        ),
      );
    await _pumpScreen(tester, repository, size: const Size(1280, 900));

    // Status is a switch in its column: row 1 is active, row 2 is not.
    await tester.tap(find.byType(Switch).at(0));
    await tester.pumpAndSettle();
    expect(find.text(BrandsKeys.deactivateMessage.en), findsOneWidget);
    expect(repository.statusUpdates, isEmpty);
    await tester.tap(find.text(CommonKeys.confirm.en));
    await tester.pumpAndSettle();
    expect(repository.statusUpdates, contains((1, false)));

    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    expect(repository.statusUpdates, contains((2, true)));
  });

  testWidgets('in-use delete failure remains visible in ConfirmDialog', (
    tester,
  ) async {
    final repository = FakeBrandsRepository()
      ..deleteResult = const Left(BrandInUseFailure())
      ..onGetBrands = (_) async => Right(
        PaginatedResult<Brand>(
          items: _brands(),
          totalCount: 3,
          currentPage: 1,
          totalPages: 1,
        ),
      );
    await _pumpScreen(tester, repository, size: const Size(1280, 900));

    await tester.tap(find.byType(AppMenu).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(BrandsKeys.delete.en));
    await tester.pumpAndSettle();
    await tester.tap(find.text(CommonKeys.confirm.en));
    await tester.pumpAndSettle();

    expect(find.text(BrandFailureKeys.brandInUse.en), findsOneWidget);
    expect(find.text('Can delete'), findsWidgets);
  });

  testWidgets('stats failure does not prevent the brands list from loading', (
    tester,
  ) async {
    final repository = FakeBrandsRepository();
    repository.onGetBrands = (_) async => Right(
      PaginatedResult<Brand>(
        items: _brands(),
        totalCount: 3,
        currentPage: 1,
        totalPages: 1,
      ),
    );
    repository.onGetBrandStats = () async => const Left(BrandInUseFailure());
    await _pumpScreen(tester, repository, size: const Size(1280, 900));

    expect(find.text('Can delete'), findsOneWidget);
    expect(find.text('In use'), findsOneWidget);
    expect(find.byType(BrandsScreen), findsOneWidget);
  });

  testWidgets('all successful list mutations refresh statistics', (
    tester,
  ) async {
    var statsRequests = 0;
    final repository = FakeBrandsRepository();
    repository.onGetBrands = (_) async => Right(
      PaginatedResult<Brand>(
        items: _brands(),
        totalCount: 3,
        currentPage: 1,
        totalPages: 1,
      ),
    );
    repository.onGetBrandStats = () async {
      statsRequests++;
      return const Right(BrandStats(total: 3, active: 2, inactive: 1));
    };
    await _pumpScreen(tester, repository, size: const Size(1280, 900));

    expect(statsRequests, 1);
    final cubit = BlocProvider.of<BrandsListCubit>(
      tester.element(find.byType(BrandsFilterBar)),
    );

    await cubit.onBrandSaved(isNew: true);
    await tester.pumpAndSettle();
    expect(statsRequests, 2);

    await cubit.onBrandSaved(isNew: false);
    await tester.pumpAndSettle();
    expect(statsRequests, 3);

    await cubit.activate(1);
    await tester.pumpAndSettle();
    expect(statsRequests, 4);

    await cubit.deactivate(2);
    await tester.pumpAndSettle();
    expect(statsRequests, 5);

    await cubit.delete(_brands().first);
    await tester.pumpAndSettle();
    expect(statsRequests, 6);
  });
}
