import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/data/brands_endpoint.dart';
import 'package:accounting_software/app/features/catalog/data/datasources/brands_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/data/models/brand_model.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';

class BrandsRemoteDataSourceImpl implements BrandsRemoteDataSource {
  const BrandsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  @override
  Future<ApiResult<PaginatedResult<BrandModel>>> getBrands(
    BrandListQuery query,
  ) => _apiClient.getPaginated<BrandModel>(
    BrandsEndpoint.collection,
    fromJson: BrandModel.fromJson,
    page: query.page,
    limit: query.pageSize,
    parser: PaginatedParserPresets.supabase,
    queryParameters: {
      'select': BrandsEndpoint.selectWithProductCount,
      'order': 'name.' + (query.sortAscending ? 'asc' : 'desc'),
      if (query.search.trim().isNotEmpty)
        'or': '(name.ilike."' +
            '*' + _escapeFilterValue(query.search.trim()) +
            '*",slug.ilike."' +
            '*' + _escapeFilterValue(query.search.trim()) + '*' + '")',
      if (query.status == BrandStatusFilter.active) 'is_active': 'eq.true',
      if (query.status == BrandStatusFilter.inactive) 'is_active': 'eq.false',
    },
  );

  @override
  Future<ApiResult<BrandModel>> createBrand(BrandDraft draft) =>
      _apiClient.post<BrandModel>(
        BrandsEndpoint.collection,
        data: _draftJson(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _singleBrandFromList,
      );

  @override
  Future<ApiResult<BrandModel>> updateBrand({
    required int id,
    required BrandDraft draft,
  }) => _apiClient.patch<BrandModel>(
    BrandsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _singleBrandFromList,
  );

  @override
  Future<ApiResult<Unit>> setBrandActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch<Unit>(
    BrandsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<Unit>> deleteBrand(int id) => _apiClient.delete(
    BrandsEndpoint.collection,
    queryParameters: {'id': 'eq.$id'},
    options: Options(headers: {'Prefer': 'return=minimal'}),
  );

  BrandModel _singleBrandFromList(List<dynamic> rows) {
    if (rows.length != 1 || rows.single is! Map<String, dynamic>) {
      throw const FormatException('Expected one brand from PostgREST');
    }
    return BrandModel.fromJson(rows.single as Map<String, dynamic>);
  }

  Map<String, dynamic> _draftJson(BrandDraft draft) => {
    'name': draft.name.trim(),
    'slug': draft.slug.trim(),
    'logo': _nullableTrim(draft.logo),
    'description': _nullableTrim(draft.description),
  };

  String? _nullableTrim(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  String _escapeFilterValue(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"');
}
