import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/datasources/product_type_links_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/product_type_links_endpoints.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_attribute_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_link_option.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_option_set_link.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_size_group_link.dart';

class ProductTypeLinksRemoteDataSourceImpl
    implements ProductTypeLinksRemoteDataSource {
  const ProductTypeLinksRemoteDataSourceImpl(this._apiClient);

  final IApiClient _apiClient;

  @override
  Future<ApiResult<List<ProductTypeSizeGroupLink>>> getSizeGroupLinks(int id) =>
      _apiClient.get<List<ProductTypeSizeGroupLink>>(
        ProductTypeLinksEndpoints.sizeGroupLinks,
        queryParameters: {
          'select': ProductTypeLinksEndpoints.sizeGroupLinkSelect,
          'product_type_id': 'eq.$id',
          'order': 'sort_order.asc,id.asc',
        },
        fromJsonList: (rows) => rows
            .map((row) => _sizeGroupLink(row as Map<String, dynamic>))
            .toList(growable: false),
      );

  @override
  Future<ApiResult<List<ProductTypeAttributeLink>>> getAttributeLinks(int id) =>
      _apiClient.get<List<ProductTypeAttributeLink>>(
        ProductTypeLinksEndpoints.attributeLinks,
        queryParameters: {
          'select': ProductTypeLinksEndpoints.attributeLinkSelect,
          'product_type_id': 'eq.$id',
          'order': 'sort_order.asc,attribute_id.asc',
        },
        fromJsonList: (rows) => rows
            .map((row) => _attributeLink(row as Map<String, dynamic>))
            .toList(growable: false),
      );

  @override
  Future<ApiResult<List<ProductTypeOptionSetLink>>> getOptionSetLinks(int id) =>
      _apiClient.get<List<ProductTypeOptionSetLink>>(
        ProductTypeLinksEndpoints.optionSetLinks,
        queryParameters: {
          'select': ProductTypeLinksEndpoints.optionSetLinkSelect,
          'product_type_id': 'eq.$id',
          'order': 'sort_order.asc,option_set_id.asc',
        },
        fromJsonList: (rows) => rows
            .map((row) => _optionSetLink(row as Map<String, dynamic>))
            .toList(growable: false),
      );

  @override
  Future<ApiResult<List<ProductTypeLinkOption>>> getSizeGroupOptions() =>
      _getOptions(
        ProductTypeLinksEndpoints.sizeGroups,
        'id,name,code,is_active,size_systems(name)',
        (json) => _option(json, detail: _embeddedName(json['size_systems'])),
      );

  @override
  Future<ApiResult<List<ProductTypeLinkOption>>> getAttributeOptions() =>
      _getOptions(
        ProductTypeLinksEndpoints.attributes,
        'id,name,code,is_active,data_type',
        (json) => _option(json, detail: json['data_type'] as String?),
      );

  @override
  Future<ApiResult<List<ProductTypeLinkOption>>> getOptionSetOptions() =>
      _getOptions(
        ProductTypeLinksEndpoints.optionSets,
        'id,name,code,is_active',
        _option,
      );

  @override
  Future<ApiResult<List<ProductTypeLinkOption>>> getGenderOptions() =>
      _getOptions(
        ProductTypeLinksEndpoints.genders,
        'id,name,code,is_active',
        _option,
      );

  Future<ApiResult<List<ProductTypeLinkOption>>> _getOptions(
    AppEndpoint endpoint,
    String select,
    ProductTypeLinkOption Function(Map<String, dynamic>) parse,
  ) => _apiClient.get<List<ProductTypeLinkOption>>(
    endpoint,
    queryParameters: {
      'select': select,
      'is_active': 'eq.true',
      'order': 'name.asc,id.asc',
    },
    fromJsonList: (rows) => rows
        .map((row) => parse(row as Map<String, dynamic>))
        .toList(growable: false),
  );

  @override
  Future<ApiResult<Unit>> createSizeGroupLink(Map<String, dynamic> body) =>
      _write(
        ProductTypeLinksEndpoints.sizeGroupLinks,
        body: body,
        method: _WriteMethod.post,
      );

  @override
  Future<ApiResult<Unit>> patchSizeGroupLink(
    int id,
    Map<String, dynamic> body,
  ) => _write(
    ProductTypeLinksEndpoints.sizeGroupLinks,
    query: {'id': 'eq.$id'},
    body: body,
    method: _WriteMethod.patch,
  );

  @override
  Future<ApiResult<Unit>> deleteSizeGroupLink(int id) => _write(
    ProductTypeLinksEndpoints.sizeGroupLinks,
    query: {'id': 'eq.$id'},
    method: _WriteMethod.delete,
  );

  @override
  Future<ApiResult<Unit>> createAttributeLink(Map<String, dynamic> body) =>
      _write(
        ProductTypeLinksEndpoints.attributeLinks,
        body: body,
        method: _WriteMethod.post,
      );

  @override
  Future<ApiResult<Unit>> patchAttributeLink(
    int productTypeId,
    int attributeId,
    Map<String, dynamic> body,
  ) => _write(
    ProductTypeLinksEndpoints.attributeLinks,
    query: {
      'product_type_id': 'eq.$productTypeId',
      'attribute_id': 'eq.$attributeId',
    },
    body: body,
    method: _WriteMethod.patch,
  );

  @override
  Future<ApiResult<Unit>> deleteAttributeLink(
    int productTypeId,
    int attributeId,
  ) => _write(
    ProductTypeLinksEndpoints.attributeLinks,
    query: {
      'product_type_id': 'eq.$productTypeId',
      'attribute_id': 'eq.$attributeId',
    },
    method: _WriteMethod.delete,
  );

  @override
  Future<ApiResult<Unit>> createOptionSetLink(Map<String, dynamic> body) =>
      _write(
        ProductTypeLinksEndpoints.optionSetLinks,
        body: body,
        method: _WriteMethod.post,
      );

  @override
  Future<ApiResult<Unit>> patchOptionSetLink(
    int productTypeId,
    int optionSetId,
    Map<String, dynamic> body,
  ) => _write(
    ProductTypeLinksEndpoints.optionSetLinks,
    query: {
      'product_type_id': 'eq.$productTypeId',
      'option_set_id': 'eq.$optionSetId',
    },
    body: body,
    method: _WriteMethod.patch,
  );

  @override
  Future<ApiResult<Unit>> deleteOptionSetLink(
    int productTypeId,
    int optionSetId,
  ) => _write(
    ProductTypeLinksEndpoints.optionSetLinks,
    query: {
      'product_type_id': 'eq.$productTypeId',
      'option_set_id': 'eq.$optionSetId',
    },
    method: _WriteMethod.delete,
  );

  Future<ApiResult<Unit>> _write(
    AppEndpoint endpoint, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    required _WriteMethod method,
  }) {
    final options = Options(headers: {'Prefer': 'return=minimal'});
    return switch (method) {
      _WriteMethod.post => _apiClient.post<Unit>(
        endpoint,
        data: body,
        options: options,
        fromJson: (_) => unit,
      ),
      _WriteMethod.patch => _apiClient.patch<Unit>(
        endpoint,
        queryParameters: query,
        data: body,
        options: options,
        fromJson: (_) => unit,
      ),
      _WriteMethod.delete => _apiClient.delete(
        endpoint,
        queryParameters: query,
        options: options,
      ),
    };
  }

  @override
  Future<ApiResult<int>> getPublishedProductCount(int productTypeId) async {
    final result = await _apiClient.getPaginated<_CountRow>(
      ProductTypeLinksEndpoints.products,
      fromJson: (json) => _CountRow(json['id'] as int),
      page: 1,
      limit: 1,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': 'id',
        'product_type_id': 'eq.$productTypeId',
        'status': 'eq.published',
      },
    );
    return result.when(
      success: (page) => ApiSuccess(page.totalCount),
      failure: ApiFailure<int>.new,
    );
  }

  ProductTypeLinkOption _option(Map<String, dynamic> json, {String? detail}) =>
      ProductTypeLinkOption(
        id: json['id'] as int,
        name: json['name'] as String,
        code: json['code'] as String,
        isActive: json['is_active'] as bool? ?? true,
        detail: detail,
      );

  ProductTypeSizeGroupLink _sizeGroupLink(Map<String, dynamic> json) {
    final group = _embedded(json['size_groups']);
    final gender = _embedded(json['genders']);
    return ProductTypeSizeGroupLink(
      id: json['id'] as int,
      sizeGroupId: json['size_group_id'] as int,
      sizeGroupName: group['name'] as String? ?? '',
      sizeGroupCode: group['code'] as String? ?? '',
      sizeSystemName: _embeddedName(group['size_systems']),
      genderId: json['gender_id'] as int?,
      genderName: gender['name'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  ProductTypeAttributeLink _attributeLink(Map<String, dynamic> json) {
    final attribute = _embedded(json['attributes']);
    return ProductTypeAttributeLink(
      attributeId: json['attribute_id'] as int,
      name: attribute['name'] as String? ?? '',
      code: attribute['code'] as String? ?? '',
      dataType: attribute['data_type'] as String? ?? '',
      isRequired: json['is_required'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  ProductTypeOptionSetLink _optionSetLink(Map<String, dynamic> json) {
    final optionSet = _embedded(json['option_sets']);
    return ProductTypeOptionSetLink(
      optionSetId: json['option_set_id'] as int,
      name: optionSet['name'] as String? ?? '',
      code: optionSet['code'] as String? ?? '',
      isRequired: json['is_required'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _embedded(dynamic value) =>
      value is Map<String, dynamic> ? value : const {};

  String? _embeddedName(dynamic value) {
    final embedded = _embedded(value);
    return embedded['name'] as String?;
  }
}

enum _WriteMethod { post, patch, delete }

class _CountRow {
  const _CountRow(this.id);

  final int id;
}
