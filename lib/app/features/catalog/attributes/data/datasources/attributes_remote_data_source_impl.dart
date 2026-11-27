import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/attributes_endpoint.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attributes_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/models/attribute_model.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_draft.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_lookup_choices.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';

class AttributesRemoteDataSourceImpl implements AttributesRemoteDataSource {
  const AttributesRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  @override
  Future<ApiResult<PaginatedResult<AttributeModel>>> getAttributes(
    AttributeListQuery query,
  ) {
    final term = PostgrestValue.escapeFilter(query.search.trim());
    return _apiClient.getPaginated<AttributeModel>(
      AttributesEndpoint.collection,
      fromJson: AttributeModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': AttributesEndpoint.select,
        'order': 'name.asc,id.asc',
        if (term.isNotEmpty)
          'or': '(name.ilike."*$term*",code.ilike."*$term*")',
        if (query.status == AttributeStatusFilter.active)
          'is_active': 'eq.true',
        if (query.status == AttributeStatusFilter.inactive)
          'is_active': 'eq.false',
        if (query.dataType != null) 'data_type': 'eq.${query.dataType!.name}',
        if (query.filterable == AttributeFilterableFilter.filterable)
          'is_filterable': 'eq.true',
        if (query.filterable == AttributeFilterableFilter.notFilterable)
          'is_filterable': 'eq.false',
      },
    );
  }

  @override
  Future<ApiResult<AttributeModel>> createAttribute(AttributeDraft draft) =>
      _apiClient.post(
        AttributesEndpoint.collection,
        data: _draftJson(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<AttributeModel>> updateAttribute({
    required int id,
    required AttributeDraft draft,
  }) => _apiClient.patch(
    AttributesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> setAttributeActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch(
    AttributesEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<List<AttributeUnitChoice>>> getUnitChoices() =>
      _apiClient.get<List<AttributeUnitChoice>>(
        AttributesEndpoint.unitsLookup,
        queryParameters: {
          'select': 'id,name,symbol,is_active',
          'is_active': 'eq.true',
          'order': 'name.asc,id.asc',
        },
        requiresAuth: true,
        fromJsonList: (rows) => rows
            .map(
              (row) => AttributeUnitChoice(
                id: _readId(row['id']),
                name: row['name'] as String,
                symbol: row['symbol'] as String,
                isActive: row['is_active'] as bool? ?? true,
              ),
            )
            .toList(),
      );

  @override
  Future<ApiResult<List<AttributeOptionSetChoice>>> getOptionSetChoices() =>
      _apiClient.get<List<AttributeOptionSetChoice>>(
        AttributesEndpoint.optionSetsLookup,
        queryParameters: {
          'select': 'id,name,code,is_active',
          'is_active': 'eq.true',
          'order': 'name.asc,id.asc',
        },
        fromJsonList: (rows) => rows
            .map(
              (row) => AttributeOptionSetChoice(
                id: _readId(row['id']),
                name: row['name'] as String,
                code: row['code'] as String,
                isActive: row['is_active'] as bool? ?? true,
              ),
            )
            .toList(),
      );

  int _readId(Object? value) {
    final id = value is int ? value : int.tryParse(value?.toString() ?? '');
    if (id == null) throw const FormatException('Invalid lookup id');
    return id;
  }

  AttributeModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, AttributeModel.fromJson, what: 'attribute');

  Map<String, Object?> _draftJson(AttributeDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'data_type': draft.dataType.name,
    'unit_id': draft.dataType == AttributeDataType.number ? draft.unitId : null,
    'option_set_id': draft.dataType == AttributeDataType.option
        ? draft.optionSetId
        : null,
    'is_filterable': draft.isFilterable,
    if (draft.isActive != null) 'is_active': draft.isActive,
  };
}
