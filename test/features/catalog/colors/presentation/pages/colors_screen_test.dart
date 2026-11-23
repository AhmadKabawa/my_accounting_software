import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/storage/storage_service.dart';
import 'package:accounting_software/app/core/storage/storage_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_grid.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/get_colors_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/get_color_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/delete_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/set_color_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/pages/colors_screen.dart';
import '../../../../../helpers/localized_app.dart';
import '../../../../../helpers/screen_matrix.dart';
import '../../support/fake_colors_repository.dart';

class _AccessRepository implements AccessRepository {
  _AccessRepository({required this.canManage});
  final bool canManage;

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'test-user',
      username: 'test',
      email: null,
      isSuperAdmin: false,
      roles: [],
      permissions: {if (canManage) Permissions.masterData.manage},
      branches: [],
      warehouses: [],
      posTerminals: [],
    ),
  );
}

class _MemoryStorage implements StorageService {
  final Map<StorageKey, Object?> values = {};
  @override
  Future<void> write<T>(StorageKey key, T value) async {
    values[key] = value;
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

void _register(FakeColorsRepository repository) {
  sl.registerFactory<AppSettingsManager>(
    () => AppSettingsManager(storage: _MemoryStorage()),
  );
  sl.registerFactory<FlashMessages>(FlashMessages.new);
  sl.registerFactory<ColorsListCubit>(
    () => ColorsListCubit(
      getColors: GetColorsUseCase(repository),
      setColorActive: SetColorActiveUseCase(repository),
      deleteColor: DeleteColorUseCase(repository),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory<ColorStatsCubit>(
    () => ColorStatsCubit(getColorStats: GetColorStatsUseCase(repository)),
  );
  addTearDown(() async => sl.reset());
}

Widget _home({required bool canManage}) => BlocProvider<AccessCubit>(
  create: (_) => AccessCubit(
    getMyAccess: GetMyAccessUseCase(_AccessRepository(canManage: canManage)),
  )..load(),
  child: const Scaffold(body: ColorsScreen()),
);

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  for (final width in [360.0, 600.0, 900.0, 1200.0]) {
    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      for (final dark in [false, true]) {
        testWidgets('colors page renders at $width, $direction, dark=$dark', (
          tester,
        ) async {
          _register(FakeColorsRepository());
          await pumpScreenMatrix(
            tester,
            width: width,
            direction: direction,
            dark: dark,
            home: _home(canManage: true),
          );

          expect(find.byType(ColorsScreen), findsOneWidget);
          expect(find.text('Navy'), findsWidgets);
          expect(find.textContaining('{'), findsNothing);
          expect(find.textContaining('@'), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('statistics cards apply the matching status filter', (
    tester,
  ) async {
    final repository = FakeColorsRepository();
    _register(repository);
    await pumpScreenMatrix(
      tester,
      width: 1200,
      direction: TextDirection.ltr,
      dark: false,
      home: _home(canManage: true),
    );

    await tester.tap(find.text(ColorsKeys.activeColors.en));
    await tester.pumpAndSettle();

    expect(repository.queries.last.status, ColorStatusFilter.active);
  });

  testWidgets('grid view is optional and can return to the table', (
    tester,
  ) async {
    _register(FakeColorsRepository());
    await pumpScreenMatrix(
      tester,
      width: 1200,
      direction: TextDirection.ltr,
      dark: false,
      home: _home(canManage: true),
    );

    await tester.tap(find.byTooltip(CatalogUiKeys.viewMode.en));
    await tester.pumpAndSettle();
    await tester.tap(find.text(CatalogUiKeys.viewGrid.en));
    await tester.pumpAndSettle();
    expect(find.byType(AppDataGrid), findsOneWidget);

    await tester.tap(find.byTooltip(CatalogUiKeys.viewMode.en));
    await tester.pumpAndSettle();
    await tester.tap(find.text(CatalogUiKeys.viewTable.en));
    await tester.pumpAndSettle();
    expect(find.byType(AppDataGrid), findsNothing);
  });

  testWidgets('grid view renders on a narrow RTL dark screen', (tester) async {
    _register(FakeColorsRepository());
    await pumpScreenMatrix(
      tester,
      width: 360,
      direction: TextDirection.rtl,
      dark: true,
      home: _home(canManage: true),
    );

    await tester.tap(find.byTooltip(CatalogUiKeys.viewMode.en));
    await tester.pumpAndSettle();
    await tester.tap(find.text(CatalogUiKeys.viewGrid.en));
    await tester.pumpAndSettle();

    expect(find.byType(AppDataGrid), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty catalog shows the add call to action', (tester) async {
    final repository = FakeColorsRepository()
      ..onGetColors = (_) async =>
          Right(FakeColorsRepository.page(items: const []));
    _register(repository);
    await pumpScreenMatrix(
      tester,
      width: 1200,
      direction: TextDirection.ltr,
      dark: false,
      home: _home(canManage: true),
    );

    expect(find.text(ColorsKeys.empty.en), findsOneWidget);
    expect(find.text(ColorsKeys.add.en), findsWidgets);
  });


  testWidgets('authorized users can select the page and run a bulk action', (
    tester,
  ) async {
      final repository = FakeColorsRepository();
      _register(repository);
      await pumpScreenMatrix(
        tester,
        width: 1200,
        direction: TextDirection.ltr,
        dark: false,
        home: _home(canManage: true),
      );

      expect(find.byType(Checkbox), findsNWidgets(2));
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(find.text(ColorsKeys.bulkActivate.en), findsOneWidget);

      await tester.tap(find.text(ColorsKeys.bulkActivate.en));
      await tester.pumpAndSettle();
      expect(repository.statusUpdates, [(sampleColor.id, true)]);
      expect(find.text(ColorsKeys.bulkActivate.en), findsNothing);
  },
  );

  testWidgets('without manage permission there is no add action', (
    tester,
  ) async {
    _register(FakeColorsRepository());
    await pumpScreenMatrix(
      tester,
      width: 1200,
      direction: TextDirection.ltr,
      dark: false,
      home: _home(canManage: false),
    );

    expect(find.text(ColorsKeys.add.en), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
  });
}
