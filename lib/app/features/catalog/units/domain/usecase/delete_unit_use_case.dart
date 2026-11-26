import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/repositories/units_repository.dart';

class DeleteUnitUseCase extends UseCase<Unit, int> {
  DeleteUnitUseCase(this._repository);
  final UnitsRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(int params) =>
      _repository.deleteUnit(params);
}
