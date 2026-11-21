import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/repositories/brands_repository.dart';

/// Loads catalog-wide brand counts independently from the active list filters.
class GetBrandStatsUseCase extends UseCase<BrandStats, NoParams> {
  GetBrandStatsUseCase(this._repository);

  final BrandsRepository _repository;

  @override
  Future<Either<Failure, BrandStats>> call(NoParams params) async {
    final results = await Future.wait([
      _repository.getBrands(const BrandListQuery(page: 1, pageSize: 1)),
      _repository.getBrands(
        const BrandListQuery(
          status: BrandStatusFilter.active,
          page: 1,
          pageSize: 1,
        ),
      ),
    ]);

    Failure? failure;
    int? total;
    int? active;
    results[0].fold(
      (value) => failure = value,
      (page) => total = page.totalCount,
    );
    results[1].fold(
      (value) => failure ??= value,
      (page) => active = page.totalCount,
    );

    if (failure != null) return Left(failure!);

    final totalCount = total!;
    final activeCount = active!;
    return Right(
      BrandStats(
        total: totalCount,
        active: activeCount,
        inactive: totalCount - activeCount,
      ),
    );
  }
}
