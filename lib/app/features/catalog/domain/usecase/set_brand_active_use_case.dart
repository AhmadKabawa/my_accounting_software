import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/repositories/brands_repository.dart';

class SetBrandActiveParams extends Equatable {
  const SetBrandActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class SetBrandActiveUseCase extends UseCase<Unit, SetBrandActiveParams> {
  const SetBrandActiveUseCase(this._repository);
  final BrandsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetBrandActiveParams params) =>
      _repository.setBrandActive(id: params.id, isActive: params.isActive);
}
