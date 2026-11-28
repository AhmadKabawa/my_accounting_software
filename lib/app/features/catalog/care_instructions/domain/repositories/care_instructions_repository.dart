import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';

abstract interface class CareInstructionsRepository {
  Future<Either<Failure, PaginatedResult<CareInstruction>>> getCareInstructions(
    CareInstructionListQuery query,
  );
  Future<Either<Failure, CareInstruction>> createCareInstruction(
    CareInstructionDraft draft,
  );
  Future<Either<Failure, CareInstruction>> updateCareInstruction({
    required int id,
    required CareInstructionDraft draft,
  });
  Future<Either<Failure, Unit>> deleteCareInstruction(int id);
  Future<Either<Failure, Unit>> setCareInstructionActive({
    required int id,
    required bool isActive,
  });
}
