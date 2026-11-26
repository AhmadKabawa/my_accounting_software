import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/sports/data/sports_endpoint.dart';
import 'package:accounting_software/app/features/catalog/sports/data/datasources/sports_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/sports/data/models/sport_model.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_list_query.dart';

class SportsRemoteDataSourceImpl implements SportsRemoteDataSource {
  const SportsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  @override
  Future<ApiResult<PaginatedResult<SportModel>>> getSports(
    SportListQuery query,
  ) {
    final searchTerm = PostgrestValue.escapeFilter(query.search.trim());
    return _apiClient.getPaginated<SportModel>(
      SportsEndpoint.collection,
      fromJson: SportModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': SportsEndpoint.select,
        'order': _order(query),
        if (searchTerm.isNotEmpty)
          'or':
              '(name.ilike."*$searchTerm*",code.ilike."*$searchTerm*")',
        if (query.status == SportStatusFilter.active) 'is_active': 'eq.true',
        if (query.status == SportStatusFilter.inactive) 'is_active': 'eq.false',
      },
    );
  }

  @override
  Future<ApiResult<SportModel>> createSport(SportDraft draft) =>
      _apiClient.post<SportModel>(
        SportsEndpoint.collection,
        data: _draftJson(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<SportModel>> updateSport({
    required int id,
    required SportDraft draft,
  }) => _apiClient.patch<SportModel>(
    SportsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> deleteSport(int id) => _apiClient.delete(
    SportsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );

  @override
  Future<ApiResult<Unit>> setSportActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch<Unit>(
    SportsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  /// All criteria are applied by PostgREST in priority order. An ID tie-breaker
  /// keeps page boundaries stable when values are equal.
  String _order(SportListQuery query) {
    final terms = [
      for (final sort in query.sorts)
        '${sort.field.column}.${sort.ascending ? 'asc' : 'desc'}',
    ];
    final hasName = query.sorts.any(
      (sort) => sort.field == SportSortField.name,
    );
    return [...terms, if (!hasName) 'name.asc', 'id.asc'].join(',');
  }

  SportModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, SportModel.fromJson, what: 'sport');

  Map<String, dynamic> _draftJson(SportDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'description': _nullIfBlank(draft.description),
    'sort_order': draft.sortOrder,
    'is_active': draft.isActive,
  };

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
