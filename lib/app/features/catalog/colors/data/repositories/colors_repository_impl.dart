import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/colors/data/datasources/colors_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/colors/data/models/color_model.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/failures/color_failures.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/repositories/colors_repository.dart';

class ColorsRepositoryImpl with RepositoryExecutor implements ColorsRepository {
  const ColorsRepositoryImpl(this._remote);
  final ColorsRemoteDataSource _remote;

  /// SQLSTATE of a UNIQUE violation (`colors.code`).
  static const _uniqueViolation = '23505';

  @override
  Future<Either<Failure, PaginatedResult<CatalogColor>>> getColors(
    ColorListQuery query,
  ) => execute(() async {
    final result = await _remote.getColors(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<ColorModel>>(:final data) => Right(
        PaginatedResult<CatalogColor>(
          items: data.items.map((model) => model.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<ColorModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, CatalogColor>> createColor(CatalogColorDraft draft) =>
      execute(() async {
        final result = await _remote.createColor(draft);
        return switch (result) {
          ApiSuccess<ColorModel>(:final data) => Right(data.toEntity()),
          ApiFailure<ColorModel>(:final exception) => Left(
            _mapWriteFailure(exception),
          ),
        };
      });

  @override
  Future<Either<Failure, CatalogColor>> updateColor({
    required int id,
    required CatalogColorDraft draft,
  }) => execute(() async {
    final result = await _remote.updateColor(id: id, draft: draft);
    return switch (result) {
      ApiSuccess<ColorModel>(:final data) => Right(data.toEntity()),
      ApiFailure<ColorModel>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> setColorActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final result = await _remote.setColorActive(id: id, isActive: isActive);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == _uniqueViolation
      ? const ColorDuplicateFailure()
      : ExceptionMapper.map(exception);
}
