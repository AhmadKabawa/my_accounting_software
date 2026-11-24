import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brand_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/pages/brands_screen.dart';
import '../../../../../helpers/localized_app.dart';
import '../../../../../helpers/memory_storage.dart';
import '../../support/fake_brands_repository.dart';

// Coverage moved from the removed BrandsTableSection test: the Brands data
// section is now produced by the shared CRUD engine.
const _brand = Brand(
  id: 12,
  name: 'Northwind',
  slug: 'northwind',
  isActive: true,
  productCount: 2,
);

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

Future<void> _pumpScreen(WidgetTester tester, List<Brand> rows) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repository = FakeBrandsRepository()
    ..onGetBrands = (_) async => Right(
      PaginatedResult<Brand>(
        items: rows,
        totalCount: rows.length,
        currentPage: 1,
        totalPages: 1,
      ),
    );
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

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('the products column shows just the number', (tester) async {
    await _pumpScreen(tester, const [_brand]);

    expect(find.text(BrandsKeys.productCount.en), findsWidgets);
    expect(find.text('Products: 2'), findsNothing);
    expect(find.text('2'), findsWidgets);
  });

  testWidgets('empty brands uses its dedicated AppEmptyState', (tester) async {
    await _pumpScreen(tester, const []);

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text(BrandsKeys.empty.en), findsOneWidget);
  });

  testWidgets('filtered empty result uses its dedicated AppEmptyState', (
    tester,
  ) async {
    await _pumpScreen(tester, const []);
    await BlocProvider.of<BrandsListCubit>(
      tester.element(find.byType(ListPageTemplate)),
    ).setStatus(BrandStatusFilter.inactive);
    await tester.pumpAndSettle();

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text(BrandsKeys.noResults.en), findsOneWidget);
  });
}
