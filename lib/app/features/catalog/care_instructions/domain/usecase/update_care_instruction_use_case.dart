import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/repositories/care_instructions_repository.dart';

class UpdateCareInstructionParams {
  const UpdateCareInstructionParams(this.id, this.draft);
  final int id;
  final CareInstructionDraft draft;
}

class UpdateCareInstructionUseCase
    extends UseCase<CareInstruction, UpdateCareInstructionParams> {
  UpdateCareInstructionUseCase(this._repository);
  final CareInstructionsRepository _repository;
  @override
  Future<Either<Failure, CareInstruction>> call(
    UpdateCareInstructionParams params,
  ) => _repository.updateCareInstruction(id: params.id, draft: params.draft);
}
