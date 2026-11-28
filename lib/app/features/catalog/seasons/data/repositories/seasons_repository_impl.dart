import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/failures/season_failures.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/datasources/seasons_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/models/season_model.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_draft.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_list_query.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/repositories/seasons_repository.dart';

class SeasonsRepositoryImpl
    with RepositoryExecutor
    implements SeasonsRepository {
  const SeasonsRepositoryImpl(this._remote);
  final SeasonsRemoteDataSource _remote;
  @override
  Future<Either<Failure, PaginatedResult<CatalogSeason>>> getSeasons(
    SeasonListQuery q,
  ) => execute(() async {
    final r = await _remote.getSeasons(q);
    return switch (r) {
      ApiSuccess<PaginatedResult<SeasonModel>>(:final data) => Right(
        PaginatedResult<CatalogSeason>(
          items: data.items.map((e) => e.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<SeasonModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, CatalogSeason>> createSeason(SeasonDraft d) =>
      execute(() async {
        final r = await _remote.createSeason(d);
        return switch (r) {
          ApiSuccess<SeasonModel>(:final data) => Right(data.toEntity()),
          ApiFailure<SeasonModel>(:final exception) => Left(
            _mapWriteFailure(exception),
          ),
        };
      });
  @override
  Future<Either<Failure, CatalogSeason>> updateSeason({
    required int id,
    required SeasonDraft draft,
  }) => execute(() async {
    final r = await _remote.updateSeason(id: id, draft: draft);
    return switch (r) {
      ApiSuccess<SeasonModel>(:final data) => Right(data.toEntity()),
      ApiFailure<SeasonModel>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, Unit>> deleteSeason(int id) => execute(() async {
    final r = await _remote.deleteSeason(id);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        exception is ApiException && exception.errorCode == '23503'
            ? const SeasonInUseFailure()
            : ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, Unit>> setSeasonActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final r = await _remote.setSeasonActive(id: id, isActive: isActive);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == '23505'
      ? const SeasonDuplicateFailure()
      : ExceptionMapper.map(exception);
}
