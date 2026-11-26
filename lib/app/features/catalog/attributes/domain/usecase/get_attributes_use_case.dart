import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';
class GetAttributesUseCase extends UseCase<PaginatedResult<CatalogAttribute>, AttributeListQuery> {
  GetAttributesUseCase(this._repository);
  final AttributesRepository _repository;
  @override
  Future<Either<Failure, PaginatedResult<CatalogAttribute>>> call(AttributeListQuery params) => _repository.getAttributes(params);
}
