import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/repositories/units_repository.dart';

class SetUnitActiveParams {
  const SetUnitActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;
}

class SetUnitActiveUseCase extends UseCase<Unit, SetUnitActiveParams> {
  SetUnitActiveUseCase(this._repository);
  final UnitsRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(SetUnitActiveParams params) =>
      _repository.setUnitActive(id: params.id, isActive: params.isActive);
}
