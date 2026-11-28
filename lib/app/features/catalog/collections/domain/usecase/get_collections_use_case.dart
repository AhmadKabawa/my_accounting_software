import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_list_query.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/repositories/collections_repository.dart';

class GetCollectionsUseCase
    extends UseCase<PaginatedResult<CatalogCollection>, CollectionListQuery> {
  GetCollectionsUseCase(this._r);
  final CollectionsRepository _r;
  @override
  Future<Either<Failure, PaginatedResult<CatalogCollection>>> call(
    CollectionListQuery p,
  ) => _r.getCollections(p);
}
