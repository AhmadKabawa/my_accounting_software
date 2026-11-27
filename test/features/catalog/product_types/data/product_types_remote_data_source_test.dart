import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/datasources/product_types_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/repositories/product_types_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/failures/product_type_failures.dart';

void main() {
  late _FakeApiClient api;
  late ProductTypesRemoteDataSourceImpl remote;

  setUp(() {
    api = _FakeApiClient();
    remote = ProductTypesRemoteDataSourceImpl(api);
  });

  test(
    'list query uses server search, fixed order, status and embedded counts',
    () async {
      final result = await remote.getPage(
        const ProductTypeListQuery(
          search: 'shoe',
          status: ProductTypeStatusFilter.active,
        ),
      );

      expect(result, isA<ApiSuccess<PaginatedResult>>());
      expect(api.lastQuery?['order'], 'sort_order.asc,name.asc,id.asc');
      expect(api.lastQuery?['is_active'], 'eq.true');
      expect(api.lastQuery?['or'], '(name.ilike."*shoe*",code.ilike."*shoe*")');
      expect(api.lastQuery?['select'], contains('products(count)'));
      expect(
        api.lastQuery?['select'],
        contains('product_type_option_sets(count)'),
      );

      final page = (result as ApiSuccess<PaginatedResult>).data;
      expect(page.items.single.productCount, 3);
      expect(page.items.single.sizeGroupCount, 0);
      expect(page.items.single.attributeCount, 2);
      expect(page.items.single.optionSetCount, 0);
    },
  );

  test(
    '400 on embedded counts retries without counts and leaves usage unknown',
    () async {
      api.failFirstListWith400 = true;

      final result = await remote.getPage(const ProductTypeListQuery());

      expect(result, isA<ApiSuccess<PaginatedResult>>());
      expect(api.listCalls, 2);
      expect(api.lastQuery?['select'], isNot(contains('products(count)')));
      final page = (result as ApiSuccess<PaginatedResult>).data;
      expect(page.items.single.productCount, isNull);
      expect(page.items.single.sizeGroupCount, isNull);
    },
  );

  test('create trims fields and sends active status explicitly', () async {
    await remote.create(
      const ProductTypeDraft(
        name: '  Shoes  ',
        code: ' SHOE ',
        description: '  Footwear  ',
        sortOrder: 4,
        isActive: true,
      ),
    );

    expect(api.lastBody, {
      'name': 'Shoes',
      'code': 'SHOE',
      'description': 'Footwear',
      'sort_order': 4,
      'is_active': true,
    });
    expect(api.lastOptions?.headers?['Prefer'], 'return=representation');
  });

  test('update omits unchanged is_active from PATCH body', () async {
    await remote.update(
      id: 9,
      draft: const ProductTypeDraft(
        name: 'Shoes',
        code: 'SHOE',
        sortOrder: 0,
        isActive: null,
      ),
    );

    expect(api.lastQuery, {'id': 'eq.9'});
    expect(api.lastBody, {
      'name': 'Shoes',
      'code': 'SHOE',
      'description': null,
      'sort_order': 0,
    });
    expect(api.lastBody, isNot(contains('is_active')));
  });

  test('repository maps duplicate and FK errors to domain failures', () async {
    final repository = ProductTypesRepositoryImpl(remote);
    api.nextWriteFailure = ApiException.conflict(errorCode: '23505');
    final duplicate = await repository.create(
      const ProductTypeDraft(name: 'Shoes', code: 'SHOE'),
    );
    expect(
      duplicate.fold((failure) => failure, (_) => null),
      isA<ProductTypeDuplicateFailure>(),
    );

    api.nextDeleteFailure = ApiException.conflict(errorCode: '23503');
    final inUse = await repository.delete(9);
    expect(
      inUse.fold((failure) => failure, (_) => null),
      isA<ProductTypeInUseFailure>(),
    );
  });
}

class _FakeApiClient implements IApiClient {
  Map<String, dynamic>? lastQuery;
  dynamic lastBody;
  Options? lastOptions;
  int listCalls = 0;
  bool failFirstListWith400 = false;
  ApiException? nextWriteFailure;
  ApiException? nextDeleteFailure;

  final List<Map<String, dynamic>> _rows = [
    {
      'id': 9,
      'name': 'Shoes',
      'code': 'SHOE',
      'description': 'Footwear',
      'sort_order': 4,
      'is_active': true,
      'updated_at': '2026-01-02T03:04:05Z',
      'products': [
        {'count': 3},
      ],
      'product_type_size_groups': [
        {'count': 0},
      ],
      'product_type_attributes': [
        {'count': 2},
      ],
      'product_type_option_sets': [
        {'count': 0},
      ],
      'product_type_care_instructions': [
        {'count': 0},
      ],
    },
  ];

  @override
  Future<ApiResult<PaginatedResult<T>>> getPaginated<T>(
    AppEndpoint path, {
    required JsonFactory<T> fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
    PaginatedParser parser = PaginatedParserPresets.supabase,
    int page = 1,
    int limit = 25,
  }) async {
    listCalls++;
    lastQuery = queryParameters;
    if (failFirstListWith400 && listCalls == 1) {
      return ApiFailure(ApiException.badRequest());
    }
    final includesCounts =
        queryParameters?['select']?.toString().contains('products(count)') ??
        false;
    final rows = includesCounts
        ? _rows
        : _rows.map(
            (row) => Map<String, dynamic>.of(row)
              ..remove('products')
              ..remove('product_type_size_groups')
              ..remove('product_type_attributes')
              ..remove('product_type_option_sets')
              ..remove('product_type_care_instructions'),
          );
    final items = rows.map(fromJson).toList(growable: false);
    return ApiSuccess(
      PaginatedResult<T>(
        items: items,
        totalCount: items.length,
        currentPage: page,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ApiResult<T>> post<T>(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    JsonListFactory<T>? fromJsonList,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    lastBody = data;
    lastOptions = options;
    final failure = nextWriteFailure;
    nextWriteFailure = null;
    if (failure != null) return ApiFailure(failure);
    return ApiSuccess(fromJsonList!(_rows));
  }

  @override
  Future<ApiResult<T>> patch<T>(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    JsonListFactory<T>? fromJsonList,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    lastBody = data;
    lastQuery = queryParameters;
    lastOptions = options;
    return ApiSuccess(fromJsonList!(_rows));
  }

  @override
  Future<ApiResult<Unit>> delete(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    final failure = nextDeleteFailure;
    nextDeleteFailure = null;
    if (failure != null) return ApiFailure(failure);
    return const ApiSuccess(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
