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
  ) async {
    final searchTerm = PostgrestValue.escapeFilter(query.search.trim());
    final result = await _apiClient.getPaginated<ColorModel>(
      ColorsEndpoint.collection,
      fromJson: ColorModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': ColorsEndpoint.select,
        'order': _order(query),
        if (searchTerm.isNotEmpty)
          'or':
              '(name.ilike."*$searchTerm*",code.ilike."*$searchTerm*",hex_code.ilike."*$searchTerm*")',
        if (query.status == ColorStatusFilter.active) 'is_active': 'eq.true',
        if (query.status == ColorStatusFilter.inactive) 'is_active': 'eq.false',
      },
    );

    if (result case ApiFailure<PaginatedResult<ColorModel>>()) return result;
    final page = (result as ApiSuccess<PaginatedResult<ColorModel>>).data;
    if (page.items.isEmpty) return result;

    // The usage view is security_invoker. If its RLS-visible rows cannot be
    // read, keep the catalog list usable and leave usage as unknown (null).
    final ids = page.items.map((color) => color.id).join(',');
    final usageResult = await _apiClient.get<List<Map<String, dynamic>>>(
      ColorsEndpoint.usageView,
      queryParameters: {
        'select': 'color_id,product_count,component_count',
        'color_id': 'in.($ids)',
      },
      fromJsonList: (rows) => rows
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList(growable: false),
    );
    if (usageResult case ApiFailure<List<Map<String, dynamic>>>()) {
      return result;
    }

    final usageByColorId = {
      for (final row
          in (usageResult as ApiSuccess<List<Map<String, dynamic>>>).data)
        if (row['color_id'] != null) (row['color_id'] as num).toInt(): row,
    };
    final enrichedItems = [
      for (final color in page.items)
        if (usageByColorId[color.id] case final usage?)
          color.withUsage(
            productCount: (usage['product_count'] as num?)?.toInt(),
            componentCount: (usage['component_count'] as num?)?.toInt(),
          )
        else
          color,
    ];

    return ApiSuccess(
      PaginatedResult<ColorModel>(
        items: enrichedItems,
        totalCount: page.totalCount,
        currentPage: page.currentPage,
        totalPages: page.totalPages,
        isFromCache: page.isFromCache,
      ),
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

  String _order(ColorListQuery query) {
    final terms = [
      for (final sort in query.sorts)
        '${sort.field.column}.${sort.ascending ? 'asc' : 'desc'}',
    ];
    final hasName = query.sorts.any(
      (sort) => sort.field == ColorSortField.name,
    );
    return [...terms, if (!hasName) 'name.asc', 'id.asc'].join(',');
  }

  ColorModel _single(List<dynamic> rows) =>
      PostgrestValue.single(rows, ColorModel.fromJson, what: 'color');

  Map<String, dynamic> _draftJson(CatalogColorDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'hex_code': HexColor.normalize(draft.hexCode),
    'sort_order': draft.sortOrder,
    'is_active': draft.isActive,
  };
}
