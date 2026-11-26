import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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
  const OptionSetsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  @override
  Future<ApiResult<PaginatedResult<OptionSetModel>>> getOptionSets(
    OptionSetListQuery query,
  ) {
    final term = PostgrestValue.escapeFilter(query.search.trim());
    return _apiClient.getPaginated<OptionSetModel>(
      OptionSetsEndpoint.collection,
      fromJson: OptionSetModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': OptionSetsEndpoint.select,
        'order': 'name.asc,id.asc',
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
  Future<ApiResult<OptionSetModel>> createOptionSet(OptionSetDraft draft) =>
      _apiClient.post(
        OptionSetsEndpoint.collection,
        data: _setJson(draft),
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
    data: _optionJson(optionSetId, draft),
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

  Map<String, Object?> _setJson(OptionSetDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'selection_type': draft.selectionType.name,
    if (draft.isActive != null) 'is_active': draft.isActive,
  };

  Map<String, Object?> _optionJson(
    int? optionSetId,
    CatalogOptionDraft draft,
  ) => {
    if (optionSetId != null) 'option_set_id': optionSetId,
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'sort_order': draft.sortOrder,
    if (draft.isActive != null) 'is_active': draft.isActive,
  };
}
