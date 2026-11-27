import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/models/catalog_size_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_list_query.dart';

abstract class SizesRemoteDataSource {
  Future<ApiResult<PaginatedResult<CatalogSizeModel>>> getSizes(
    CatalogSizeListQuery query,
  );
  Future<ApiResult<CatalogSizeModel>> createSize(CatalogSizeDraft draft);
  Future<ApiResult<List<CatalogSizeModel>>> createSizes(
    List<CatalogSizeDraft> drafts,
  );
  Future<ApiResult<CatalogSizeModel>> updateSize({
    required int id,
    required CatalogSizeDraft draft,
  });
  Future<ApiResult<Unit>> deleteSize(int id);
  Future<ApiResult<Unit>> setSizeActive({
    required int id,
    required bool isActive,
  });
}
