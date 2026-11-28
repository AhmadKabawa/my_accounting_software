import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_draft.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/repositories/fabric_types_repository.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/create_fabric_type_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/delete_fabric_type_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/get_fabric_types_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/set_fabric_type_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/update_fabric_type_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/cubit/fabric_types_form/fabric_type_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/cubit/fabric_types_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/pages/fabric_types_screen.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_draft.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/repositories/materials_repository.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/create_material_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/delete_material_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/get_materials_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/set_material_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/update_material_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/cubit/materials_form/material_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/cubit/materials_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/pages/materials_screen.dart';
import '../../helpers/localized_app.dart';
import '../../helpers/memory_storage.dart';
import '../../helpers/screen_matrix.dart';

class _AccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => const Right(
    AccessSnapshot(
      userId: 'test-user',
      username: 'test',
      email: null,
      isSuperAdmin: false,
      roles: [],
      permissions: {Permission('masterdata.manage')},
      branches: [],
      warehouses: [],
      posTerminals: [],
    ),
  );
}

class _MaterialsRepository implements MaterialsRepository {
  const _MaterialsRepository({this.withItems = false});

  final bool withItems;

  @override
  Future<Either<Failure, PaginatedResult<CatalogMaterial>>> getMaterials(
    MaterialListQuery query,
  ) async {
    final items = withItems
        ? const [
            CatalogMaterial(
              id: 1,
              name: 'Cotton',
              code: 'MAT-COTTON',
              materialType: MaterialType.natural,
              isActive: true,
            ),
          ]
        : const <CatalogMaterial>[];
    return Right(
      PaginatedResult(
        items: items,
        totalCount: items.length,
        currentPage: query.page,
        totalPages: items.isEmpty ? 0 : 1,
      ),
    );
  }

  @override
  Future<Either<Failure, CatalogMaterial>> createMaterial(
    MaterialDraft draft,
  ) async => Right(
    CatalogMaterial(
      id: 1,
      name: draft.name,
      code: draft.code,
      materialType: draft.materialType,
      description: draft.description,
      isActive: draft.isActive ?? true,
    ),
  );

