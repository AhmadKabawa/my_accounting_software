import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/sports/data/datasources/sports_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/sports/data/datasources/sport_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/sports/data/models/sport_model.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_stats.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_list_query.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/failures/sport_failures.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/repositories/sports_repository.dart';

class SportsRepositoryImpl with RepositoryExecutor implements SportsRepository {
  const SportsRepositoryImpl(this._remote, this._statsRemote);
  final SportsRemoteDataSource _remote;
  final SportStatsRemoteDataSource _statsRemote;

  /// SQLSTATE of a UNIQUE violation (`sports.code`).
  static const _uniqueViolation = '23505';

  @override
  Future<Either<Failure, SportStats>> getSportStats() => execute(() async {
    final result = await _statsRemote.getSportStats();
    return switch (result) {
      ApiSuccess<SportStats>(:final data) => Right(data),
      ApiFailure<SportStats>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> deleteSport(int id) => execute(() async {
    final result = await _remote.deleteSport(id);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(_mapDeleteFailure(exception)),
    };
  });

  @override
  Future<Either<Failure, PaginatedResult<Sport>>> getSports(
    SportListQuery query,
  ) => execute(() async {
    final result = await _remote.getSports(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<SportModel>>(:final data) => Right(
        PaginatedResult<Sport>(
          items: data.items.map((model) => model.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<SportModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Sport>> createSport(SportDraft draft) =>
      execute(() async {
        final result = await _remote.createSport(draft);
        return switch (result) {
          ApiSuccess<SportModel>(:final data) => Right(data.toEntity()),
          ApiFailure<SportModel>(:final exception) => Left(
            _mapWriteFailure(exception),
          ),
        };
      });

  @override
  Future<Either<Failure, Sport>> updateSport({
    required int id,
    required SportDraft draft,
  }) => execute(() async {
    final result = await _remote.updateSport(id: id, draft: draft);
    return switch (result) {
      ApiSuccess<SportModel>(:final data) => Right(data.toEntity()),
      ApiFailure<SportModel>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> setSportActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final result = await _remote.setSportActive(id: id, isActive: isActive);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  Failure _mapDeleteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == '23503'
      ? const SportInUseFailure()
      : ExceptionMapper.map(exception);

  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == _uniqueViolation
      ? const SportDuplicateFailure()
      : ExceptionMapper.map(exception);
}
