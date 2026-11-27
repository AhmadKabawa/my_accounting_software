import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_lookup_choices.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_draft.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';

abstract interface class AttributesRepository {
  Future<Either<Failure, PaginatedResult<CatalogAttribute>>> getAttributes(
    AttributeListQuery query,
  );
  Future<Either<Failure, CatalogAttribute>> createAttribute(
    AttributeDraft draft,
  );
  Future<Either<Failure, CatalogAttribute>> updateAttribute({
    required int id,
    required AttributeDraft draft,
  });
  Future<Either<Failure, Unit>> setAttributeActive({
    required int id,
    required bool isActive,
  });
  Future<Either<Failure, List<AttributeUnitChoice>>> getUnitChoices();
  Future<Either<Failure, List<AttributeOptionSetChoice>>> getOptionSetChoices();
}
