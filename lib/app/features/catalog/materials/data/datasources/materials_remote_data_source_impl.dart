import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/materials/data/materials_endpoint.dart';
import 'package:accounting_software/app/features/catalog/materials/data/datasources/materials_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/materials/data/models/material_model.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_draft.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';

class MaterialsRemoteDataSourceImpl implements MaterialsRemoteDataSource {
  const MaterialsRemoteDataSourceImpl(this._api);
  final IApiClient _api;
  @override
  Future<ApiResult<PaginatedResult<MaterialModel>>> getMaterials(
    MaterialListQuery q,
  ) {
    final term = PostgrestValue.escapeFilter(q.search.trim());
    return _api.getPaginated<MaterialModel>(
      MaterialsEndpoint.collection,
      fromJson: MaterialModel.fromJson,
      page: q.page,
      limit: q.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': MaterialsEndpoint.select,
        'order': _order(q),
        if (term.isNotEmpty)
          'or': '(name.ilike."*$term*",code.ilike."*$term*")',
        if (q.status == MaterialStatusFilter.active) 'is_active': 'eq.true',
        if (q.status == MaterialStatusFilter.inactive) 'is_active': 'eq.false',
        if (q.type != null) 'material_type': 'eq.${q.type}',
      },
    );
  }

  @override
  Future<ApiResult<MaterialModel>> createMaterial(MaterialDraft d) =>
      _api.post<MaterialModel>(
        MaterialsEndpoint.collection,
        data: _json(d),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );
  @override
  Future<ApiResult<MaterialModel>> updateMaterial({
    required int id,
    required MaterialDraft draft,
  }) => _api.patch<MaterialModel>(
    MaterialsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _updateJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );
  @override
  Future<ApiResult<Unit>> deleteMaterial(int id) => _api.delete(
    MaterialsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );
  @override
  Future<ApiResult<Unit>> setMaterialActive({
    required int id,
    required bool isActive,
  }) => _api.patch<Unit>(
    MaterialsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );
  String _order(MaterialListQuery q) {
    final terms = [
      for (final sort in q.sorts)
        '${sort.field.column}.${sort.ascending ? 'asc' : 'desc'}',
    ];
    final hasName = q.sorts.any((sort) => sort.field == MaterialSortField.name);
    return [...terms, if (!hasName) 'name.asc', 'id.asc'].join(',');
  }
  MaterialModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, MaterialModel.fromJson, what: 'material');
  Map<String, dynamic> _updateJson(MaterialDraft draft) {
    final json = _json(draft);
    if (draft.isActive == null) json.remove('is_active');
    return json;
  }
  Map<String, dynamic> _json(MaterialDraft d) => {
    'name': d.name.trim(),
    'code': d.code.trim(),
    'material_type': d.materialType?.name,
    'description': d.description?.trim(),
    'is_active': d.isActive ?? true,
  };
}
