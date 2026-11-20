import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/domain/entities/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entities/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/domain/entities/brand_list_query.dart';

abstract interface class BrandsRepository {
  Future<Either<Failure, PaginatedResult<Brand>>> getBrands(
    BrandListQuery query,
  );

  Future<Either<Failure, Brand>> createBrand(BrandDraft draft);

  Future<Either<Failure, Brand>> updateBrand({
    required int id,
    required BrandDraft draft,
  });

  Future<Either<Failure, Unit>> setBrandActive({
    required int id,
    required bool isActive,
  });

  Future<Either<Failure, Unit>> deleteBrand(int id);
}
