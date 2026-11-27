import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/data/datasources/size_groups_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/data/models/size_group_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/data/size_groups_endpoint.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/data/size_query_helpers.dart';

class SizeGroupsRemoteDataSourceImpl implements SizeGroupsRemoteDataSource {
  SizeGroupsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  /// Upper bound for the gender picker; the table is a small reference list.
  static const _gendersLimit = 200;

  // After a 400 on the relation projection, stay on the safe projection.
  bool _includeCounts = true;

  @override
  Future<ApiResult<PaginatedResult<SizeGroupModel>>> getSizeGroups(
    SizeGroupListQuery query,
  ) async {
    final preferred = await _fetch(
      query,
      _includeCounts
          ? SizeGroupsEndpoint.select
          : SizeGroupsEndpoint.selectWithoutCounts,
    );
    if (preferred case ApiFailure<PaginatedResult<SizeGroupModel>>(
      :final exception,
    )) {
      if (_includeCounts &&
          exception is ApiException &&
          exception.statusCode == 400) {
        _includeCounts = false;
        return _fetch(query, SizeGroupsEndpoint.selectWithoutCounts);
      }
    }
    return preferred;
  }

  Future<ApiResult<PaginatedResult<SizeGroupModel>>> _fetch(
    SizeGroupListQuery query,
    String select,
  ) {
    final search = SizeQueryHelpers.searchFilter(query.search, const [
      'name',
      'code',
    ]);
    final status = SizeQueryHelpers.statusFilter(query.status);
    return _apiClient.getPaginated<SizeGroupModel>(
      SizeGroupsEndpoint.collection,
      fromJson: SizeGroupModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': select,
        'size_system_id': 'eq.${query.sizeSystemId}',
        'order': SizeQueryHelpers.order(
          query.sortField.column,
          query.sortAscending,
        ),
        if (search != null) 'or': search,
        if (status != null) 'is_active': status,
        if (query.genderId != null) 'gender_id': 'eq.${query.genderId}',
      },
    );
  }

  @override
  Future<ApiResult<List<GenderOptionModel>>> getGenders() async {
    final result = await _apiClient.getPaginated<GenderOptionModel>(
      SizeGroupsEndpoint.genders,
      fromJson: GenderOptionModel.fromJson,
      page: 1,
      limit: _gendersLimit,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': SizeGroupsEndpoint.gendersSelect,
        'order': SizeGroupsEndpoint.gendersOrder,
      },
    );
    return switch (result) {
      ApiSuccess<PaginatedResult<GenderOptionModel>>(:final data) =>
        ApiSuccess(data.items),
      ApiFailure<PaginatedResult<GenderOptionModel>>(:final exception) =>
        ApiFailure<List<GenderOptionModel>>(exception),
    };
  }

  @override
  Future<ApiResult<SizeGroupModel>> createSizeGroup(SizeGroupDraft draft) =>
      _apiClient.post<SizeGroupModel>(
        SizeGroupsEndpoint.collection,
        data: _draftJson(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<SizeGroupModel>> updateSizeGroup({
    required int id,
    required SizeGroupDraft draft,
  }) => _apiClient.patch<SizeGroupModel>(
    SizeGroupsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> deleteSizeGroup(int id) => _apiClient.delete(
    SizeGroupsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );

  @override
  Future<ApiResult<Unit>> setSizeGroupActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch<Unit>(
    SizeGroupsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  SizeGroupModel _single(List<dynamic> rows) => PostgrestValue.single(
    rows,
    SizeGroupModel.fromJson,
    what: 'size group',
  );

  Map<String, dynamic> _draftJson(SizeGroupDraft draft) => {
    'size_system_id': draft.sizeSystemId,
    'gender_id': draft.genderId,
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'description': PostgrestValue.nullableTrim(draft.description),
    'is_active': draft.isActive,
  };
}
