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
import 'package:accounting_software/app/features/catalog/product_types/domain/failures/product_type_failures.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/storage/storage_key.dart';
import 'package:accounting_software/app/core/storage/storage_service.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_stats/product_type_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_types_list/product_types_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/pages/product_types_screen.dart';
import '../../../../../helpers/localized_app.dart';
import '../../../../../helpers/screen_matrix.dart';

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

final _sample = ProductType(
  id: 9,
  name: 'Shoes',
  code: 'SHOE',
  description: 'Footwear',
  sortOrder: 0,
  isActive: true,
  productCount: 0,
  sizeGroupCount: 0,
  attributeCount: 0,
  optionSetCount: 0,
  careInstructionCount: 0,
);

class _FakeProductTypesRepository implements ProductTypesRepository {
  final List<ProductTypeListQuery> queries = [];
  Failure? deleteFailure;
  bool deactivated = false;

  @override
  Future<Either<Failure, PaginatedResult<ProductType>>> getPage(
    ProductTypeListQuery query,
  ) async {
    queries.add(query);
    return Right(
      PaginatedResult(
        items: [_sample],
        totalCount: 1,
        currentPage: query.page,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<Either<Failure, ProductType>> getById(int id) async => Right(_sample);

  @override
  Future<Either<Failure, ProductType>> create(ProductTypeDraft draft) async =>
      Right(_sample);

  @override
  Future<Either<Failure, ProductType>> update({
    required int id,
    required ProductTypeDraft draft,
  }) async => Right(_sample);

  @override
  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  }) async {
    if (!isActive) deactivated = true;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> delete(int id) async {
    final failure = deleteFailure;
    return failure == null ? const Right(unit) : Left(failure);
  }
}

void _register(_FakeProductTypesRepository repository) {
  sl.registerFactory<AppSettingsManager>(
    () => AppSettingsManager(storage: _MemoryStorage()),
  );
  sl.registerFactory<FlashMessages>(FlashMessages.new);
  sl.registerFactory<ProductTypesListCubit>(
    () => ProductTypesListCubit(
      repository: repository,
      flashMessages: sl<FlashMessages>(),
    ),
  );
  sl.registerFactory<ProductTypeStatsCubit>(
    () => ProductTypeStatsCubit(repository: repository),
  );
  addTearDown(() async => sl.reset());
}

Widget _home({required bool canManage}) => BlocProvider<AccessCubit>(
  create: (_) => AccessCubit(
    getMyAccess: GetMyAccessUseCase(_AccessRepository(canManage: canManage)),
  )..load(),
  child: const Scaffold(body: ProductTypesScreen()),
);

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  for (final width in [360.0, 600.0, 900.0, 1200.0]) {
    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      for (final dark in [false, true]) {
        testWidgets(
          'product types page renders at $width, $direction, dark=$dark',
          (tester) async {
            final repository = _FakeProductTypesRepository();
            _register(repository);
            await pumpScreenMatrix(
              tester,
              width: width,
              direction: direction,
              dark: dark,
              home: _home(canManage: true),
            );

            expect(find.byType(ProductTypesScreen), findsOneWidget);
            expect(find.text('Shoes'), findsWidgets);
            expect(find.text('SHOE'), findsWidgets);
            expect(find.text(ProductTypesKeys.updatedAt.en), findsNothing);
            expect(find.text(ProductTypesKeys.unusedStats.en), findsOneWidget);
            expect(find.textContaining('{'), findsNothing);
            expect(find.textContaining('@'), findsNothing);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('statistics apply the matching status filter', (tester) async {
    final repository = _FakeProductTypesRepository();
    _register(repository);
    await pumpScreenMatrix(
      tester,
      width: 1200,
      direction: TextDirection.ltr,
      dark: false,
      home: _home(canManage: true),
    );

    await tester.tap(find.text(ProductTypesKeys.activeStats.en).first);
    await tester.pumpAndSettle();

    expect(repository.queries.last.status, ProductTypeStatusFilter.active);
  });

  testWidgets('read-only users do not see the add action', (tester) async {
    _register(_FakeProductTypesRepository());
    await pumpScreenMatrix(
      tester,
      width: 1200,
      direction: TextDirection.ltr,
      dark: false,
      home: _home(canManage: false),
    );

    expect(find.text(ProductTypesKeys.add.en), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a 23503 delete failure offers direct deactivation', (
    tester,
  ) async {
    final repository = _FakeProductTypesRepository()
      ..deleteFailure = const ProductTypeInUseFailure();
    _register(repository);
    await pumpScreenMatrix(
      tester,
      width: 1200,
      direction: TextDirection.ltr,
      dark: false,
      home: _home(canManage: true),
    );

    await tester.tap(find.byTooltip(CatalogUiKeys.moreActions.en).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(ProductTypesKeys.delete.en).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(ProductTypesKeys.delete.en).last);
    await tester.pumpAndSettle();

    expect(find.text(ProductTypesKeys.inUseTitle.en), findsOneWidget);
    await tester.tap(find.text(ProductTypesKeys.deactivate.en).last);
    await tester.pumpAndSettle();

    expect(repository.deactivated, isTrue);
    expect(tester.takeException(), isNull);
  });
}
