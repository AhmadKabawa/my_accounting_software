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
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brand_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/pages/brands_screen.dart';
import '../../../../../helpers/localized_app.dart';
import '../../../../../helpers/screen_matrix.dart';
import '../../support/fake_brands_repository.dart';

class _NoopAccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => const Right(
    AccessSnapshot(
      userId: 'test-user',
      username: 'test',
      email: null,
      isSuperAdmin: false,
      roles: [],
      permissions: {},
      branches: [],
      warehouses: [],
      posTerminals: [],
    ),
  );
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  for (final width in [360.0, 800.0, 1280.0]) {
    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      for (final dark in [false, true]) {
        testWidgets('brands page renders at $width, $direction, dark=$dark', (
          tester,
        ) async {
          final repository = FakeBrandsRepository();
          sl.registerFactory<FlashMessages>(FlashMessages.new);
  sl.registerSingleton<AppSettingsManager>(
    AppSettingsManager(storage: MemoryStorage()),
  );
          sl.registerFactory<BrandStatsCubit>(
            () => BrandStatsCubit(
              getBrandStats: GetBrandStatsUseCase(repository),
            ),
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

          await pumpScreenMatrix(
            tester,
            width: width,
            direction: direction,
            dark: dark,
            home: BlocProvider<AccessCubit>(
              create: (_) => AccessCubit(
                getMyAccess: GetMyAccessUseCase(_NoopAccessRepository()),
              )..load(),
              child: const Scaffold(body: BrandsScreen()),
            ),
          );

          expect(find.byType(BrandsScreen), findsOneWidget);
          // Breadcrumb + page title both show "Brands".
          expect(find.text('Brands'), findsWidgets);
          expect(find.textContaining('Total brands'), findsOneWidget);
          expect(find.textContaining('Active brands'), findsOneWidget);
          expect(find.textContaining('Inactive brands'), findsOneWidget);
          // No unresolved placeholders anywhere on the page.
          expect(find.textContaining('{'), findsNothing);
          expect(find.textContaining('@'), findsNothing);
          // Record actions are icons (AppRowActions), never text buttons.
          expect(find.text('Edit brand'), findsNothing);
          expect(find.text('Brand deleted'), findsNothing);
        });
      }
    }
  }

  testWidgets(
    'one mutation refreshes stats once after repeated list and stats rebuilds',
    (tester) async {
      final repository = FakeBrandsRepository();
      var statsCalls = 0;
      repository.onGetBrandStats = () async {
        statsCalls++;
        return Right(
          BrandStats(total: statsCalls, active: statsCalls, inactive: 0),
        );
      };
      final statsCubit = BrandStatsCubit(
        getBrandStats: GetBrandStatsUseCase(repository),
      );
      final listCubit = BrandsListCubit(
        getBrands: GetBrandsUseCase(repository),
        setBrandActive: SetBrandActiveUseCase(repository),
        deleteBrand: DeleteBrandUseCase(repository),
        flashMessages: FlashMessages(),
      );
      sl.registerSingleton<AppSettingsManager>(
        AppSettingsManager(storage: MemoryStorage()),
      );
      sl.registerFactory<BrandStatsCubit>(() => statsCubit);
      sl.registerFactory<BrandsListCubit>(() => listCubit);
      addTearDown(() async => sl.reset());

      await pumpScreenMatrix(
        tester,
        width: 1200,
        direction: TextDirection.ltr,
        dark: false,
        home: BlocProvider<AccessCubit>(
          create: (_) => AccessCubit(
            getMyAccess: GetMyAccessUseCase(_NoopAccessRepository()),
          )..load(),
          child: const Scaffold(body: BrandsScreen()),
        ),
      );
      expect(statsCalls, 1);

      await listCubit.refresh();
      await statsCubit.refresh();
      await listCubit.refresh();
      await statsCubit.refresh();
      await tester.pumpAndSettle();
      expect(statsCalls, 3);

      await listCubit.activate(12);
      await tester.pumpAndSettle();

      expect(statsCalls, 4);
      expect(tester.takeException(), isNull);
    },
  );
}
