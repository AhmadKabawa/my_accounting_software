import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_logo_upload.dart';
import 'package:accounting_software/app/features/catalog/domain/repositories/brands_repository.dart';

/// Uploads a logo file and returns its public URL (to be stored in `brands.logo`).
class UploadBrandLogoUseCase extends UseCase<String, BrandLogoUpload> {
  UploadBrandLogoUseCase(this._repository);
  final BrandsRepository _repository;

  @override
  Future<Either<Failure, String>> call(BrandLogoUpload upload) =>
      _repository.uploadLogo(upload);
}
