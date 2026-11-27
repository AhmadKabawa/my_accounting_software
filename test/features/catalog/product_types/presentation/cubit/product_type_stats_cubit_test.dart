import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_stats/product_type_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_stats/product_type_stats_state.dart';

void main() {
  test('unused count includes all pages and only known zero-product types', () async {
    final repository = _StatsRepository({
      1: [_type(1, products: 0), _type(2, products: 4)],
      2: [_type(3, products: 0)],
    }, totalPages: 2);
    final cubit = ProductTypeStatsCubit(repository: repository);

    await cubit.load();

    final stats = (cubit.state as ProductTypeStatsLoaded).value;
    expect(stats.total, 3);
    expect(stats.unused, 2);
    expect(repository.queries.map((query) => query.page), [1, 2]);
    await cubit.close();
  });

  test('unused count is unknown if any product count is unknown', () async {
    final repository = _StatsRepository({
      1: [_type(1, products: 0), _type(2, products: null)],
    }, totalPages: 1);
    final cubit = ProductTypeStatsCubit(repository: repository);

    await cubit.load();

    final stats = (cubit.state as ProductTypeStatsLoaded).value;
    expect(stats.unused, isNull);
    await cubit.close();
  });
}

ProductType _type(int id, {int? products}) => ProductType(
  id: id,
  name: 'Type $id',
  code: 'TYPE$id',
  sortOrder: id,
  isActive: true,
  productCount: products,
  sizeGroupCount: 0,
  attributeCount: 0,
  optionSetCount: 0,
  careInstructionCount: 0,
);

class _StatsRepository implements ProductTypesRepository {
  _StatsRepository(this.pages, {required this.totalPages});
  final Map<int, List<ProductType>> pages;
  final int totalPages;
  final List<ProductTypeListQuery> queries = [];

  @override
  Future<Either<Failure, PaginatedResult<ProductType>>> getPage(
    ProductTypeListQuery query,
  ) async {
    queries.add(query);
    return Right(
      PaginatedResult(
        items: pages[query.page] ?? const [],
        totalCount: 3,
        currentPage: query.page,
        totalPages: totalPages,
      ),
    );
  }

  @override
  Future<Either<Failure, ProductType>> getById(int id) async =>
      Right(_type(id));

  @override
  Future<Either<Failure, ProductType>> create(ProductTypeDraft draft) async =>
      Right(_type(1));

  @override
  Future<Either<Failure, ProductType>> update({
    required int id,
    required ProductTypeDraft draft,
  }) async => Right(_type(id));

  @override
  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> delete(int id) async => const Right(unit);
}
