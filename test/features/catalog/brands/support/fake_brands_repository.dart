import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_logo_upload.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/repositories/brands_repository.dart';

class FakeBrandsRepository implements BrandsRepository {
  final List<BrandListQuery> queries = [];
  final List<int> deletedIds = [];
  Future<Either<Failure, PaginatedResult<Brand>>> Function(BrandListQuery)?
  onGetBrands;
  Future<Either<Failure, BrandStats>> Function()? onGetBrandStats;
  Future<Either<Failure, Brand>> Function(BrandDraft)? onCreateBrand;
  Future<Either<Failure, Brand>> Function(int, BrandDraft)? onUpdateBrand;
  Either<Failure, Unit> statusMutationResult = const Right(unit);

  @override
  Future<Either<Failure, PaginatedResult<Brand>>> getBrands(
    BrandListQuery query,
  ) {
    queries.add(query);
    final handler = onGetBrands;
    if (handler != null) return handler(query);
    return Future.value(Right(_page(query: query)));
  }

  @override
  Future<Either<Failure, BrandStats>> getBrandStats() {
    final handler = onGetBrandStats;
    if (handler != null) return handler();
    return Future.value(
      const Right(BrandStats(total: 1, active: 1, inactive: 0)),
    );
  }

  @override
  Future<Either<Failure, Brand>> createBrand(BrandDraft draft) {
    final handler = onCreateBrand;
    if (handler != null) return handler(draft);
    return Future.value(Right(brand));
  }

  @override
  Future<Either<Failure, Brand>> updateBrand({
    required int id,
    required BrandDraft draft,
  }) {
    final handler = onUpdateBrand;
    if (handler != null) return handler(id, draft);
    return Future.value(Right(brand));
  }

  @override
  Future<Either<Failure, Unit>> setBrandActive({
    required int id,
    required bool isActive,
  }) => Future.value(setActiveResult);

  @override
  Future<Either<Failure, Unit>> deleteBrand(int id) {
    deletedIds.add(id);
    return Future.value(const Right(unit));
  }

  BrandLogoUpload? lastUpload;
  Either<Failure, String> uploadResult = const Right(
    'https://cdn.test/logo.png',
  );

  @override
  Future<Either<Failure, String>> uploadLogo(BrandLogoUpload upload) {
    lastUpload = upload;
    return Future.value(uploadResult);
  }

  static const brand = Brand(
    id: 12,
    name: 'Northwind',
    slug: 'northwind',
    isActive: true,
    productCount: 0,
  );

  static PaginatedResult<Brand> _page({BrandListQuery? query}) =>
      PaginatedResult<Brand>(
        items: const [brand],
        totalCount: 1,
        currentPage: query?.page ?? 1,
        totalPages: 1,
      );
}
