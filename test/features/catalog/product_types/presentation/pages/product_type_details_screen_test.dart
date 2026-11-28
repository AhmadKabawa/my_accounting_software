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
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_attribute_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_link_option.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_option_set_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_size_group_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_type_links_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/pages/product_type_details_screen.dart';
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

final _productType = ProductType(
  id: 9,
  name: 'Shoes',
  code: 'SHOE',
  sortOrder: 0,
  isActive: true,
  productCount: 0,
  sizeGroupCount: 0,
  attributeCount: 0,
  optionSetCount: 0,
  careInstructionCount: 0,
);

class _FakeTypesRepository implements ProductTypesRepository {
  Failure? loadFailure;
  int getByIdCalls = 0;

  @override
  Future<Either<Failure, ProductType>> getById(int id) async {
    getByIdCalls++;
    final failure = loadFailure;
    return failure != null && getByIdCalls == 1
        ? Left(failure)
        : Right(_productType);
  }

  @override
  Future<Either<Failure, PaginatedResult<ProductType>>> getPage(
    ProductTypeListQuery query,
  ) async => const Right(
    PaginatedResult(items: [], totalCount: 0, currentPage: 1, totalPages: 0),
  );

  @override
  Future<Either<Failure, ProductType>> create(ProductTypeDraft draft) async =>
      Right(_productType);

  @override
  Future<Either<Failure, ProductType>> update({
    required int id,
    required ProductTypeDraft draft,
  }) async => Right(_productType);

  @override
  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> delete(int id) async => const Right(unit);
}

class _FakeLinksRepository implements ProductTypeLinksRepository {
  _FakeLinksRepository({this.publishedCount = 0});

  final int publishedCount;
  @override
  Future<Either<Failure, List<ProductTypeSizeGroupLink>>> getSizeGroupLinks(
    int id,
  ) async => const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeAttributeLink>>> getAttributeLinks(
    int id,
  ) async => const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeOptionSetLink>>> getOptionSetLinks(
    int id,
  ) async => const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>>
  getSizeGroupOptions() async => const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>>
  getAttributeOptions() async => const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>>
  getOptionSetOptions() async => const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>>
  getGenderOptions() async => const Right([]);

  @override
  Future<Either<Failure, Unit>> createSizeGroupLink(
    Map<String, dynamic> body,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> patchSizeGroupLink(
    int id,
    Map<String, dynamic> body,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> deleteSizeGroupLink(int id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> createAttributeLink(
    Map<String, dynamic> body,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> patchAttributeLink(
    int productTypeId,
    int attributeId,
    Map<String, dynamic> body,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> deleteAttributeLink(
    int productTypeId,
    int attributeId,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> createOptionSetLink(
    Map<String, dynamic> body,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> patchOptionSetLink(
    int productTypeId,
    int optionSetId,
    Map<String, dynamic> body,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> deleteOptionSetLink(
    int productTypeId,
    int optionSetId,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, int>> getPublishedProductCount(
    int productTypeId,
  ) async => Right(publishedCount);
}

void _register({int publishedCount = 0, Failure? loadFailure}) {
  final types = _FakeTypesRepository()..loadFailure = loadFailure;
  sl.registerFactory<ProductTypeDetailsCubit>(
    () => ProductTypeDetailsCubit(
      repository: _FakeLinksRepository(publishedCount: publishedCount),
      productTypesRepository: types,
    ),
  );
  addTearDown(() async => sl.reset());
}

Widget _home({required bool canManage}) => BlocProvider<AccessCubit>(
  create: (_) => AccessCubit(
    getMyAccess: GetMyAccessUseCase(_AccessRepository(canManage: canManage)),
  )..load(),
  child: const Scaffold(body: ProductTypeDetailsScreen(productTypeId: 9)),
);

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  for (final width in [280.0, 360.0, 600.0, 900.0, 1200.0]) {
    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      for (final dark in [false, true]) {
        testWidgets(
          'product type details renders at $width, $direction, dark=$dark',
          (tester) async {
            _register();
            await pumpScreenMatrix(
              tester,
              width: width,
              direction: direction,
              dark: dark,
              textScale: width == 280 ? 1.5 : 1,
              home: _home(canManage: true),
            );

            expect(find.textContaining('Shoes'), findsOneWidget);
            expect(find.text(ProductTypesKeys.noSizeGroups.en), findsWidgets);
            expect(find.text(ProductTypesKeys.noAttributes.en), findsWidgets);
            expect(find.text(ProductTypesKeys.noOptionSets.en), findsWidgets);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('failed details can be retried from the inline error state', (
    tester,
  ) async {
      _register(loadFailure: const ServerFailure());
      await pumpScreenMatrix(
        tester,
        width: 900,
        direction: TextDirection.ltr,
        dark: false,
        home: _home(canManage: true),
      );

      expect(find.text(ProductTypesKeys.retry.en), findsOneWidget);
      // The first request fails; retrying the action restores loaded data.
      await tester.tap(find.text(ProductTypesKeys.retry.en));
      await tester.pumpAndSettle();
      expect(find.textContaining('Shoes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('published products are shown in a warning banner', (
    tester,
  ) async {
      _register(publishedCount: 2);
      await pumpScreenMatrix(
        tester,
        width: 900,
        direction: TextDirection.rtl,
        dark: false,
        home: _home(canManage: true),
      );

      expect(
        find.text(ProductTypesKeys.publishedProductsWarning.en),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('read-only users see sections without write controls', (
    tester,
  ) async {
    _register();
    await pumpScreenMatrix(
      tester,
      width: 900,
      direction: TextDirection.rtl,
      dark: true,
      home: _home(canManage: false),
    );

    expect(find.byType(SearchableDropdown), findsNothing);
    expect(find.byType(AppIconButton), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
