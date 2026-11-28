import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/repositories/care_instructions_repository.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/create_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/update_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instruction_form_cubit.dart';

class _Repository implements CareInstructionsRepository {
  @override
  Future<Either<Failure, CareInstruction>> createCareInstruction(CareInstructionDraft draft) async =>
      Right(CareInstruction(id: 1, name: draft.name, code: draft.code, careType: draft.careType, isActive: draft.isActive ?? true));
  @override
  Future<Either<Failure, CareInstruction>> updateCareInstruction({required int id, required CareInstructionDraft draft}) async =>
      Right(CareInstruction(id: id, name: draft.name, code: draft.code, careType: draft.careType, isActive: draft.isActive ?? true));
  @override
  Future<Either<Failure, Unit>> deleteCareInstruction(int id) async => const Right(unit);
  @override
  Future<Either<Failure, PaginatedResult<CareInstruction>>> getCareInstructions(CareInstructionListQuery query) async =>
      const Right(PaginatedResult(items: [], totalCount: 0, currentPage: 1, totalPages: 0));
  @override
  Future<Either<Failure, Unit>> setCareInstructionActive({required int id, required bool isActive}) async => const Right(unit);
}

void main() {
  test('successful save returns to idle and posts one flash message', () async {
    final repository = _Repository();
    final flash = FlashMessages();
    final cubit = CareInstructionFormCubit(
      create: CreateCareInstructionUseCase(repository),
      update: UpdateCareInstructionUseCase(repository),
      flashMessages: flash,
    );
    await cubit.save(draft: const CareInstructionDraft(
      name: 'Wash cold', code: 'WASH', careType: CareType.washing,
    ));
    expect(cubit.state, isA<CareInstructionFormIdle>());
    expect(flash.pendingCount, 1);
    await cubit.close();
  });
}
