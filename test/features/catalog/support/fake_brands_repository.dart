import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/domain/repositories/brands_repository.dart';

class FakeBrandsRepository implements BrandsRepository {
  final List<BrandListQuery> queries = [];
  final List<int> deletedIds = [];
  Future<Either<Failure, PaginatedResult<Brand>>> Function(BrandListQuery)?
  onGetBrands;

  @override
  Future<Either<Failure, PaginatedResult<Brand>>> getBrands(
    BrandListQuery query,
  ) {
    queries.add(query);
    final handler = onGetBrands;
    if (handler != null) return handler(query);
    return Future.value(Right(_page()));
  }

  @override
  Future<Either<Failure, Brand>> createBrand(BrandDraft draft) =>
      Future.value(Right(_brand));

  @override
  Future<Either<Failure, Brand>> updateBrand({
    required int id,
    required BrandDraft draft,
  }) => Future.value(Right(_brand));

  @override
  Future<Either<Failure, Unit>> setBrandActive({
    required int id,
    required bool isActive,
  }) => Future.value(const Right(unit));

  @override
  Future<Either<Failure, Unit>> deleteBrand(int id) {
    deletedIds.add(id);
    return Future.value(const Right(unit));
  }

  static const _brand = Brand(
    id: 12,
    name: 'Northwind',
    slug: 'northwind',
    isActive: true,
    productCount: 0,
  );

  static PaginatedResult<Brand> _page() => const PaginatedResult<Brand>(
    items: [_brand],
    totalCount: 1,
    currentPage: 1,
    totalPages: 1,
  );
}
