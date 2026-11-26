import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_sets_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/models/option_set_model.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class OptionSetsRepositoryImpl
    with RepositoryExecutor
    implements OptionSetsRepository {
  const OptionSetsRepositoryImpl(this._remote);
  final OptionSetsRemoteDataSource _remote;

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
  Future<Either<Failure, OptionSet>> createOptionSet(OptionSetDraft draft) =>
      _write(() => _remote.createOptionSet(draft));
  @override
  Future<Either<Failure, OptionSet>> updateOptionSet({
    required int id,
    required OptionSetDraft draft,
  }) => _write(() => _remote.updateOptionSet(id: id, draft: draft));

  Future<Either<Failure, OptionSet>> _write(
    Future<ApiResult<OptionSetModel>> Function() request,
  ) => execute(() async {
    final result = await request();
    return switch (result) {
      ApiSuccess<OptionSetModel>(:final data) => Right(data.toEntity()),
      ApiFailure<OptionSetModel>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> setOptionSetActive({
    required int id,
    required bool isActive,
  }) => _unit(() => _remote.setOptionSetActive(id: id, isActive: isActive));
  @override
  Future<Either<Failure, Unit>> createOption({
    required int optionSetId,
    required CatalogOptionDraft draft,
  }) =>
      _unit(() => _remote.createOption(optionSetId: optionSetId, draft: draft));
  @override
  Future<Either<Failure, Unit>> updateOption({
    required int optionId,
    required CatalogOptionDraft draft,
  }) => _unit(() => _remote.updateOption(optionId: optionId, draft: draft));
  @override
  Future<Either<Failure, Unit>> setOptionActive({
    required int optionId,
    required bool isActive,
  }) => _unit(
    () => _remote.setOptionActive(optionId: optionId, isActive: isActive),
  );

  Future<Either<Failure, Unit>> _unit(
    Future<ApiResult<Unit>> Function() request,
  ) => execute(() async {
    final result = await request();
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });
}
