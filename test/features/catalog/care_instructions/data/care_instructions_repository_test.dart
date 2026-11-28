import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/datasources/care_instructions_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/models/care_instruction_model.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/repositories/care_instructions_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/failures/care_instruction_failures.dart';

class _Remote implements CareInstructionsRemoteDataSource {
  ApiResult<CareInstructionModel> createResult = const ApiSuccess(
    CareInstructionModel(id: 1, name: 'Wash cold', code: 'WASH', careType: CareType.washing, isActive: true),
  );
  ApiResult<Unit> deleteResult = const ApiSuccess(unit);
  @override
  Future<ApiResult<PaginatedResult<CareInstructionModel>>> getCareInstructions(CareInstructionListQuery query) async =>
      const ApiSuccess(PaginatedResult(items: [], totalCount: 0, currentPage: 1, totalPages: 0));
  @override
  Future<ApiResult<CareInstructionModel>> createCareInstruction(CareInstructionDraft draft) async => createResult;
  @override
  Future<ApiResult<CareInstructionModel>> updateCareInstruction({required int id, required CareInstructionDraft draft}) async => createResult;
  @override
  Future<ApiResult<Unit>> deleteCareInstruction(int id) async => deleteResult;
  @override
  Future<ApiResult<Unit>> setCareInstructionActive({required int id, required bool isActive}) async => const ApiSuccess(unit);
}

void main() {
  test('maps unique violation to one duplicate failure', () async {
    final remote = _Remote()..createResult = ApiFailure(ApiException.conflict(errorCode: '23505'));
    final result = await CareInstructionsRepositoryImpl(remote).createCareInstruction(
      const CareInstructionDraft(name: 'Wash', code: 'WASH', careType: CareType.washing),
    );
    expect(result.fold((failure) => failure, (_) => null), isA<CareInstructionDuplicateFailure>());
  });

  test('maps FK usage rejection to in-use failure', () async {
    final remote = _Remote()..deleteResult = ApiFailure(ApiException.conflict(errorCode: '23503'));
    final result = await CareInstructionsRepositoryImpl(remote).deleteCareInstruction(1);
    expect(result.fold((failure) => failure, (_) => null), isA<CareInstructionInUseFailure>());
  });
}
