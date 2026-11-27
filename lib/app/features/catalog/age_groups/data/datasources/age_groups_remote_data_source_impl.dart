import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/age_groups_endpoint.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/datasources/age_groups_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/models/age_group_model.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_draft.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_list_query.dart';

class AgeGroupsRemoteDataSourceImpl implements AgeGroupsRemoteDataSource {
  const AgeGroupsRemoteDataSourceImpl(this._api);
  final IApiClient _api;
  @override
  Future<ApiResult<PaginatedResult<AgeGroupModel>>> getAgeGroups(
    AgeGroupListQuery q,
  ) {
    final term = PostgrestValue.escapeFilter(q.search.trim());
    return _api.getPaginated<AgeGroupModel>(
      AgeGroupsEndpoint.collection,
      fromJson: AgeGroupModel.fromJson,
      page: q.page,
      limit: q.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': AgeGroupsEndpoint.select,
        'order':
            '${q.sortField.column}.${q.sortAscending ? 'asc' : 'desc'},id.asc',
        if (term.isNotEmpty) 'name': 'ilike.*$term*',
        if (q.status == AgeGroupStatusFilter.active) 'is_active': 'eq.true',
        if (q.status == AgeGroupStatusFilter.inactive) 'is_active': 'eq.false',
      },
    );
  }

  @override
  Future<ApiResult<AgeGroupModel>> createAgeGroup(AgeGroupDraft d) =>
      _api.post<AgeGroupModel>(
        AgeGroupsEndpoint.collection,
        data: _json(d, create: true),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );
  @override
  Future<ApiResult<AgeGroupModel>> updateAgeGroup({
    required int id,
    required AgeGroupDraft draft,
  }) => _api.patch<AgeGroupModel>(
    AgeGroupsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _json(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );
  @override
  Future<ApiResult<Unit>> deleteAgeGroup(int id) => _api.delete(
    AgeGroupsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    options: Options(headers: {'Prefer': 'return=minimal'}),
  );
  @override
  Future<ApiResult<Unit>> setAgeGroupActive({
    required int id,
    required bool isActive,
  }) => _api.patch<Unit>(
    AgeGroupsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );
  AgeGroupModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, AgeGroupModel.fromJson, what: 'age group');
  Map<String, dynamic> _json(AgeGroupDraft d, {bool create = false}) => {
    'name': d.name.trim(),
    'min_age': d.minAge,
    'max_age': d.maxAge,
    'sort_order': d.sortOrder,
    if (create || d.isActive != null) 'is_active': d.isActive ?? true,
  };
}
