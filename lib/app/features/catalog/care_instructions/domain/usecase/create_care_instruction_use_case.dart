import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/repositories/care_instructions_repository.dart';

class CreateCareInstructionUseCase
    extends UseCase<CareInstruction, CareInstructionDraft> {
  CreateCareInstructionUseCase(this._repository);
  final CareInstructionsRepository _repository;
  @override
  Future<Either<Failure, CareInstruction>> call(CareInstructionDraft draft) =>
      _repository.createCareInstruction(draft);
}
