import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/date/date_only.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/seasons_endpoint.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/datasources/seasons_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/models/season_model.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_draft.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_list_query.dart';

class SeasonsRemoteDataSourceImpl implements SeasonsRemoteDataSource {
  const SeasonsRemoteDataSourceImpl(this._api);
  final IApiClient _api;

  @override
  Future<ApiResult<PaginatedResult<SeasonModel>>> getSeasons(
    SeasonListQuery query,
  ) {
    final term = PostgrestValue.escapeFilter(query.search.trim());
    return _api.getPaginated<SeasonModel>(
      SeasonsEndpoint.collection,
      fromJson: SeasonModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': SeasonsEndpoint.select,
        'order': _order(query),
        if (term.isNotEmpty)
          'or': '(name.ilike."*$term*",code.ilike."*$term*")',
        if (query.status == SeasonStatusFilter.active) 'is_active': 'eq.true',
        if (query.status == SeasonStatusFilter.inactive) 'is_active': 'eq.false',
        if (query.type != null) 'season_type': 'eq.${query.type}',
      },
    );
  }

  @override
  Future<ApiResult<SeasonModel>> createSeason(SeasonDraft draft) =>
      _api.post<SeasonModel>(
        SeasonsEndpoint.collection,
        data: _json(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<SeasonModel>> updateSeason({
    required int id,
    required SeasonDraft draft,
  }) => _api.patch<SeasonModel>(
    SeasonsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _updateJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> deleteSeason(int id) => _api.delete(
    SeasonsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );

  @override
  Future<ApiResult<Unit>> setSeasonActive({
    required int id,
    required bool isActive,
  }) => _api.patch<Unit>(
    SeasonsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  String _order(SeasonListQuery query) {
    final terms = [
      for (final sort in query.sorts)
        '${sort.field.column}.${sort.ascending ? 'asc' : 'desc'}',
    ];
    return [...terms, 'name.asc', 'id.asc'].join(',');
  }

  SeasonModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, SeasonModel.fromJson, what: 'season');

  Map<String, dynamic> _updateJson(SeasonDraft draft) {
    final json = _json(draft);
    if (draft.isActive == null) json.remove('is_active');
    return json;
  }

  Map<String, dynamic> _json(SeasonDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'season_type': draft.seasonType?.name,
    'start_date': draft.startDate == null
        ? null
        : DateOnly.toApiString(draft.startDate!),
    'end_date': draft.endDate == null
        ? null
        : DateOnly.toApiString(draft.endDate!),
    'is_active': draft.isActive ?? true,
  };
}
