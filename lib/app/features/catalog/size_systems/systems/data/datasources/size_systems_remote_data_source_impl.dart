import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/data/size_query_helpers.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/data/datasources/size_systems_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/data/models/size_system_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/data/size_systems_endpoint.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_stats.dart';

class SizeSystemsRemoteDataSourceImpl implements SizeSystemsRemoteDataSource {
  SizeSystemsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  // After a 400 on the relation projection, stay on the safe projection.
  bool _includeCount = true;

  @override
  Future<ApiResult<PaginatedResult<SizeSystemModel>>> getSizeSystems(
    SizeSystemListQuery query,
  ) async {
    final preferred = await _fetch(
      query,
      _includeCount
          ? SizeSystemsEndpoint.select
          : SizeSystemsEndpoint.selectWithoutCount,
    );
    if (preferred case ApiFailure<PaginatedResult<SizeSystemModel>>(
      :final exception,
    )) {
      if (_includeCount &&
          exception is ApiException &&
          exception.statusCode == 400) {
        _includeCount = false;
        return _fetch(query, SizeSystemsEndpoint.selectWithoutCount);
      }
    }
    return preferred;
  }

  Future<ApiResult<PaginatedResult<SizeSystemModel>>> _fetch(
    SizeSystemListQuery query,
    String select,
  ) {
    final search = SizeQueryHelpers.searchFilter(query.search, const [
      'name',
      'code',
    ]);
    final status = SizeQueryHelpers.statusFilter(query.status);
    return _apiClient.getPaginated<SizeSystemModel>(
      SizeSystemsEndpoint.collection,
      fromJson: SizeSystemModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': select,
        'order': SizeQueryHelpers.order(
          query.sortField.column,
          query.sortAscending,
        ),
        if (search != null) 'or': search,
        if (status != null) 'is_active': status,
      },
    );
  }

  @override
  Future<ApiResult<SizeSystemStats>> getStats() async {
    final total = await _count(const {});
    if (total case ApiFailure<int>(:final exception)) {
      return ApiFailure<SizeSystemStats>(exception);
    }
    final active = await _count(const {'is_active': 'eq.true'});
    if (active case ApiFailure<int>(:final exception)) {
      return ApiFailure<SizeSystemStats>(exception);
    }
    final totalCount = (total as ApiSuccess<int>).data;
    final activeCount = (active as ApiSuccess<int>).data;
    return ApiSuccess(
      SizeSystemStats(
        total: totalCount,
        active: activeCount,
        inactive: totalCount - activeCount,
      ),
    );
  }

  Future<ApiResult<int>> _count(Map<String, dynamic> filter) async {
    final result = await _apiClient.getPaginated<int>(
      SizeSystemsEndpoint.collection,
      fromJson: (json) => json['id'] as int,
      queryParameters: {'select': 'id', ...filter},
      parser: PaginatedParserPresets.supabase,
      page: 1,
      limit: 1,
    );
    return switch (result) {
      ApiSuccess<PaginatedResult<int>>(:final data) => ApiSuccess(
        data.totalCount,
      ),
      ApiFailure<PaginatedResult<int>>(:final exception) => ApiFailure<int>(
        exception,
      ),
    };
  }

  @override
  Future<ApiResult<SizeSystemModel>> createSizeSystem(SizeSystemDraft draft) =>
      _apiClient.post<SizeSystemModel>(
        SizeSystemsEndpoint.collection,
        data: _draftJson(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<SizeSystemModel>> updateSizeSystem({
    required int id,
    required SizeSystemDraft draft,
  }) => _apiClient.patch<SizeSystemModel>(
    SizeSystemsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> deleteSizeSystem(int id) => _apiClient.delete(
    SizeSystemsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );

  @override
  Future<ApiResult<Unit>> setSizeSystemActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch<Unit>(
    SizeSystemsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  SizeSystemModel _single(List<dynamic> rows) => PostgrestValue.single(
    rows,
    SizeSystemModel.fromJson,
    what: 'size system',
  );

  Map<String, dynamic> _draftJson(SizeSystemDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'description': PostgrestValue.nullableTrim(draft.description),
    'is_active': draft.isActive,
  };
}
