import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/tags/data/datasources/tags_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/tags/data/datasources/tag_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/tags/data/models/tag_model.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_stats.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_list_query.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/failures/tag_failures.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/repositories/tags_repository.dart';

class TagsRepositoryImpl with RepositoryExecutor implements TagsRepository {
  const TagsRepositoryImpl(this._remote, this._statsRemote);
  final TagsRemoteDataSource _remote;
  final TagStatsRemoteDataSource _statsRemote;

  /// SQLSTATE of a UNIQUE violation (`tags.name` or `tags.slug`).
  static const _uniqueViolation = '23505';

  @override
  Future<Either<Failure, TagStats>> getTagStats() => execute(() async {
    final result = await _statsRemote.getTagStats();
    return switch (result) {
      ApiSuccess<TagStats>(:final data) => Right(data),
      ApiFailure<TagStats>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> deleteTag(int id) => execute(() async {
    final result = await _remote.deleteTag(id);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(_mapDeleteFailure(exception)),
    };
  });

  @override
  Future<Either<Failure, PaginatedResult<CatalogTag>>> getTags(
    TagListQuery query,
  ) => execute(() async {
    final result = await _remote.getTags(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<TagModel>>(:final data) => Right(
        PaginatedResult<CatalogTag>(
          items: data.items.map((model) => model.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<TagModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, CatalogTag>> createTag(CatalogTagDraft draft) =>
      execute(() async {
        final result = await _remote.createTag(draft);
        return switch (result) {
          ApiSuccess<TagModel>(:final data) => Right(data.toEntity()),
          ApiFailure<TagModel>(:final exception) => Left(
            _mapWriteFailure(exception),
          ),
        };
      });

  @override
  Future<Either<Failure, CatalogTag>> updateTag({
    required int id,
    required CatalogTagDraft draft,
  }) => execute(() async {
    final result = await _remote.updateTag(id: id, draft: draft);
    return switch (result) {
      ApiSuccess<TagModel>(:final data) => Right(data.toEntity()),
      ApiFailure<TagModel>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> setTagActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final result = await _remote.setTagActive(id: id, isActive: isActive);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  Failure _mapDeleteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == '23503'
      ? const TagInUseFailure()
      : ExceptionMapper.map(exception);

  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == _uniqueViolation
      ? const TagDuplicateFailure()
      : ExceptionMapper.map(exception);
}
