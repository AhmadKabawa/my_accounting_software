import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_draft.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_lookup_choices.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_stats.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';

class FakeAttributesRepository implements AttributesRepository {
  final queries = <AttributeListQuery>[];
  final deletedIds = <int>[];
  final statusUpdates = <(int, bool)>[];
  final createdDrafts = <AttributeDraft>[];
  final updatedDrafts = <(int, AttributeDraft)>[];
  Future<Either<Failure, PaginatedResult<CatalogAttribute>>> Function(
    AttributeListQuery,
  )?
  onGet;
  Either<Failure, AttributeStats> statsResult = const Right(
    AttributeStats(all: 1, active: 1, inactive: 0, filterable: 1),
  );
  Either<Failure, Unit> deleteResult = const Right(unit);
  Either<Failure, Unit> statusResult = const Right(unit);
  Either<Failure, List<AttributeUnitChoice>> unitChoicesResult = const Right([
    AttributeUnitChoice(id: 2, name: 'Kilogram', symbol: 'kg', isActive: true),
  ]);
  Either<Failure, List<AttributeOptionSetChoice>> optionSetChoicesResult = const Right([
    AttributeOptionSetChoice(id: 3, name: 'Sizes', code: 'SIZES', isActive: true),
  ]);
  @override
  Future<Either<Failure, PaginatedResult<CatalogAttribute>>> getAttributes(
    AttributeListQuery query,
  ) {
    queries.add(query);
    final handler = onGet;
    if (handler != null) return handler(query);
    return Future.value(
      Right(
        PaginatedResult<CatalogAttribute>(
          items: const [attribute],
          totalCount: 1,
          currentPage: query.page,
          totalPages: 1,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, AttributeStats>> getAttributeStats() async =>
      statsResult;
  @override
  Future<Either<Failure, CatalogAttribute>> createAttribute(
    AttributeDraft draft,
  ) async {
    createdDrafts.add(draft);
    return const Right(attribute);
  }

  @override
  Future<Either<Failure, CatalogAttribute>> updateAttribute({
    required int id,
    required AttributeDraft draft,
  }) async {
    updatedDrafts.add((id, draft));
    return const Right(attribute);
  }

  @override
  Future<Either<Failure, Unit>> deleteAttribute(int id) async {
    deletedIds.add(id);
    return deleteResult;
  }

  @override
  Future<Either<Failure, Unit>> setAttributeActive({
    required int id,
    required bool isActive,
  }) async {
    statusUpdates.add((id, isActive));
    return statusResult;
  }

  @override
  Future<Either<Failure, List<AttributeUnitChoice>>> getUnitChoices() async =>
      const Right([
        AttributeUnitChoice(
          id: 2,
          name: 'Kilogram',
          symbol: 'kg',
          isActive: true,
        ),
      ]);
  @override
  Future<Either<Failure, List<AttributeOptionSetChoice>>>
  getOptionSetChoices() async => const Right([
    AttributeOptionSetChoice(
      id: 3,
      name: 'Sizes',
      code: 'SIZES',
      isActive: true,
    ),
  ]);

  static const attribute = CatalogAttribute(
    id: 7,
    name: 'Material',
    code: 'MATERIAL',
    dataType: AttributeDataType.text,
    unitId: null,
    unitName: null,
    unitSymbol: null,
    optionSetId: null,
    optionSetName: null,
    optionSetCode: null,
    isFilterable: true,
    isActive: true,
    linkedProductTypesCount: 0,
    valueCount: 0,
  );
}
