import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/repositories/brands_repository.dart';

class CreateBrandUseCase extends UseCase<Brand, BrandDraft> {
  CreateBrandUseCase(this._repository);
  final BrandsRepository _repository;

  @override
  Future<Either<Failure, Brand>> call(BrandDraft params) =>
      _repository.createBrand(params);
}
