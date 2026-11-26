import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/units/data/units_endpoint.dart';
import 'package:accounting_software/app/features/catalog/units/data/datasources/units_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/units/data/models/unit_model.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_draft.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';

class UnitsRemoteDataSourceImpl implements UnitsRemoteDataSource {
  UnitsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  bool _includeUsageCounts = true;

  @override
  Future<ApiResult<PaginatedResult<UnitModel>>> getUnits(
    UnitListQuery query,
  ) async {
    final preferred = await _getUnits(
      query,
      select: _includeUsageCounts
          ? UnitsEndpoint.select
          : UnitsEndpoint.baseSelect,
    );
    if (preferred case ApiFailure<PaginatedResult<UnitModel>>(
      :final exception,
    )) {
      if (_includeUsageCounts &&
          exception is ApiException &&
          exception.statusCode == 400) {
        _includeUsageCounts = false;
        return _getUnits(query, select: UnitsEndpoint.baseSelect);
      }
    }
    return preferred;
  }

  Future<ApiResult<PaginatedResult<UnitModel>>> _getUnits(
    UnitListQuery query, {
    required String select,
  }) {
    final term = PostgrestValue.escapeFilter(query.search.trim());
    return _apiClient.getPaginated<UnitModel>(
      UnitsEndpoint.collection,
      fromJson: UnitModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': select,
        'order': "name.${query.sortAscending ? 'asc' : 'desc'},id.asc",
        if (term.isNotEmpty)
          'or': '(name.ilike."*$term*",symbol.ilike."*$term*")',
        if (query.status == UnitStatusFilter.active) 'is_active': 'eq.true',
        if (query.status == UnitStatusFilter.inactive) 'is_active': 'eq.false',
        if (query.type != null) 'unit_type': 'eq.${query.type!.name}',
      },
    );
  }

  @override
  Future<ApiResult<UnitModel>> createUnit(UnitDraft draft) => _apiClient.post(
    UnitsEndpoint.collection,
    data: _draftJson(draft, includeActiveDefault: true),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<UnitModel>> updateUnit({
    required int id,
    required UnitDraft draft,
  }) => _apiClient.patch(
    UnitsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> setUnitActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch(
    UnitsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<Unit>> deleteUnit(int id) => _apiClient.delete(
    UnitsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    options: Options(headers: {'Prefer': 'return=minimal'}),
  );

  UnitModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, UnitModel.fromJson, what: 'unit');

  Map<String, Object?> _draftJson(
    UnitDraft draft, {
    bool includeActiveDefault = false,
  }) => {
    'name': draft.name.trim(),
    'symbol': draft.symbol.trim(),
    'unit_type': draft.type.name,
    if (includeActiveDefault) 'is_active': draft.isActive ?? true,
    if (!includeActiveDefault && draft.isActive != null)
      'is_active': draft.isActive,
  };
}
