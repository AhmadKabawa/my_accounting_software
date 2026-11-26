import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/units/data/datasources/units_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/units/data/datasources/unit_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/units/data/models/unit_model.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_draft.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_stats.dart';
import 'package:accounting_software/app/features/catalog/units/domain/failures/unit_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/units/domain/repositories/units_repository.dart';

class UnitsRepositoryImpl with RepositoryExecutor implements UnitsRepository {
  const UnitsRepositoryImpl(this._remote, this._statsRemote);
  final UnitsRemoteDataSource _remote;
  final UnitStatsRemoteDataSource _statsRemote;

  @override
  Future<Either<Failure, UnitStats>> getUnitStats() => execute(() async {
    final result = await _statsRemote.getUnitStats();
    return switch (result) {
      ApiSuccess<UnitStats>(:final data) => Right(data),
      ApiFailure<UnitStats>(:final exception) => Left(ExceptionMapper.map(exception)),
    };
  });

  @override
  Future<Either<Failure, PaginatedResult<CatalogUnit>>> getUnits(
    UnitListQuery query,
  ) => execute(() async {
    final result = await _remote.getUnits(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<UnitModel>>(:final data) => Right(
        PaginatedResult<CatalogUnit>(
          items: data.items.map((item) => item.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<UnitModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, CatalogUnit>> createUnit(UnitDraft draft) =>
      _write(() => _remote.createUnit(draft));

  @override
  Future<Either<Failure, CatalogUnit>> updateUnit({
    required int id,
    required UnitDraft draft,
  }) => _write(() => _remote.updateUnit(id: id, draft: draft));

  Future<Either<Failure, CatalogUnit>> _write(
    Future<ApiResult<UnitModel>> Function() request,
  ) => execute(() async {
    final result = await request();
    return switch (result) {
      ApiSuccess<UnitModel>(:final data) => Right(data.toEntity()),
      ApiFailure<UnitModel>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });

  Failure _mapWriteFailure(AppException exception) {
    if (exception is ApiException &&
        (exception.errorCode == '23505' || exception.statusCode == 409)) {
      return ValidationFailure(
        messageKey: UnitFailureKeys.duplicateSymbol,
        statusCode: exception.statusCode,
      );
    }
    return ExceptionMapper.map(exception);
  }

  Failure _mapDeleteFailure(AppException exception) {
    if (exception is ApiException && exception.errorCode == '23503') {
      return ValidationFailure(
        messageKey: UnitFailureKeys.inUse,
        statusCode: exception.statusCode,
      );
    }
    return ExceptionMapper.map(exception);
  }

  @override
  Future<Either<Failure, Unit>> setUnitActive({
    required int id,
    required bool isActive,
  }) => _unitResult(() => _remote.setUnitActive(id: id, isActive: isActive));

  @override
  Future<Either<Failure, Unit>> deleteUnit(int id) =>
      _unitResult(() => _remote.deleteUnit(id), mapFailure: _mapDeleteFailure);

  Future<Either<Failure, Unit>> _unitResult(
    Future<ApiResult<Unit>> Function() request, {
    Failure Function(AppException exception) mapFailure = ExceptionMapper.map,
  }) => execute(() async {
    final result = await request();
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        mapFailure(exception),
      ),
    };
  });
}
