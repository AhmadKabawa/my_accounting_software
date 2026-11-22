import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/colors/data/colors_endpoint.dart';
import 'package:accounting_software/app/features/catalog/colors/data/datasources/colors_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/colors/data/models/color_model.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';

class ColorsRemoteDataSourceImpl implements ColorsRemoteDataSource {
  const ColorsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  @override
  Future<ApiResult<PaginatedResult<ColorModel>>> getColors(
    ColorListQuery query,
  ) {
    final searchTerm = PostgrestValue.escapeFilter(query.search.trim());
    return _apiClient.getPaginated<ColorModel>(
      ColorsEndpoint.collection,
      fromJson: ColorModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': ColorsEndpoint.select,
        'order': _order(query),
        if (searchTerm.isNotEmpty)
          'or': '(name.ilike."*$searchTerm*",code.ilike."*$searchTerm*",hex_code.ilike."*$searchTerm*")',
        if (query.status == ColorStatusFilter.active) 'is_active': 'eq.true',
        if (query.status == ColorStatusFilter.inactive) 'is_active': 'eq.false',
      },
    );
  }

  @override
  Future<ApiResult<ColorModel>> createColor(CatalogColorDraft draft) =>
      _apiClient.post<ColorModel>(
        ColorsEndpoint.collection,
        data: _draftJson(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<ColorModel>> updateColor({
    required int id,
    required CatalogColorDraft draft,
  }) => _apiClient.patch<ColorModel>(
    ColorsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> deleteColor(int id) => _apiClient.delete(
    ColorsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
  );

  @override
  Future<ApiResult<Unit>> setColorActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch<Unit>(
    ColorsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  /// The manual order is `sort_order` then name; a header sort orders by that
  /// one column (name as the tie-breaker keeps pages stable).
  String _order(ColorListQuery query) {
    final direction = query.sortAscending ? 'asc' : 'desc';
    return switch (query.sortField) {
      ColorSortField.order => 'sort_order.$direction,name.asc',
      ColorSortField.name => 'name.$direction',
      ColorSortField.code => 'code.$direction,name.asc',
    };
  }

  ColorModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, ColorModel.fromJson, what: 'color');

  Map<String, dynamic> _draftJson(CatalogColorDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'hex_code': HexColor.normalize(draft.hexCode),
    'sort_order': draft.sortOrder,
  };
}
