import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/tags/data/tags_endpoint.dart';
import 'package:accounting_software/app/features/catalog/tags/data/datasources/tags_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/tags/data/models/tag_model.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_list_query.dart';

class TagsRemoteDataSourceImpl implements TagsRemoteDataSource {
  const TagsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  @override
  Future<ApiResult<PaginatedResult<TagModel>>> getTags(TagListQuery query) {
    final searchTerm = PostgrestValue.escapeFilter(query.search.trim());
    return _apiClient.getPaginated<TagModel>(
      TagsEndpoint.collection,
      fromJson: TagModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': TagsEndpoint.select,
        'order': _order(query),
        if (searchTerm.isNotEmpty)
          'or': '(name.ilike."*$searchTerm*",slug.ilike."*$searchTerm*")',
        if (query.status == TagStatusFilter.active) 'is_active': 'eq.true',
        if (query.status == TagStatusFilter.inactive) 'is_active': 'eq.false',
      },
    );
  }

  @override
  Future<ApiResult<TagModel>> createTag(CatalogTagDraft draft) =>
      _apiClient.post<TagModel>(
        TagsEndpoint.collection,
        data: _draftJson(draft, includeActiveDefault: true),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<TagModel>> updateTag({
    required int id,
    required CatalogTagDraft draft,
  }) => _apiClient.patch<TagModel>(
    TagsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> deleteTag(int id) => _apiClient.delete(
    TagsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );

  @override
  Future<ApiResult<Unit>> setTagActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch<Unit>(
    TagsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  /// All criteria are applied by PostgREST in priority order. An ID tie-breaker
  /// keeps page boundaries stable when values are equal.
  String _order(TagListQuery query) {
    final terms = [
      for (final sort in query.sorts)
        '${sort.field.column}.${sort.ascending ? 'asc' : 'desc'}',
    ];
    final hasName = query.sorts.any((sort) => sort.field == TagSortField.name);
    return [...terms, if (!hasName) 'name.asc', 'id.asc'].join(',');
  }

  TagModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, TagModel.fromJson, what: 'tag');

  Map<String, dynamic> _draftJson(
    CatalogTagDraft draft, {
    bool includeActiveDefault = false,
  }) => {
    'name': draft.name.trim(),
    'slug': draft.slug.trim(),
    if (includeActiveDefault) 'is_active': draft.isActive ?? true,
    if (!includeActiveDefault && draft.isActive != null)
      'is_active': draft.isActive,
  };
}
