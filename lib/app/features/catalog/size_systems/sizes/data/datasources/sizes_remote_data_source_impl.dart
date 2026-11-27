import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/data/size_query_helpers.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/datasources/sizes_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/models/catalog_size_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/sizes_endpoint.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_list_query.dart';

class SizesRemoteDataSourceImpl implements SizesRemoteDataSource {
  SizesRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  // After a 400 on the relation projection, stay on the safe projection.
  bool _includeCount = true;

  @override
  Future<ApiResult<PaginatedResult<CatalogSizeModel>>> getSizes(
    CatalogSizeListQuery query,
  ) async {
    final preferred = await _fetch(
      query,
      _includeCount ? SizesEndpoint.select : SizesEndpoint.selectWithoutCount,
    );
    if (preferred case ApiFailure<PaginatedResult<CatalogSizeModel>>(
      :final exception,
    )) {
      if (_includeCount &&
          exception is ApiException &&
          exception.statusCode == 400) {
        _includeCount = false;
        return _fetch(query, SizesEndpoint.selectWithoutCount);
      }
    }
    return preferred;
  }

  Future<ApiResult<PaginatedResult<CatalogSizeModel>>> _fetch(
    CatalogSizeListQuery query,
    String select,
  ) {
    final search = SizeQueryHelpers.searchFilter(query.search, const [
      'name',
      'code',
    ]);
    final status = SizeQueryHelpers.statusFilter(query.status);
    return _apiClient.getPaginated<CatalogSizeModel>(
      SizesEndpoint.collection,
      fromJson: CatalogSizeModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': select,
        'size_group_id': 'eq.${query.sizeGroupId}',
        'order': order(query),
        if (search != null) 'or': search,
        if (status != null) 'is_active': status,
      },
    );
  }

  /// The default order is the group's natural one: sort_order, then
  /// numeric_value (nulls last), then id. Other sorts keep `id` as tiebreaker.
  static String order(CatalogSizeListQuery query) {
    final dir = query.sortAscending ? 'asc' : 'desc';
    return switch (query.sortField) {
      CatalogSizeSortField.order =>
        'sort_order.$dir,numeric_value.$dir.nullslast,id.asc',
      CatalogSizeSortField.value => 'numeric_value.$dir.nullslast,id.asc',
      CatalogSizeSortField.name => 'name.$dir,id.asc',
      CatalogSizeSortField.code => 'code.$dir,id.asc',
    };
  }

  @override
  Future<ApiResult<CatalogSizeModel>> createSize(CatalogSizeDraft draft) =>
      _apiClient.post<CatalogSizeModel>(
        SizesEndpoint.collection,
        data: _draftJson(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<List<CatalogSizeModel>>> createSizes(
    List<CatalogSizeDraft> drafts,
  ) => _apiClient.post<List<CatalogSizeModel>>(
    SizesEndpoint.collection,
    data: [for (final draft in drafts) _draftJson(draft)],
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: (rows) => [
      for (final row in rows)
        CatalogSizeModel.fromJson(row as Map<String, dynamic>),
    ],
  );

  @override
  Future<ApiResult<CatalogSizeModel>> updateSize({
    required int id,
    required CatalogSizeDraft draft,
  }) => _apiClient.patch<CatalogSizeModel>(
    SizesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> deleteSize(int id) => _apiClient.delete(
    SizesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );

  @override
  Future<ApiResult<Unit>> setSizeActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch<Unit>(
    SizesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  CatalogSizeModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, CatalogSizeModel.fromJson, what: 'size');

  /// `numeric_value` is sent as its exact decimal text, never a double.
  Map<String, dynamic> _draftJson(CatalogSizeDraft draft) => {
    'size_group_id': draft.sizeGroupId,
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'numeric_value': draft.numericValue?.toString(),
    'sort_order': draft.sortOrder,
    'is_active': draft.isActive,
  };
}
