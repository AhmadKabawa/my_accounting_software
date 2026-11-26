import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_attribute_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_link_option.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_option_set_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_size_group_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/failures/product_type_failures.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_type_links_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_state.dart';

void main() {
  late _FakeTypesRepository types;
  late _FakeLinksRepository links;
  late ProductTypeDetailsCubit cubit;

  setUp(() {
    types = _FakeTypesRepository();
    links = _FakeLinksRepository();
    cubit = ProductTypeDetailsCubit(
      repository: links,
      productTypesRepository: types,
    );
  });

  tearDown(() async => cubit.close());

  test('loads product type and all three link sections', () async {
    links.sizeGroups = [_sizeGroup(id: 1, genderId: null, isDefault: true)];

    await cubit.load(9);

    expect(cubit.state, isA<ProductTypeDetailsLoaded>());
    final state = cubit.state as ProductTypeDetailsLoaded;
    expect(state.productType.name, 'Shoes');
    expect(state.sizeGroups, hasLength(1));
    expect(state.attributes, isEmpty);
    expect(state.optionSets, isEmpty);
  });

  test('rejects a second default size group for the null gender', () async {
    links.sizeGroups = [_sizeGroup(id: 1, genderId: null, isDefault: true)];
    await cubit.load(9);

    await cubit.addSizeGroup(
      sizeGroupId: 22,
      genderId: null,
      isDefault: true,
    );

    final state = cubit.state as ProductTypeDetailsLoaded;
    expect(state.updateFailure, isA<ProductTypeDefaultSizeGroupConflictFailure>());
    expect(links.createSizeGroupCalls, 0);
  });

  test('checks published products before making an attribute required', () async {
    await cubit.load(9);

    await cubit.addAttribute(attributeId: 44, isRequired: true);

    final countIndex = links.calls.indexOf('published-count');
    final createIndex = links.calls.indexOf('create-attribute');
    expect(countIndex, greaterThanOrEqualTo(0));
    expect(createIndex, greaterThan(countIndex));
    final state = cubit.state as ProductTypeDetailsLoaded;
    expect(state.publishedProductCount, 6);
  });
}

ProductType _type() => const ProductType(
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

ProductTypeSizeGroupLink _sizeGroup({
  required int id,
  required int? genderId,
  required bool isDefault,
}) => ProductTypeSizeGroupLink(
  id: id,
  sizeGroupId: id + 10,
  sizeGroupName: 'Group',
  sizeGroupCode: 'GRP',
  genderId: genderId,
  genderName: null,
  isDefault: isDefault,
  sortOrder: 0,
);

class _FakeTypesRepository implements ProductTypesRepository {
  @override
  Future<Either<Failure, ProductType>> getById(int id) async => Right(_type());

  @override
  Future<Either<Failure, PaginatedResult<ProductType>>> getPage(
    ProductTypeListQuery query,
  ) async => const Right(
    PaginatedResult(
      items: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 0,
    ),
  );

  @override
  Future<Either<Failure, ProductType>> create(ProductTypeDraft draft) async =>
      Right(_type());

  @override
  Future<Either<Failure, ProductType>> update({
    required int id,
    required ProductTypeDraft draft,
  }) async => Right(_type());

  @override
  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> delete(int id) async => const Right(unit);
}

class _FakeLinksRepository implements ProductTypeLinksRepository {
  List<ProductTypeSizeGroupLink> sizeGroups = [];
  final List<String> calls = [];
  int createSizeGroupCalls = 0;

  @override
  Future<Either<Failure, List<ProductTypeSizeGroupLink>>> getSizeGroupLinks(
    int id,
  ) async => Right(sizeGroups);

  @override
  Future<Either<Failure, List<ProductTypeAttributeLink>>> getAttributeLinks(
    int id,
  ) async => const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeOptionSetLink>>> getOptionSetLinks(
    int id,
  ) async => const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>> getSizeGroupOptions() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>> getAttributeOptions() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>> getOptionSetOptions() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<ProductTypeLinkOption>>> getGenderOptions() async =>
      const Right([]);

  @override
  Future<Either<Failure, Unit>> createSizeGroupLink(Map<String, dynamic> body) async {
    createSizeGroupCalls++;
    return const Right(unit);
  }

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
  ) async {
    calls.add('create-attribute');
    return const Right(unit);
  }

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
  Future<Either<Failure, int>> getPublishedProductCount(int productTypeId) async {
    calls.add('published-count');
    return const Right(6);
  }
}
