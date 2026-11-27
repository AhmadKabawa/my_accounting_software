import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/categories/data/datasources/categories_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/categories/data/models/category_model.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';

class FakeCategoriesRemoteDataSource implements CategoriesRemoteDataSource {
  final Map<int, PaginatedResult<CategoryModel>> pages = {};
  final List<int> requestedPages = [];
  AppException? createFailure;
  AppException? deleteFailure;
  AppException? updateFailure;

  CategoryModel get model => const CategoryModel(
    id: 1,
    name: 'Shoes',
    slug: 'shoes',
    sortOrder: 0,
    isActive: true,
    productCount: 0,
  );

  @override
  Future<ApiResult<PaginatedResult<CategoryModel>>> getPage({
    required int page,
    required int limit,
  }) async {
    requestedPages.add(page);
    return ApiSuccess(
      pages[page] ??
          PaginatedResult<CategoryModel>(
            items: [model],
            totalCount: 1,
            currentPage: page,
            totalPages: 1,
          ),
    );
  }

  @override
  Future<ApiResult<CategoryModel>> create(CategoryDraft draft) async =>
      createFailure == null ? ApiSuccess(model) : ApiFailure(createFailure!);

  @override
  Future<ApiResult<CategoryModel>> update({
    required int id,
    required CategoryDraft draft,
  }) async =>
      updateFailure == null ? ApiSuccess(model) : ApiFailure(updateFailure!);

  @override
  Future<ApiResult<Unit>> delete(int id) async => deleteFailure == null
      ? const ApiSuccess(unit)
      : ApiFailure(deleteFailure!);

  @override
  Future<ApiResult<String>> uploadImage(ImageUpload image) async =>
      const ApiSuccess('https://cdn.example.test/categories/image.webp');

  @override
  Future<ApiResult<Unit>> setActive({
    required int id,
    required bool isActive,
  }) async => const ApiSuccess(unit);
}
