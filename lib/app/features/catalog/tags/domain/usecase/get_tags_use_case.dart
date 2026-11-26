import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_list_query.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/repositories/tags_repository.dart';

class GetTagsUseCase
    extends UseCase<PaginatedResult<CatalogTag>, TagListQuery> {
  GetTagsUseCase(this._repository);
  final TagsRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<CatalogTag>>> call(
    TagListQuery params,
  ) => _repository.getTags(params);
}
