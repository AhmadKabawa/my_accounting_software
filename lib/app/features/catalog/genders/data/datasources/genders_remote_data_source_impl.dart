import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/genders/data/genders_endpoint.dart';
import 'package:accounting_software/app/features/catalog/genders/data/datasources/genders_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/genders/data/models/gender_model.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_draft.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_list_query.dart';

class GendersRemoteDataSourceImpl implements GendersRemoteDataSource {
  const GendersRemoteDataSourceImpl(this._api);
  final IApiClient _api;

  @override
  Future<ApiResult<PaginatedResult<GenderModel>>> getGenders(
    GenderListQuery query,
  ) {
    final term = PostgrestValue.escapeFilter(query.search.trim());
    return _api.getPaginated<GenderModel>(
      GendersEndpoint.collection,
      fromJson: GenderModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': GendersEndpoint.select,
        'order': _order(query),
        if (term.isNotEmpty)
          'or': '(name.ilike."*$term*",code.ilike."*$term*")',
        if (query.status == GenderStatusFilter.active) 'is_active': 'eq.true',
        if (query.status == GenderStatusFilter.inactive)
          'is_active': 'eq.false',
      },
    );
  }

  @override
  Future<ApiResult<GenderModel>> createGender(GenderDraft draft) =>
      _api.post<GenderModel>(
        GendersEndpoint.collection,
        data: _draftJson(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<GenderModel>> updateGender({
    required int id,
    required GenderDraft draft,
  }) => _api.patch<GenderModel>(
    GendersEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> deleteGender(int id) => _api.delete(
    GendersEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    options: Options(headers: {'Prefer': 'return=minimal'}),
  );

  @override
  Future<ApiResult<Unit>> setGenderActive({
    required int id,
    required bool isActive,
  }) => _api.patch<Unit>(
    GendersEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  String _order(GenderListQuery query) {
    final terms = [
      for (final sort in query.sorts)
        '${sort.field.column}.${sort.ascending ? 'asc' : 'desc'}',
    ];
    if (!query.sorts.any((sort) => sort.field == GenderSortField.name)) {
      terms.add('name.asc');
    }
    if (!query.sorts.any((sort) => sort.field == GenderSortField.order)) {
      terms.add('sort_order.asc');
    }
    terms.add('id.asc');
    return terms.join(',');
  }

  GenderModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, GenderModel.fromJson, what: 'gender');

  Map<String, dynamic> _draftJson(GenderDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'sort_order': draft.sortOrder,
    if (draft.isActive != null) 'is_active': draft.isActive,
  };
}
