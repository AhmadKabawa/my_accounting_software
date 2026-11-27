import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_list_query.dart';

abstract class SizesRepository {
  Future<Either<Failure, PaginatedResult<CatalogSize>>> getSizes(
    CatalogSizeListQuery query,
  );
  Future<Either<Failure, CatalogSize>> createSize(CatalogSizeDraft draft);

  /// One POST with an array body: PostgREST inserts it as one statement, so a
  /// failing row (e.g. duplicate code) rejects the whole batch.
  Future<Either<Failure, List<CatalogSize>>> createSizes(
    List<CatalogSizeDraft> drafts,
  );
  Future<Either<Failure, CatalogSize>> updateSize({
    required int id,
    required CatalogSizeDraft draft,
  });
  Future<Either<Failure, Unit>> deleteSize(int id);
  Future<Either<Failure, Unit>> setSizeActive({
    required int id,
    required bool isActive,
  });
}
