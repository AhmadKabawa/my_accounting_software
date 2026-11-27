import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/datasources/age_groups_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/models/age_group_model.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_draft.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/failures/age_group_failures.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/repositories/age_groups_repository.dart';

class AgeGroupsRepositoryImpl
    with RepositoryExecutor
    implements AgeGroupsRepository {
  const AgeGroupsRepositoryImpl(this._remote);
  final AgeGroupsRemoteDataSource _remote;
  @override
  Future<Either<Failure, PaginatedResult<AgeGroup>>> getAgeGroups(
    AgeGroupListQuery q,
  ) => execute(() async {
    final r = await _remote.getAgeGroups(q);
    return switch (r) {
      ApiSuccess<PaginatedResult<AgeGroupModel>>(:final data) => Right(
        PaginatedResult<AgeGroup>(
          items: data.items.map((m) => m.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<AgeGroupModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, AgeGroup>> createAgeGroup(AgeGroupDraft d) => execute(
    () async {
      final r = await _remote.createAgeGroup(d);
      return switch (r) {
        ApiSuccess<AgeGroupModel>(:final data) => Right(data.toEntity()),
        ApiFailure<AgeGroupModel>(:final exception) => Left(_write(exception)),
      };
    },
  );
  @override
  Future<Either<Failure, AgeGroup>> updateAgeGroup({
    required int id,
    required AgeGroupDraft draft,
  }) => execute(() async {
    final r = await _remote.updateAgeGroup(id: id, draft: draft);
    return switch (r) {
      ApiSuccess<AgeGroupModel>(:final data) => Right(data.toEntity()),
      ApiFailure<AgeGroupModel>(:final exception) => Left(_write(exception)),
    };
  });
  @override
  Future<Either<Failure, Unit>> deleteAgeGroup(int id) => execute(() async {
    final r = await _remote.deleteAgeGroup(id);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(_delete(exception)),
    };
  });
  @override
  Future<Either<Failure, Unit>> setAgeGroupActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final r = await _remote.setAgeGroupActive(id: id, isActive: isActive);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  Failure _write(AppException e) {
    if (e is! ApiException) return ExceptionMapper.map(e);
    return switch (e.errorCode) {
      '23505' => const AgeGroupDuplicateFailure(),
      '23514' => const AgeGroupInvalidRangeFailure(),
      _ => ExceptionMapper.map(e),
    };
  }

  Failure _delete(AppException e) => e is ApiException && e.errorCode == '23503'
      ? const AgeGroupInUseFailure()
      : ExceptionMapper.map(e);
}
