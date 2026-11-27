import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failures.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/datasources/sizes_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/models/catalog_size_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/repositories/sizes_repository.dart';

class SizesRepositoryImpl with RepositoryExecutor implements SizesRepository {
  const SizesRepositoryImpl(this._remote);
  final SizesRemoteDataSource _remote;

  static const _uniqueViolation = '23505';
  static const _foreignKeyViolation = '23503';

  @override
  Future<Either<Failure, PaginatedResult<CatalogSize>>> getSizes(
    CatalogSizeListQuery query,
  ) => execute(() async {
    final result = await _remote.getSizes(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<CatalogSizeModel>>(:final data) => Right(
        PaginatedResult<CatalogSize>(
          items: data.items.map((model) => model.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<CatalogSizeModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, CatalogSize>> createSize(CatalogSizeDraft draft) =>
      execute(() async {
        final result = await _remote.createSize(draft);
        return switch (result) {
          ApiSuccess<CatalogSizeModel>(:final data) => Right(data.toEntity()),
          ApiFailure<CatalogSizeModel>(:final exception) => Left(
            _mapWriteFailure(exception),
          ),
        };
      });

  @override
  Future<Either<Failure, List<CatalogSize>>> createSizes(
    List<CatalogSizeDraft> drafts,
  ) => execute(() async {
    final result = await _remote.createSizes(drafts);
    return switch (result) {
      ApiSuccess<List<CatalogSizeModel>>(:final data) => Right(
        data.map((model) => model.toEntity()).toList(),
      ),
      ApiFailure<List<CatalogSizeModel>>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, CatalogSize>> updateSize({
    required int id,
    required CatalogSizeDraft draft,
  }) => execute(() async {
    final result = await _remote.updateSize(id: id, draft: draft);
    return switch (result) {
      ApiSuccess<CatalogSizeModel>(:final data) => Right(data.toEntity()),
      ApiFailure<CatalogSizeModel>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> deleteSize(int id) => execute(() async {
    final result = await _remote.deleteSize(id);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(_mapDeleteFailure(exception)),
    };
  });

  @override
  Future<Either<Failure, Unit>> setSizeActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final result = await _remote.setSizeActive(id: id, isActive: isActive);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  Failure _mapDeleteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == _foreignKeyViolation
      ? const SizeInUseFailure()
      : ExceptionMapper.map(exception);

  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException &&
          (exception.errorCode == _uniqueViolation ||
              exception.statusCode == 409)
      ? const SizeCodeDuplicateFailure()
      : ExceptionMapper.map(exception);
}
