import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/models/care_instruction_model.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';

abstract interface class CareInstructionsRemoteDataSource {
  Future<ApiResult<PaginatedResult<CareInstructionModel>>> getCareInstructions(
    CareInstructionListQuery query,
  );
  Future<ApiResult<CareInstructionModel>> createCareInstruction(
    CareInstructionDraft draft,
  );
  Future<ApiResult<CareInstructionModel>> updateCareInstruction({
    required int id,
    required CareInstructionDraft draft,
  });
  Future<ApiResult<Unit>> deleteCareInstruction(int id);
  Future<ApiResult<Unit>> setCareInstructionActive({
    required int id,
    required bool isActive,
  });
}
