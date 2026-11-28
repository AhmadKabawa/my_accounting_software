import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/repositories/care_instructions_repository.dart';

class DeleteCareInstructionParams {
  const DeleteCareInstructionParams(this.id);
  final int id;
}

class DeleteCareInstructionUseCase extends UseCase<Unit, DeleteCareInstructionParams> {
  DeleteCareInstructionUseCase(this._repository);
  final CareInstructionsRepository _repository;
  @override
  Future<Either<Failure, Unit>> call(DeleteCareInstructionParams params) =>
      _repository.deleteCareInstruction(params.id);
}
