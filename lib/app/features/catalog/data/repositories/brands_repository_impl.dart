import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/data/datasources/brands_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/data/models/brand_model.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/domain/repositories/brands_repository.dart';

class BrandsRepositoryImpl with RepositoryExecutor implements BrandsRepository {
  const BrandsRepositoryImpl(this._remote);
  final BrandsRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedResult<Brand>>> getBrands(
    BrandListQuery query,
  ) => execute(() async {
    final result = await _remote.getBrands(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<BrandModel>>(:final data) => Right(
        PaginatedResult<Brand>(
          items: data.items.map((model) => model.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<BrandModel>>(:final exception) =>
        Left(ExceptionMapper.map(exception)),
    };
  });

  @override
  Future<Either<Failure, Brand>> createBrand(BrandDraft draft) =>
      execute(() async {
        final result = await _remote.createBrand(draft);
        return switch (result) {
          ApiSuccess<BrandModel>(:final data) => Right(data.toEntity()),
          ApiFailure<BrandModel>(:final exception) =>
            Left(_mapWriteFailure(exception)),
        };
      });

  @override
  Future<Either<Failure, Brand>> updateBrand({
    required int id,
    required BrandDraft draft,
  }) => execute(() async {
    final result = await _remote.updateBrand(id: id, draft: draft);
    return switch (result) {
      ApiSuccess<BrandModel>(:final data) => Right(data.toEntity()),
      ApiFailure<BrandModel>(:final exception) =>
        Left(_mapWriteFailure(exception)),
    };
  });

  @override
  Future<Either<Failure, Unit>> setBrandActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final result = await _remote.setBrandActive(id: id, isActive: isActive);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) =>
        Left(ExceptionMapper.map(exception)),
    };
  });

  @override
  Future<Either<Failure, Unit>> deleteBrand(int id) => execute(() async {
    final result = await _remote.deleteBrand(id);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) =>
        Left(_mapDeleteFailure(exception)),
    };
  });

  Failure _mapWriteFailure(AppException exception) {
    if (_isDuplicate(exception)) return const BrandDuplicateFailure();
    return ExceptionMapper.map(exception);
  }

  Failure _mapDeleteFailure(AppException exception) {
    if (_isForeignKeyConflict(exception)) return const BrandInUseFailure();
    return ExceptionMapper.map(exception);
  }

  bool _isDuplicate(AppException exception) =>
      exception.statusCode == 409 ||
      (exception is ApiException && exception.errorCode == '23505');

  bool _isForeignKeyConflict(AppException exception) =>
      exception.statusCode == 409 ||
      (exception is ApiException && exception.errorCode == '23503');
}
