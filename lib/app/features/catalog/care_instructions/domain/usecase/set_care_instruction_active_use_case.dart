import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/repositories/care_instructions_repository.dart';

class SetCareInstructionActiveParams {
  const SetCareInstructionActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;
}

class SetCareInstructionActiveUseCase extends UseCase<Unit, SetCareInstructionActiveParams> {
  SetCareInstructionActiveUseCase(this._repository);
  final CareInstructionsRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(SetCareInstructionActiveParams params) =>
      _repository.setCareInstructionActive(id: params.id, isActive: params.isActive);
}
