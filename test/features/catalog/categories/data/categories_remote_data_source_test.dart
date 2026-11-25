import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/features/catalog/categories/data/categories_endpoint.dart';
import 'package:accounting_software/app/features/catalog/categories/data/datasources/categories_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/categories/data/models/category_model.dart';

class _ApiClient extends Fake implements IApiClient {
  int calls = 0;
  final List<Map<String, dynamic>> queries = [];
  ApiException? firstFailure;

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
    int limit = 20,
  }) async {
    calls++;
    queries.add(Map<String, dynamic>.of(queryParameters ?? {}));
    if (calls == 1 && firstFailure != null) {
      return ApiFailure<PaginatedResult<T>>(firstFailure!);
    }
    final item = fromJson({
      'id': 1,
      'name': 'Shoes',
      'slug': 'shoes',
      'sort_order': 0,
      'is_active': true,
    });
    return ApiSuccess(
      PaginatedResult<T>(
        items: [item],
        totalCount: 1,
        currentPage: page,
        totalPages: 1,
      ),
    );
  }
}

void main() {
  test(
    'falls back to the base projection when embedded count is rejected',
    () async {
      final api = _ApiClient()..firstFailure = ApiException.badRequest();
      final source = CategoriesRemoteDataSourceImpl(api);

      final result = await source.getPage(page: 1, limit: 1000);

      expect(result, isA<ApiSuccess<PaginatedResult<CategoryModel>>>());
      expect(api.calls, 2);
      expect(api.queries.first['select'], CategoriesEndpoint.select);
      expect(
        api.queries.last['select'],
        CategoriesEndpoint.selectWithoutProductCount,
      );
      final page = (result as ApiSuccess<PaginatedResult<CategoryModel>>).data;
      expect(page.items.single.productCount, isNull);
    },
  );

  test(
    'does not retry permission or connectivity failures without the embed',
    () async {
      final api = _ApiClient()..firstFailure = ApiException.forbidden();
      final source = CategoriesRemoteDataSourceImpl(api);

      final result = await source.getPage(page: 1, limit: 1000);

      expect(result, isA<ApiFailure<PaginatedResult<CategoryModel>>>());
      expect(api.calls, 1);
    },
  );
}