  @override
  Future<Either<Failure, Unit>> deleteMaterial(int id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> setMaterialActive({
    required int id,
    required bool isActive,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, CatalogMaterial>> updateMaterial({
    required int id,
    required MaterialDraft draft,
  }) async => Right(
    CatalogMaterial(
      id: id,
      name: draft.name,
      code: draft.code,
      materialType: draft.materialType,
      description: draft.description,
      isActive: draft.isActive ?? true,
    ),
  );
}

class _FabricTypesRepository implements FabricTypesRepository {
  const _FabricTypesRepository({this.withItems = false});

  final bool withItems;

  @override
  Future<Either<Failure, PaginatedResult<CatalogFabricType>>> getFabricTypes(
    FabricTypeListQuery query,
  ) async {
    final items = withItems
        ? const [
            CatalogFabricType(
              id: 1,
              name: 'Cotton knit',
              code: 'FAB-COTTON-KNIT',
              fabricCategory: FabricCategory.knit,
              isActive: true,
            ),
          ]
        : const <CatalogFabricType>[];
    return Right(
      PaginatedResult(
        items: items,
        totalCount: items.length,
        currentPage: query.page,
        totalPages: items.isEmpty ? 0 : 1,
      ),
    );
  }

  @override
  Future<Either<Failure, CatalogFabricType>> createFabricType(
    FabricTypeDraft draft,
  ) async => Right(
    CatalogFabricType(
      id: 1,
      name: draft.name,
      code: draft.code,
      fabricCategory: draft.fabricCategory,
      description: draft.description,
      isNamedFabric: draft.isNamedFabric,
      isActive: draft.isActive ?? true,
    ),
  );

  @override
  Future<Either<Failure, Unit>> deleteFabricType(int id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> setFabricTypeActive({
    required int id,
    required bool isActive,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, CatalogFabricType>> updateFabricType({
    required int id,
    required FabricTypeDraft draft,
  }) async => Right(
    CatalogFabricType(
      id: id,
      name: draft.name,
      code: draft.code,
      fabricCategory: draft.fabricCategory,
      description: draft.description,
      isNamedFabric: draft.isNamedFabric,
      isActive: draft.isActive ?? true,
    ),
  );
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  for (final width in [360.0, 600.0, 900.0, 1200.0]) {
    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      for (final dark in [false, true]) {
        testWidgets(
          'materials screen renders at $width, $direction, dark=$dark',
          (tester) async {
            final repository = _MaterialsRepository();
            _registerMaterials(repository);
            addTearDown(() async => sl.reset());

            await pumpScreenMatrix(
              tester,
              width: width,
              direction: direction,
              dark: dark,
              home: BlocProvider<AccessCubit>(
                create: (_) => AccessCubit(
                  getMyAccess: GetMyAccessUseCase(_AccessRepository()),
                )..load(),
                child: const Scaffold(body: MaterialsScreen()),
              ),
            );

            expect(find.byType(MaterialsScreen), findsOneWidget);
            expect(find.text('No materials yet'), findsOneWidget);
            expect(find.textContaining('{'), findsNothing);
          },
        );

        testWidgets(
          'fabric types screen renders at $width, $direction, dark=$dark',
          (tester) async {
            final repository = _FabricTypesRepository();
            _registerFabricTypes(repository);
            addTearDown(() async => sl.reset());

            await pumpScreenMatrix(
              tester,
              width: width,
              direction: direction,
              dark: dark,
              home: BlocProvider<AccessCubit>(
                create: (_) => AccessCubit(
                  getMyAccess: GetMyAccessUseCase(_AccessRepository()),
                )..load(),
                child: const Scaffold(body: FabricTypesScreen()),
              ),
            );

            expect(find.byType(FabricTypesScreen), findsOneWidget);
            expect(find.text('No fabric types yet'), findsOneWidget);
            expect(find.textContaining('{'), findsNothing);
          },
        );
      }
    }
  }

  for (final width in [360.0, 1200.0]) {
    testWidgets('materials displays rows at $width', (tester) async {
      _registerMaterials(const _MaterialsRepository(withItems: true));
      addTearDown(() async => sl.reset());

      await pumpScreenMatrix(
        tester,
        width: width,
        direction: TextDirection.rtl,
        dark: false,
        home: _withAccess(const Scaffold(body: MaterialsScreen())),
      );

      expect(find.text('MAT-COTTON'), findsOneWidget);
    });

    testWidgets('fabric types displays rows at $width', (tester) async {
      _registerFabricTypes(const _FabricTypesRepository(withItems: true));
      addTearDown(() async => sl.reset());

      await pumpScreenMatrix(
        tester,
        width: width,
        direction: TextDirection.rtl,
        dark: false,
        home: _withAccess(const Scaffold(body: FabricTypesScreen())),
      );

      expect(find.text('FAB-COTTON-KNIT'), findsOneWidget);
    });
  }

  testWidgets('materials add form validates required fields', (tester) async {
    final repository = const _MaterialsRepository();
    _registerMaterials(repository);
    addTearDown(() async => sl.reset());

    await pumpScreenMatrix(
      tester,
      width: 1200,
      direction: TextDirection.ltr,
      dark: false,
      home: _withAccess(const Scaffold(body: MaterialsScreen())),
    );

    await tester.tap(find.text('Add material').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsNWidgets(2));
  });

  testWidgets('fabric types add form validates required fields', (
    tester,
  ) async {
    final repository = const _FabricTypesRepository();
    _registerFabricTypes(repository);
    addTearDown(() async => sl.reset());

    await pumpScreenMatrix(
      tester,
      width: 1200,
      direction: TextDirection.ltr,
      dark: false,
      home: _withAccess(const Scaffold(body: FabricTypesScreen())),
    );

    await tester.tap(find.text('Add fabric type').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsNWidgets(2));
  });
}

Widget _withAccess(Widget child) => BlocProvider<AccessCubit>(
  create: (_) =>
      AccessCubit(getMyAccess: GetMyAccessUseCase(_AccessRepository()))..load(),
  child: child,
);

void _registerMaterials(MaterialsRepository repository) {
  sl.registerFactory<FlashMessages>(FlashMessages.new);
  sl.registerSingleton<AppSettingsManager>(
    AppSettingsManager(storage: MemoryStorage()),
  );
  sl.registerFactory<MaterialsListCubit>(
    () => MaterialsListCubit(
      getItems: GetMaterialsUseCase(repository),
      setActive: SetMaterialActiveUseCase(repository),
      deleteItem: DeleteMaterialUseCase(repository),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory<MaterialFormCubit>(
    () => MaterialFormCubit(
      create: CreateMaterialUseCase(repository),
      update: UpdateMaterialUseCase(repository),
      flashMessages: sl(),
    ),
  );
}

void _registerFabricTypes(FabricTypesRepository repository) {
  sl.registerFactory<FlashMessages>(FlashMessages.new);
  sl.registerSingleton<AppSettingsManager>(
    AppSettingsManager(storage: MemoryStorage()),
  );
  sl.registerFactory<FabricTypesListCubit>(
    () => FabricTypesListCubit(
      getItems: GetFabricTypesUseCase(repository),
      setActive: SetFabricTypeActiveUseCase(repository),
      deleteItem: DeleteFabricTypeUseCase(repository),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory<FabricTypeFormCubit>(
    () => FabricTypeFormCubit(
      create: CreateFabricTypeUseCase(repository),
      update: UpdateFabricTypeUseCase(repository),
      flashMessages: sl(),
    ),
  );
}
