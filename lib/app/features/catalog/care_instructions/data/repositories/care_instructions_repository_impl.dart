import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/datasources/care_instructions_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/models/care_instruction_model.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/failures/care_instruction_failures.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/repositories/care_instructions_repository.dart';

class CareInstructionsRepositoryImpl with RepositoryExecutor implements CareInstructionsRepository {
  const CareInstructionsRepositoryImpl(this._remote);
  final CareInstructionsRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedResult<CareInstruction>>> getCareInstructions(CareInstructionListQuery q) =>
      execute(() async {
        final result = await _remote.getCareInstructions(q);
        return switch (result) {
          ApiSuccess<PaginatedResult<CareInstructionModel>>(:final data) => Right(
            PaginatedResult<CareInstruction>(
              items: data.items.map((item) => item.toEntity()).toList(),
              totalCount: data.totalCount, currentPage: data.currentPage,
              totalPages: data.totalPages, isFromCache: data.isFromCache,
            ),
          ),
          ApiFailure<PaginatedResult<CareInstructionModel>>(:final exception) => Left(ExceptionMapper.map(exception)),
        };
      });

  @override
  Future<Either<Failure, CareInstruction>> createCareInstruction(CareInstructionDraft draft) =>
      execute(() async {
        final result = await _remote.createCareInstruction(draft);
        return switch (result) {
          ApiSuccess<CareInstructionModel>(:final data) => Right(data.toEntity()),
          ApiFailure<CareInstructionModel>(:final exception) => Left(_mapWriteFailure(exception)),
        };
      });

  @override
  Future<Either<Failure, CareInstruction>> updateCareInstruction({required int id, required CareInstructionDraft draft}) =>
      execute(() async {
        final result = await _remote.updateCareInstruction(id: id, draft: draft);
        return switch (result) {
          ApiSuccess<CareInstructionModel>(:final data) => Right(data.toEntity()),
          ApiFailure<CareInstructionModel>(:final exception) => Left(_mapWriteFailure(exception)),
        };
      });

  @override
  Future<Either<Failure, Unit>> deleteCareInstruction(int id) => execute(() async {
    final result = await _remote.deleteCareInstruction(id);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        exception is ApiException && exception.errorCode == '23503'
            ? const CareInstructionInUseFailure()
            : ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> setCareInstructionActive({required int id, required bool isActive}) =>
      execute(() async {
        final result = await _remote.setCareInstructionActive(id: id, isActive: isActive);
        return switch (result) {
          ApiSuccess<Unit>() => const Right(unit),
          ApiFailure<Unit>(:final exception) => Left(ExceptionMapper.map(exception)),
        };
      });

  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == '23505'
          ? const CareInstructionDuplicateFailure()
          : ExceptionMapper.map(exception);
}
