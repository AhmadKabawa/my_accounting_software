import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/brands/data/brands_endpoint.dart';
import 'package:accounting_software/app/features/catalog/brands/data/datasources/brands_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/brands/data/models/brand_model.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_logo_upload.dart';

class BrandsRemoteDataSourceImpl implements BrandsRemoteDataSource {
  const BrandsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  @override
  Future<ApiResult<PaginatedResult<BrandModel>>> getBrands(
    BrandListQuery query,
  ) {
    final searchTerm = _escapeFilterValue(query.search.trim());
    return _apiClient.getPaginated<BrandModel>(
      BrandsEndpoint.collection,
      fromJson: BrandModel.fromJson,
      page: query.page,
      limit: query.pageSize,
      parser: PaginatedParserPresets.supabase,
      queryParameters: {
        'select': BrandsEndpoint.selectWithProductCount,
        'order': _order(query),
        if (searchTerm.isNotEmpty)
          'or': '(name.ilike."*$searchTerm*",slug.ilike."*$searchTerm*")',
        if (query.status == BrandStatusFilter.active) 'is_active': 'eq.true',
        if (query.status == BrandStatusFilter.inactive) 'is_active': 'eq.false',
      },
    );
  }

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

  @override
  Future<ApiResult<String>> uploadLogo(BrandLogoUpload upload) {
    final extension = _fileExtension(upload);
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final path =
        '${BrandsEndpoint.logoFolder}/$stamp-${Random().nextInt(0x7fffffff)}.$extension';
    return _apiClient.post<String>(
      BrandsEndpoint.logoUpload(path),
      data: upload.bytes,
      options: Options(
        headers: {
          'Content-Type': upload.normalizedMimeType,
          'x-upsert': 'false',
        },
      ),
      fromJson: (_) => BrandsEndpoint.logoPublicUrl(AppConfig.baseUrl, path),
    );
  }

  /// Sorting is done by the database: every criterion becomes one `order`
  /// term. `id.asc` is appended unless `id` is already sorted, so equal values
  /// keep a stable order across pages.
  String _order(BrandListQuery query) {
    final terms = [
      for (final sort in query.sorts)
        '${sort.field.column}.${sort.ascending ? 'asc' : 'desc'}',
    ];
    final hasId = query.sorts.any((s) => s.field == BrandSortField.newest);
    return [...terms, if (!hasId) 'id.asc'].join(',');
  }

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
    if (draft.isActive != null) 'is_active': draft.isActive,
  };

  String? _nullableTrim(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  String _fileExtension(BrandLogoUpload upload) =>
      switch (upload.mimeType.toLowerCase()) {
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
        _ => 'img',
      };

  String _escapeFilterValue(String value) =>
      value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
}
