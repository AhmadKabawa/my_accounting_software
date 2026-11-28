import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/repositories/care_instructions_repository.dart';

class GetCareInstructionsUseCase extends UseCase<PaginatedResult<CareInstruction>, CareInstructionListQuery> {
  GetCareInstructionsUseCase(this._repository);
  final CareInstructionsRepository _repository;
  @override
  Future<Either<Failure, PaginatedResult<CareInstruction>>> call(CareInstructionListQuery query) =>
      _repository.getCareInstructions(query);
}
