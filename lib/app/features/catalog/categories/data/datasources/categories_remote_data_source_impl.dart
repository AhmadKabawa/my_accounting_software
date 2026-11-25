import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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

  @override
  Future<ApiResult<PaginatedResult<CategoryModel>>> getPage({
    required int page,
    required int limit,
  }) => _apiClient.getPaginated<CategoryModel>(
    CategoriesEndpoint.collection,
    fromJson: CategoryModel.fromJson,
    page: page,
    limit: limit,
    parser: PaginatedParserPresets.supabase,
    queryParameters: {
      'select': CategoriesEndpoint.select,
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

  /// Spec §19: data fields only; `is_active` has its own request. `parent_id`
  /// is always sent, so a null moves the category to the root.
  Map<String, dynamic> _draftJson(CategoryDraft draft) => {
    'parent_id': draft.parentId,
    'name': draft.name.trim(),
    'slug': draft.slug.trim(),
    'description': PostgrestValue.nullableTrim(draft.description),
    'image': PostgrestValue.nullableTrim(draft.image),
    'sort_order': draft.sortOrder,
  };
}
