import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failures.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/data/datasources/size_systems_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/data/models/size_system_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_stats.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/repositories/size_systems_repository.dart';

class SizeSystemsRepositoryImpl
    with RepositoryExecutor
    implements SizeSystemsRepository {
  const SizeSystemsRepositoryImpl(this._remote);
  final SizeSystemsRemoteDataSource _remote;

  static const _uniqueViolation = '23505';
  static const _foreignKeyViolation = '23503';

  @override
  Future<Either<Failure, PaginatedResult<SizeSystem>>> getSizeSystems(
    SizeSystemListQuery query,
  ) => execute(() async {
    final result = await _remote.getSizeSystems(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<SizeSystemModel>>(:final data) => Right(
        PaginatedResult<SizeSystem>(
          items: data.items.map((model) => model.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<SizeSystemModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, SizeSystemStats>> getStats() => execute(() async {
    final result = await _remote.getStats();
    return switch (result) {
      ApiSuccess<SizeSystemStats>(:final data) => Right(data),
      ApiFailure<SizeSystemStats>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, SizeSystem>> createSizeSystem(SizeSystemDraft draft) =>
      execute(() async {
        final result = await _remote.createSizeSystem(draft);
        return switch (result) {
          ApiSuccess<SizeSystemModel>(:final data) => Right(data.toEntity()),
          ApiFailure<SizeSystemModel>(:final exception) => Left(
            _mapWriteFailure(exception),
          ),
        };
      });

  @override
  Future<Either<Failure, SizeSystem>> updateSizeSystem({
    required int id,
    required SizeSystemDraft draft,
  }) => execute(() async {
    final result = await _remote.updateSizeSystem(id: id, draft: draft);
    return switch (result) {
      ApiSuccess<SizeSystemModel>(:final data) => Right(data.toEntity()),
      ApiFailure<SizeSystemModel>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> deleteSizeSystem(int id) => execute(() async {
    final result = await _remote.deleteSizeSystem(id);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(_mapDeleteFailure(exception)),
    };
  });

  @override
  Future<Either<Failure, Unit>> setSizeSystemActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final result = await _remote.setSizeSystemActive(
      id: id,
      isActive: isActive,
    );
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  Failure _mapDeleteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == _foreignKeyViolation
      ? const SizeSystemInUseFailure()
      : ExceptionMapper.map(exception);

  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException &&
          (exception.errorCode == _uniqueViolation ||
              exception.statusCode == 409)
      ? const SizeCodeDuplicateFailure()
      : ExceptionMapper.map(exception);
}
