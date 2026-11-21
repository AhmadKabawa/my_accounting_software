import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/repositories/brands_repository.dart';

class GetBrandsUseCase extends UseCase<PaginatedResult<Brand>, BrandListQuery> {
  GetBrandsUseCase(this._repository);
  final BrandsRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<Brand>>> call(BrandListQuery params) =>
      _repository.getBrands(params);
}
