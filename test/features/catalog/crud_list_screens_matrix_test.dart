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
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brand_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/pages/brands_screen.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/delete_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/get_color_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/get_colors_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/set_color_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/pages/colors_screen.dart';
import 'package:accounting_software/app/features/catalog/brands/support/fake_brands_repository.dart';
import 'package:accounting_software/app/features/catalog/colors/support/fake_colors_repository.dart';
import '../../helpers/localized_app.dart';
import '../../helpers/memory_storage.dart';
import '../../helpers/screen_matrix.dart';

class _AccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'crud-matrix',
      username: 'crud-matrix',
      email: null,
      isSuperAdmin: false,
      roles: const [],
      permissions: {Permissions.masterData.manage},
      branches: const [],
      warehouses: const [],
      posTerminals: const [],
    ),
  );
}

Future<void> _chooseMode(WidgetTester tester, AppViewMode mode) async {
  await tester.tap(find.byTooltip(CatalogUiKeys.viewMode.en));
  await tester.pumpAndSettle();
  final key = switch (mode) {
    AppViewMode.table => CatalogUiKeys.viewTable,
    AppViewMode.cards => CatalogUiKeys.viewCards,
    AppViewMode.grid => CatalogUiKeys.viewGrid,
  };
  await tester.tap(find.text(key.en).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  tearDown(() async => sl.reset());

  testWidgets('Brands supports all view modes at 280px RTL and 1.5 scale', (
    tester,
  ) async {
    late FakeBrandsRepository repository;
    sl.registerFactory<AppSettingsManager>(
      () => AppSettingsManager(storage: MemoryStorage()),
    );
    sl.registerFactory<FlashMessages>(FlashMessages.new);
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

    for (final mode in AppViewMode.values) {
      repository = FakeBrandsRepository();
      await pumpScreenMatrix(
        tester,
        width: 280,
        direction: TextDirection.rtl,
        dark: false,
        textScale: 1.5,
        home: BlocProvider<AccessCubit>(
          create: (_) =>
              AccessCubit(getMyAccess: GetMyAccessUseCase(_AccessRepository()))
                ..load(),
          child: const Scaffold(body: BrandsScreen()),
        ),
      );
      await _chooseMode(tester, mode);
      expect(
        BlocProvider.of<ViewModeCubit>(
          tester.element(find.byType(ListPageTemplate)),
        ).state,
        mode,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Colors supports all view modes at 280px RTL and 1.5 scale', (
    tester,
  ) async {
    late FakeColorsRepository repository;
    sl.registerFactory<AppSettingsManager>(
      () => AppSettingsManager(storage: MemoryStorage()),
    );
    sl.registerFactory<FlashMessages>(FlashMessages.new);
    sl.registerFactory<ColorStatsCubit>(
      () => ColorStatsCubit(getColorStats: GetColorStatsUseCase(repository)),
    );
    sl.registerFactory<ColorsListCubit>(
      () => ColorsListCubit(
        getColors: GetColorsUseCase(repository),
        setColorActive: SetColorActiveUseCase(repository),
        deleteColor: DeleteColorUseCase(repository),
        flashMessages: sl(),
      ),
    );

    for (final mode in AppViewMode.values) {
      repository = FakeColorsRepository();
      await pumpScreenMatrix(
        tester,
        width: 280,
        direction: TextDirection.rtl,
        dark: false,
        textScale: 1.5,
        home: BlocProvider<AccessCubit>(
          create: (_) =>
              AccessCubit(getMyAccess: GetMyAccessUseCase(_AccessRepository()))
                ..load(),
          child: const Scaffold(body: ColorsScreen()),
        ),
      );
      await _chooseMode(tester, mode);
      expect(
        BlocProvider.of<ViewModeCubit>(
          tester.element(find.byType(ListPageTemplate)),
        ).state,
        mode,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
