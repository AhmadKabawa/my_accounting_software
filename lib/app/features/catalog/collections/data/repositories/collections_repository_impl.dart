import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/failures/collection_failures.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/collections/data/datasources/collections_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/collections/data/models/collection_model.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_draft.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_list_query.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/repositories/collections_repository.dart';

class CollectionsRepositoryImpl
    with RepositoryExecutor
    implements CollectionsRepository {
  const CollectionsRepositoryImpl(this._remote);
  final CollectionsRemoteDataSource _remote;
  @override
  Future<Either<Failure, PaginatedResult<CatalogCollection>>> getCollections(
    CollectionListQuery q,
  ) => execute(() async {
    final r = await _remote.getCollections(q);
    return switch (r) {
      ApiSuccess<PaginatedResult<CollectionModel>>(:final data) => Right(
        PaginatedResult<CatalogCollection>(
          items: data.items.map((e) => e.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<CollectionModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, CatalogCollection>> createCollection(CollectionDraft d) =>
      execute(() async {
        final r = await _remote.createCollection(d);
        return switch (r) {
          ApiSuccess<CollectionModel>(:final data) => Right(data.toEntity()),
          ApiFailure<CollectionModel>(:final exception) => Left(
            _mapWriteFailure(exception),
          ),
        };
      });
  @override
  Future<Either<Failure, CatalogCollection>> updateCollection({
    required int id,
    required CollectionDraft draft,
  }) => execute(() async {
    final r = await _remote.updateCollection(id: id, draft: draft);
    return switch (r) {
      ApiSuccess<CollectionModel>(:final data) => Right(data.toEntity()),
      ApiFailure<CollectionModel>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, Unit>> deleteCollection(int id) => execute(() async {
    final r = await _remote.deleteCollection(id);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        exception is ApiException && exception.errorCode == '23503'
            ? const CollectionInUseFailure()
            : ExceptionMapper.map(exception),
      ),
    };
  });
  @override
  Future<Either<Failure, Unit>> setCollectionActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final r = await _remote.setCollectionActive(id: id, isActive: isActive);
    return switch (r) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == '23505'
      ? const CollectionDuplicateFailure()
      : ExceptionMapper.map(exception);
}
