import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/product_type_endpoints.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/datasources/product_types_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/models/product_type_model.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';

class ProductTypesRemoteDataSourceImpl implements ProductTypesRemoteDataSource {
  ProductTypesRemoteDataSourceImpl(this._apiClient);

  final IApiClient _apiClient;
  bool _includeUsageCounts = true;

  @override
  Future<ApiResult<PaginatedResult<ProductTypeModel>>> getPage(
    ProductTypeListQuery query,
  ) async {
    final search = _escapeFilterValue(query.search.trim());
    final preferred = await _getPage(
      query,
      search,
      _includeUsageCounts
          ? ProductTypeEndpoints.select
          : ProductTypeEndpoints.selectWithoutUsageCounts,
    );
    if (preferred case ApiFailure<PaginatedResult<ProductTypeModel>>(
      exception: final exception,
    )) {
      if (_includeUsageCounts &&
          exception is ApiException &&
          exception.statusCode == 400) {
        _includeUsageCounts = false;
        return _getPage(
          query,
          search,
          ProductTypeEndpoints.selectWithoutUsageCounts,
        );
      }
    }
    return preferred;
  }

  Future<ApiResult<PaginatedResult<ProductTypeModel>>> _getPage(
    ProductTypeListQuery query,
    String search,
    String select,
  ) => _apiClient.getPaginated<ProductTypeModel>(
    ProductTypeEndpoints.collection,
    fromJson: ProductTypeModel.fromJson,
    page: query.page,
    limit: query.pageSize,
    parser: PaginatedParserPresets.supabase,
    queryParameters: {
      'select': select,
      'order': ProductTypeEndpoints.order,
      if (search.isNotEmpty)
        'or': '(name.ilike."*$search*",code.ilike."*$search*")',
      if (query.status == ProductTypeStatusFilter.active)
        'is_active': 'eq.true',
      if (query.status == ProductTypeStatusFilter.inactive)
        'is_active': 'eq.false',
    },
  );

  @override
  Future<ApiResult<ProductTypeModel>> create(ProductTypeDraft draft) =>
      _apiClient.post<ProductTypeModel>(
        ProductTypeEndpoints.collection,
        data: _draftJson(draft),
        options: Options(headers: {'Prefer': 'return=representation'}),
        fromJsonList: _single,
      );

  @override
  Future<ApiResult<ProductTypeModel>> update({
    required int id,
    required ProductTypeDraft draft,
  }) => _apiClient.patch<ProductTypeModel>(
    ProductTypeEndpoints.collection,
    queryParameters: {'id': 'eq.$id'},
    data: _draftJson(draft),
    options: Options(headers: {'Prefer': 'return=representation'}),
    fromJsonList: _single,
  );

  @override
  Future<ApiResult<Unit>> setActive({
    required int id,
    required bool isActive,
  }) => _apiClient.patch<Unit>(
    ProductTypeEndpoints.collection,
    queryParameters: {'id': 'eq.$id'},
    data: {'is_active': isActive},
    options: Options(headers: {'Prefer': 'return=minimal'}),
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<Unit>> delete(int id) => _apiClient.delete(
    ProductTypeEndpoints.collection,
    queryParameters: {'id': 'eq.$id'},
    options: Options(headers: {'Prefer': 'return=minimal'}),
  );

  ProductTypeModel _single(List<dynamic> rows) => PostgrestValue.single(
    rows,
    ProductTypeModel.fromJson,
    what: 'product type',
  );

  Map<String, dynamic> _draftJson(ProductTypeDraft draft) => {
    'name': draft.name.trim(),
    'code': draft.code.trim(),
    'description': PostgrestValue.nullableTrim(draft.description),
    'sort_order': draft.sortOrder,
    if (draft.isActive != null) 'is_active': draft.isActive,
  };

  String _escapeFilterValue(String value) =>
      value.replaceAll(r'\\', r'\\\\').replaceAll('"', r'\\"');
}
