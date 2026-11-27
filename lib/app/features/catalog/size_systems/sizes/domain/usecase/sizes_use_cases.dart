import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/repositories/sizes_repository.dart';

class GetSizesUseCase
    extends UseCase<PaginatedResult<CatalogSize>, CatalogSizeListQuery> {
  GetSizesUseCase(this._repository);
  final SizesRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<CatalogSize>>> call(
    CatalogSizeListQuery params,
  ) => _repository.getSizes(params);
}

class CreateSizeUseCase extends UseCase<CatalogSize, CatalogSizeDraft> {
  CreateSizeUseCase(this._repository);
  final SizesRepository _repository;

  @override
  Future<Either<Failure, CatalogSize>> call(CatalogSizeDraft params) =>
      _repository.createSize(params);
}

class CreateSizesBatchUseCase
    extends UseCase<List<CatalogSize>, List<CatalogSizeDraft>> {
  CreateSizesBatchUseCase(this._repository);
  final SizesRepository _repository;

  @override
  Future<Either<Failure, List<CatalogSize>>> call(
    List<CatalogSizeDraft> params,
  ) => _repository.createSizes(params);
}

class UpdateSizeParams extends Equatable {
  const UpdateSizeParams({required this.id, required this.draft});
  final int id;
  final CatalogSizeDraft draft;

  @override
  List<Object?> get props => [id, draft];
}

class UpdateSizeUseCase extends UseCase<CatalogSize, UpdateSizeParams> {
  UpdateSizeUseCase(this._repository);
  final SizesRepository _repository;

  @override
  Future<Either<Failure, CatalogSize>> call(UpdateSizeParams params) =>
      _repository.updateSize(id: params.id, draft: params.draft);
}

class DeleteSizeUseCase extends UseCase<Unit, int> {
  DeleteSizeUseCase(this._repository);
  final SizesRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int params) =>
      _repository.deleteSize(params);
}

class SetSizeActiveParams extends Equatable {
  const SetSizeActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class SetSizeActiveUseCase extends UseCase<Unit, SetSizeActiveParams> {
  SetSizeActiveUseCase(this._repository);
  final SizesRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetSizeActiveParams params) =>
      _repository.setSizeActive(id: params.id, isActive: params.isActive);
}
