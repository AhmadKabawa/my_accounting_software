import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/data/datasources/size_groups_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/data/models/size_group_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/gender_option.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/repositories/size_groups_repository.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failures.dart';

class SizeGroupsRepositoryImpl
    with RepositoryExecutor
    implements SizeGroupsRepository {
  const SizeGroupsRepositoryImpl(this._remote);
  final SizeGroupsRemoteDataSource _remote;

  static const _uniqueViolation = '23505';
  static const _foreignKeyViolation = '23503';

  @override
  Future<Either<Failure, PaginatedResult<SizeGroup>>> getSizeGroups(
    SizeGroupListQuery query,
  ) => execute(() async {
    final result = await _remote.getSizeGroups(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<SizeGroupModel>>(:final data) => Right(
        PaginatedResult<SizeGroup>(
          items: data.items.map((model) => model.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<SizeGroupModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, List<GenderOption>>> getGenders() =>
      execute(() async {
        final result = await _remote.getGenders();
        return switch (result) {
          ApiSuccess<List<GenderOptionModel>>(:final data) => Right(
            data.map((model) => model.toEntity()).toList(),
          ),
          ApiFailure<List<GenderOptionModel>>(:final exception) => Left(
            ExceptionMapper.map(exception),
          ),
        };
      });

  @override
  Future<Either<Failure, SizeGroup>> createSizeGroup(SizeGroupDraft draft) =>
      execute(() async {
        final result = await _remote.createSizeGroup(draft);
        return switch (result) {
          ApiSuccess<SizeGroupModel>(:final data) => Right(data.toEntity()),
          ApiFailure<SizeGroupModel>(:final exception) => Left(
            _mapWriteFailure(exception),
          ),
        };
      });

  @override
  Future<Either<Failure, SizeGroup>> updateSizeGroup({
    required int id,
    required SizeGroupDraft draft,
  }) => execute(() async {
    final result = await _remote.updateSizeGroup(id: id, draft: draft);
    return switch (result) {
      ApiSuccess<SizeGroupModel>(:final data) => Right(data.toEntity()),
      ApiFailure<SizeGroupModel>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> deleteSizeGroup(int id) => execute(() async {
    final result = await _remote.deleteSizeGroup(id);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(_mapDeleteFailure(exception)),
    };
  });

  @override
  Future<Either<Failure, Unit>> setSizeGroupActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final result = await _remote.setSizeGroupActive(id: id, isActive: isActive);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  Failure _mapDeleteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == _foreignKeyViolation
      ? const SizeGroupInUseFailure()
      : ExceptionMapper.map(exception);

  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException &&
          (exception.errorCode == _uniqueViolation ||
              exception.statusCode == 409)
      ? const SizeCodeDuplicateFailure()
      : ExceptionMapper.map(exception);
}
