import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/repositories/brands_repository.dart';

class UpdateBrandParams extends Equatable {
  const UpdateBrandParams({required this.id, required this.draft});
  final int id;
  final BrandDraft draft;

  @override
  List<Object?> get props => [id, draft];
}

class UpdateBrandUseCase extends UseCase<Brand, UpdateBrandParams> {
  UpdateBrandUseCase(this._repository);
  final BrandsRepository _repository;

  @override
  Future<Either<Failure, Brand>> call(UpdateBrandParams params) =>
      _repository.updateBrand(id: params.id, draft: params.draft);
}
