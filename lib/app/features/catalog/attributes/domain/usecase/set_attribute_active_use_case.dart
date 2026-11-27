import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';

class SetAttributeActiveParams {
  const SetAttributeActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;
}

class SetAttributeActiveUseCase
    extends UseCase<Unit, SetAttributeActiveParams> {
  SetAttributeActiveUseCase(this._repository);
  final AttributesRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetAttributeActiveParams params) =>
      _repository.setAttributeActive(id: params.id, isActive: params.isActive);
}
