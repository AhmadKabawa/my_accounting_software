import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_sets_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_set_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/models/option_set_model.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_stats.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/failures/option_set_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class OptionSetsRepositoryImpl
    with RepositoryExecutor
    implements OptionSetsRepository {
  const OptionSetsRepositoryImpl(this._remote, this._statsRemote);
  final OptionSetsRemoteDataSource _remote;
  final OptionSetStatsRemoteDataSource _statsRemote;

  @override
  Future<Either<Failure, OptionSetStats>> getOptionSetStats() =>
      execute(() async {
        final result = await _statsRemote.getOptionSetStats();
        return switch (result) {
          ApiSuccess<OptionSetStats>(:final data) => Right(data),
          ApiFailure<OptionSetStats>(:final exception) => Left(
            ExceptionMapper.map(exception),
          ),
        };
      });

  @override
  Future<Either<Failure, PaginatedResult<OptionSet>>> getOptionSets(
    OptionSetListQuery query,
  ) => execute(() async {
    final result = await _remote.getOptionSets(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<OptionSetModel>>(:final data) => Right(
        PaginatedResult<OptionSet>(
          items: data.items.map((item) => item.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<OptionSetModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, List<CatalogOption>>> getOptions({
    required int optionSetId,
    String search = '',
  }) => execute(() async {
    final result = await _remote.getOptions(
      optionSetId: optionSetId,
      search: search,
    );
    return switch (result) {
      ApiSuccess<List<CatalogOptionModel>>(:final data) => Right(
        data.map((item) => item.toEntity()).toList(),
      ),
      ApiFailure<List<CatalogOptionModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, OptionSet>> createOptionSet(OptionSetDraft draft) =>
      _writeGroup(() => _remote.createOptionSet(draft));

  @override
  Future<Either<Failure, OptionSet>> updateOptionSet({
    required int id,
    required OptionSetDraft draft,
  }) => _writeGroup(() => _remote.updateOptionSet(id: id, draft: draft));

  Future<Either<Failure, OptionSet>> _writeGroup(
    Future<ApiResult<OptionSetModel>> Function() request,
  ) => execute(() async {
    final result = await request();
    return switch (result) {
      ApiSuccess<OptionSetModel>(:final data) => Right(data.toEntity()),
      ApiFailure<OptionSetModel>(:final exception) => Left(
        _mapGroupWriteFailure(exception),
      ),
    };
  });

  Failure _mapGroupWriteFailure(AppException exception) {
    if (exception is ApiException &&
        (exception.errorCode == '23505' || exception.statusCode == 409)) {
      return ValidationFailure(
        messageKey: OptionSetFailureKeys.duplicateCode,
        statusCode: exception.statusCode,
      );
    }
    if (exception is ApiException && exception.errorCode == '23514') {
      return ValidationFailure(
        messageKey: OptionSetFailureKeys.invalidSelectionType,
        statusCode: exception.statusCode,
      );
    }
    if (exception is ApiException && exception.errorCode == 'ERP28') {
      return ValidationFailure(
        messageKey: OptionSetFailureKeys.selectionTypeLocked,
        statusCode: exception.statusCode,
      );
    }
    return ExceptionMapper.map(exception);
  }

  Failure _mapDeleteFailure(AppException exception) {
    if (exception is ApiException && exception.errorCode == '23503') {
      return ValidationFailure(
        messageKey: OptionSetFailureKeys.inUse,
        statusCode: exception.statusCode,
      );
    }
    return ExceptionMapper.map(exception);
  }

  Failure _mapOptionWriteFailure(AppException exception) {
    if (exception is ApiException &&
        (exception.errorCode == '23505' || exception.statusCode == 409)) {
      return ValidationFailure(
        messageKey: OptionSetFailureKeys.duplicateOptionCode,
        statusCode: exception.statusCode,
      );
    }
    if (exception is ApiException && exception.errorCode == '23514') {
      return ValidationFailure(
        messageKey: OptionSetFailureKeys.invalidSelectionType,
        statusCode: exception.statusCode,
      );
    }
    return ExceptionMapper.map(exception);
  }

  @override
  Future<Either<Failure, Unit>> deleteOptionSet(int id) =>
      _unit(() => _remote.deleteOptionSet(id), mapFailure: _mapDeleteFailure);

  @override
  Future<Either<Failure, Unit>> setOptionSetActive({
    required int id,
    required bool isActive,
  }) => _unit(() => _remote.setOptionSetActive(id: id, isActive: isActive));

  @override
  Future<Either<Failure, Unit>> createOption({
    required int optionSetId,
    required CatalogOptionDraft draft,
  }) => _unit(
    () => _remote.createOption(optionSetId: optionSetId, draft: draft),
    mapFailure: _mapOptionWriteFailure,
  );

  @override
  Future<Either<Failure, Unit>> updateOption({
    required int optionId,
    required CatalogOptionDraft draft,
  }) => _unit(
    () => _remote.updateOption(optionId: optionId, draft: draft),
    mapFailure: _mapOptionWriteFailure,
  );

  @override
  Future<Either<Failure, Unit>> setOptionActive({
    required int optionId,
    required bool isActive,
  }) => _unit(
    () => _remote.setOptionActive(optionId: optionId, isActive: isActive),
  );

  Future<Either<Failure, Unit>> _unit(
    Future<ApiResult<Unit>> Function() request, {
    Failure Function(AppException exception) mapFailure = ExceptionMapper.map,
  }) => execute(() async {
    final result = await request();
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(mapFailure(exception)),
    };
  });
}
