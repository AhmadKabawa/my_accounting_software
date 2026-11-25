import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/categories/data/categories_endpoint.dart';
import 'package:accounting_software/app/features/catalog/categories/data/datasources/categories_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/categories/data/models/category_model.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  const CategoriesRemoteDataSourceImpl(this._apiClient);

  final IApiClient _apiClient;

  // Once the relationship projection is rejected, keep subsequent pages on
  // the safe projection for this data-source lifetime.
  bool _includeProductCount = true;

  @override
  Future<ApiResult<PaginatedResult<CategoryModel>>> getPage({
    required int page,
    required int limit,
  }) async {
    final preferred = await _getPage(
      page: page,
      limit: limit,
      select: _includeProductCount
          ? CategoriesEndpoint.select
          : CategoriesEndpoint.selectWithoutProductCount,
    );
    if (preferred case ApiFailure<PaginatedResult<CategoryModel>>(
      exception: final exception,
    )) {
      // Only retry a client-side query/projection rejection. Permission,
      // connectivity and server failures must remain visible to the caller.
      if (_includeProductCount &&
          exception is ApiException &&
          exception.statusCode == 400) {
        _includeProductCount = false;
        return _getPage(
          page: page,
          limit: limit,
          select: CategoriesEndpoint.selectWithoutProductCount,
        );
      }
    }
    return preferred;
  }

  Future<ApiResult<PaginatedResult<CategoryModel>>> _getPage({
    required int page,
    required int limit,
    required String select,
  }) => _apiClient.getPaginated<CategoryModel>(
    CategoriesEndpoint.collection,
    fromJson: CategoryModel.fromJson,
    page: page,
    limit: limit,
    parser: PaginatedParserPresets.supabase,
    queryParameters: {
      'select': select,
      'order': CategoriesEndpoint.order,
    },
  );

  @override
  Future<ApiResult<CategoryModel>> create(CategoryDraft draft) =>
      _apiClient.post<CategoryModel>(
        CategoriesEndpoint.collection,
        data: _draftJson(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<CategoryModel>> update({
    required int id,
    required CategoryDraft draft,
  }) => _apiClient.patch<CategoryModel>(
    CategoriesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> delete(int id) => _apiClient.delete(
    CategoriesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );

  @override
  Future<ApiResult<Unit>> setActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch<Unit>(
    CategoriesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  CategoryModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, CategoryModel.fromJson, what: 'category');

  Map<String, dynamic> _draftJson(CategoryDraft draft) => {
    'parent_id': draft.parentId,
    'name': draft.name.trim(),
    'slug': draft.slug.trim(),
    'description': PostgrestValue.nullableTrim(draft.description),
    'image': PostgrestValue.nullableTrim(draft.image),
    'sort_order': draft.sortOrder,
  };
}
