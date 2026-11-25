import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/categories/data/models/category_model.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';

abstract interface class CategoriesRemoteDataSource {
  /// One page of the category table, in tree order.
  Future<ApiResult<PaginatedResult<CategoryModel>>> getPage({
    required int page,
    required int limit,
  });

  Future<ApiResult<CategoryModel>> create(CategoryDraft draft);

  Future<ApiResult<CategoryModel>> update({
    required int id,
    required CategoryDraft draft,
  });

  Future<ApiResult<Unit>> delete(int id);

  Future<ApiResult<Unit>> setActive({required int id, required bool isActive});
}
