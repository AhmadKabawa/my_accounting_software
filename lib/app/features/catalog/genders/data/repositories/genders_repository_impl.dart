import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/genders/data/datasources/genders_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/genders/data/datasources/gender_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/genders/data/models/gender_model.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_draft.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_list_query.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_stats.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/failures/gender_failures.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/repositories/genders_repository.dart';

class GendersRepositoryImpl
    with RepositoryExecutor
    implements GendersRepository {
  const GendersRepositoryImpl(this._remote, this._stats);
  final GendersRemoteDataSource _remote;
  final GenderStatsRemoteDataSource _stats;
  @override
  Future<Either<Failure, GenderStats>> getGenderStats() => execute(() async {
    final r = await _stats.getGenderStats();
    return switch (r) {
      ApiSuccess<GenderStats>(:final data) => Right(data),
      ApiFailure<GenderStats>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, PaginatedResult<Gender>>> getGenders(
    GenderListQuery q,
  ) => execute(() async {
    final r = await _remote.getGenders(q);
    return switch (r) {
      ApiSuccess<PaginatedResult<GenderModel>>(:final data) => Right(
        PaginatedResult<Gender>(
          items: data.items.map((m) => m.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<GenderModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, Gender>> createGender(GenderDraft d) =>
      execute(() async {
        final r = await _remote.createGender(d);
        return switch (r) {
          ApiSuccess<GenderModel>(:final data) => Right(data.toEntity()),
          ApiFailure<GenderModel>(:final exception) => Left(_write(exception)),
        };
      });
  @override
  Future<Either<Failure, Gender>> updateGender({
    required int id,
    required GenderDraft draft,
  }) => execute(() async {
    final r = await _remote.updateGender(id: id, draft: draft);
    return switch (r) {
      ApiSuccess<GenderModel>(:final data) => Right(data.toEntity()),
      ApiFailure<GenderModel>(:final exception) => Left(_write(exception)),
    };
  });
  @override
  Future<Either<Failure, Unit>> deleteGender(int id) => execute(() async {
    final r = await _remote.deleteGender(id);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(_delete(exception)),
    };
  });
  @override
  Future<Either<Failure, Unit>> setGenderActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final r = await _remote.setGenderActive(id: id, isActive: isActive);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  Failure _delete(AppException e) => e is ApiException && e.errorCode == '23503'
      ? const GenderInUseFailure()
      : ExceptionMapper.map(e);
  Failure _write(AppException e) => e is ApiException && e.errorCode == '23505'
      ? const GenderDuplicateFailure()
      : ExceptionMapper.map(e);
}
