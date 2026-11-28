import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/collections/data/models/collection_model.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_draft.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_list_query.dart';

abstract interface class CollectionsRemoteDataSource {
  Future<ApiResult<PaginatedResult<CollectionModel>>> getCollections(
    CollectionListQuery query,
  );
  Future<ApiResult<CollectionModel>> createCollection(CollectionDraft draft);
  Future<ApiResult<CollectionModel>> updateCollection({
    required int id,
    required CollectionDraft draft,
  });
  Future<ApiResult<Unit>> deleteCollection(int id);
  Future<ApiResult<Unit>> setCollectionActive({
    required int id,
    required bool isActive,
  });
}
