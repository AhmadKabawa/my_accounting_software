import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_draft.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_list_query.dart';

abstract interface class CollectionsRepository {
  Future<Either<Failure, PaginatedResult<CatalogCollection>>> getCollections(
    CollectionListQuery query,
  );
  Future<Either<Failure, CatalogCollection>> createCollection(CollectionDraft draft);
  Future<Either<Failure, CatalogCollection>> updateCollection({
    required int id,
    required CollectionDraft draft,
  });
  Future<Either<Failure, Unit>> deleteCollection(int id);
  Future<Either<Failure, Unit>> setCollectionActive({
    required int id,
    required bool isActive,
  });
}
