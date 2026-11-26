import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/models/product_type_model.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';

abstract interface class ProductTypesRemoteDataSource {
  Future<ApiResult<PaginatedResult<ProductTypeModel>>> getPage(
    ProductTypeListQuery query,
  );

  Future<ApiResult<ProductTypeModel>> create(ProductTypeDraft draft);

  Future<ApiResult<ProductTypeModel>> update({
    required int id,
    required ProductTypeDraft draft,
  });

  Future<ApiResult<Unit>> setActive({required int id, required bool isActive});

  Future<ApiResult<Unit>> delete(int id);
}
