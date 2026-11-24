import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';

abstract interface class BrandsRepository {
  Future<Either<Failure, PaginatedResult<Brand>>> getBrands(
    BrandListQuery query,
  );

  Future<Either<Failure, BrandStats>> getBrandStats();

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

  /// Uploads a logo and returns its public URL.
  Future<Either<Failure, String>> uploadLogo(ImageUpload upload);
}
