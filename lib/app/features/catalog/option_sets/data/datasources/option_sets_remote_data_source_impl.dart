import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/option_sets_endpoint.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_sets_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/models/option_set_model.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';

class OptionSetsRemoteDataSourceImpl implements OptionSetsRemoteDataSource {
  OptionSetsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  bool _includeCounts = true;

  @override
  Future<ApiResult<PaginatedResult<OptionSetModel>>> getOptionSets(
    OptionSetListQuery query,
  ) async {
    final preferred = await _getOptionSets(
      query,
      select: _includeCounts
          ? OptionSetsEndpoint.select
          : OptionSetsEndpoint.baseSelect,
    );
    if (preferred case ApiFailure<PaginatedResult<OptionSetModel>>(
      :final exception,
    )) {
      if (_includeCounts &&
          exception is ApiException &&
          exception.statusCode == 400) {
        _includeCounts = false;
        return _getOptionSets(query, select: OptionSetsEndpoint.baseSelect);
      }
    }
    return preferred;
  }

  Future<ApiResult<PaginatedResult<OptionSetModel>>> _getOptionSets(
    OptionSetListQuery query, {
    required String select,
  }) {
    final term = PostgrestValue.escapeFilter(query.search.trim());
    return _apiClient.getPaginated<OptionSetModel>(
      OptionSetsEndpoint.collection,
      fromJson: OptionSetModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': select,
        'order': "name.${query.sortAscending ? 'asc' : 'desc'},id.asc",
        if (term.isNotEmpty)
          'or': '(name.ilike."*$term*",code.ilike."*$term*")',
        if (query.status == OptionSetStatusFilter.active)
          'is_active': 'eq.true',
        if (query.status == OptionSetStatusFilter.inactive)
          'is_active': 'eq.false',
      },
    );
  }

  @override
  Future<ApiResult<List<CatalogOptionModel>>> getOptions({
    required int optionSetId,
    String search = '',
  }) {
    final term = PostgrestValue.escapeFilter(search.trim());
    return _apiClient.get<List<CatalogOptionModel>>(
      OptionSetsEndpoint.optionsCollection,
      queryParameters: {
        'select': OptionSetsEndpoint.optionsSelect,
        'option_set_id': 'eq.$optionSetId',
        'order': 'sort_order.asc,name.asc,id.asc',
        if (term.isNotEmpty)
          'or': '(name.ilike."*$term*",code.ilike."*$term*")',
      },
      fromJsonList: (rows) =>
          rows.map((row) => CatalogOptionModel.fromJson(row)).toList(),
    );
  }

  @override
  Future<ApiResult<OptionSetModel>> createOptionSet(OptionSetDraft draft) =>
      _apiClient.post(
        OptionSetsEndpoint.collection,
        data: _setJson(draft, includeActiveDefault: true),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<OptionSetModel>> updateOptionSet({
    required int id,
    required OptionSetDraft draft,
  }) => _apiClient.patch(
    OptionSetsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _setJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> deleteOptionSet(int id) => _apiClient.delete(
    OptionSetsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    options: Options(headers: {'Prefer': 'return=minimal'}),
  );

  @override
  Future<ApiResult<Unit>> setOptionSetActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch(
    OptionSetsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<Unit>> createOption({
    required int optionSetId,
    required CatalogOptionDraft draft,
  }) => _apiClient.post(
    OptionSetsEndpoint.optionsCollection,
    data: _optionJson(optionSetId, draft, includeActiveDefault: true),
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<Unit>> updateOption({
    required int optionId,
    required CatalogOptionDraft draft,
  }) => _apiClient.patch(
    OptionSetsEndpoint.optionsCollection,
    queryParameters: {'id': 'eq.$optionId'},
    data: _optionJson(null, draft),
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<Unit>> setOptionActive({
    required int optionId,
    required bool isActive,
  }) => _apiClient.patch(
    OptionSetsEndpoint.optionsCollection,
    queryParameters: {'id': 'eq.$optionId'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  OptionSetModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, OptionSetModel.fromJson, what: 'option set');

  Map<String, Object?> _setJson(
    OptionSetDraft draft, {
    bool includeActiveDefault = false,
  }) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'selection_type': draft.selectionType.name,
    if (includeActiveDefault) 'is_active': draft.isActive ?? true,
    if (!includeActiveDefault && draft.isActive != null)
      'is_active': draft.isActive,
  };

  Map<String, Object?> _optionJson(
    int? optionSetId,
    CatalogOptionDraft draft, {
    bool includeActiveDefault = false,
  }) => {
    'option_set_id': ?optionSetId,
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'sort_order': draft.sortOrder,
    if (includeActiveDefault) 'is_active': draft.isActive ?? true,
    if (!includeActiveDefault && draft.isActive != null)
      'is_active': draft.isActive,
  };
}
