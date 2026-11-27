import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/fabric_types_endpoint.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/datasources/fabric_types_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/models/fabric_type_model.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_draft.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_list_query.dart';

class FabricTypesRemoteDataSourceImpl implements FabricTypesRemoteDataSource {
  const FabricTypesRemoteDataSourceImpl(this._api);
  final IApiClient _api;
  @override
  Future<ApiResult<PaginatedResult<FabricTypeModel>>> getFabricTypes(
    FabricTypeListQuery q,
  ) {
    final term = PostgrestValue.escapeFilter(q.search.trim());
    return _api.getPaginated<FabricTypeModel>(
      FabricTypesEndpoint.collection,
      fromJson: FabricTypeModel.fromJson,
      page: q.page,
      limit: q.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': FabricTypesEndpoint.select,
        'order': _order(q),
        if (term.isNotEmpty)
          'or': '(name.ilike."*$term*",code.ilike."*$term*")',
        if (q.status == FabricTypeStatusFilter.active) 'is_active': 'eq.true',
        if (q.status == FabricTypeStatusFilter.inactive)
          'is_active': 'eq.false',
        if (q.category != null) 'fabric_category': 'eq.${q.category}',
      },
    );
  }

  @override
  Future<ApiResult<FabricTypeModel>> createFabricType(FabricTypeDraft d) =>
      _api.post<FabricTypeModel>(
        FabricTypesEndpoint.collection,
        data: _json(d),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );
  @override
  Future<ApiResult<FabricTypeModel>> updateFabricType({
    required int id,
    required FabricTypeDraft draft,
  }) => _api.patch<FabricTypeModel>(
    FabricTypesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _json(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );
  @override
  Future<ApiResult<Unit>> deleteFabricType(int id) => _api.delete(
    FabricTypesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );
  @override
  Future<ApiResult<Unit>> setFabricTypeActive({
    required int id,
    required bool isActive,
  }) => _api.patch<Unit>(
    FabricTypesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );
  String _order(FabricTypeListQuery q) {
    final primary = '${q.sortField.column}.${q.sortAscending ? 'asc' : 'desc'}';
    return [primary, if (q.sortField != FabricTypeSortField.name) 'name.asc', 'id.asc'].join(',');
  }
  FabricTypeModel _single(List<dynamic> rows) => PostgrestValue.single(
    rows,
    FabricTypeModel.fromJson,
    what: 'fabric type',
  );
  Map<String, dynamic> _json(FabricTypeDraft d) => {
    'name': d.name.trim(),
    'code': d.code.trim(),
    'fabric_category': d.fabricCategory?.name,
    'is_named_fabric': d.isNamedFabric,
    'description': d.description?.trim(),
    'is_active': d.isActive ?? true,
  };
}
