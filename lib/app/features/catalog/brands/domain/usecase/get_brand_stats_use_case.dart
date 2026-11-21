import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/repositories/brands_repository.dart';

/// Retrieves brand totals through the repository's dedicated stats operation.
class GetBrandStatsUseCase extends UseCase<BrandStats, NoParams> {
  GetBrandStatsUseCase(this._repository);

  final BrandsRepository _repository;

  @override
  Future<Either<Failure, BrandStats>> call(NoParams params) =>
      _repository.getStats();
}
