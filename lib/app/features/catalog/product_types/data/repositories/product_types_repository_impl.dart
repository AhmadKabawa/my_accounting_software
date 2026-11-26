import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/datasources/product_types_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/models/product_type_model.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/failures/product_type_failures.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';

class ProductTypesRepositoryImpl
    with RepositoryExecutor
    implements ProductTypesRepository {
  const ProductTypesRepositoryImpl(this._remote);

  final ProductTypesRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginatedResult<ProductType>>> getPage(
    ProductTypeListQuery query,
  ) => execute(() async {
    final result = await _remote.getPage(query);
    return switch (result) {
      ApiSuccess<PaginatedResult<ProductTypeModel>>(:final data) => Right(
        PaginatedResult<ProductType>(
          items: data.items.map((item) => item.toEntity()).toList(),
          totalCount: data.totalCount,
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          isFromCache: data.isFromCache,
        ),
      ),
      ApiFailure<PaginatedResult<ProductTypeModel>>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, ProductType>> create(ProductTypeDraft draft) =>
      execute(() async {
        final result = await _remote.create(draft);
        return switch (result) {
          ApiSuccess<ProductTypeModel>(:final data) => Right(data.toEntity()),
          ApiFailure<ProductTypeModel>(:final exception) => Left(
            _mapWriteFailure(exception),
          ),
        };
      });

  @override
  Future<Either<Failure, ProductType>> update({
    required int id,
    required ProductTypeDraft draft,
  }) => execute(() async {
    final result = await _remote.update(id: id, draft: draft);
    return switch (result) {
      ApiSuccess<ProductTypeModel>(:final data) => Right(data.toEntity()),
      ApiFailure<ProductTypeModel>(:final exception) => Left(
        _mapWriteFailure(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  }) => execute(() async {
    final result = await _remote.setActive(id: id, isActive: isActive);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(
        ExceptionMapper.map(exception),
      ),
    };
  });

  @override
  Future<Either<Failure, Unit>> delete(int id) => execute(() async {
    final result = await _remote.delete(id);
    return switch (result) {
      ApiSuccess<Unit>() => const Right(unit),
      ApiFailure<Unit>(:final exception) => Left(_mapDeleteFailure(exception)),
    };
  });

  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException &&
          (exception.errorCode == '23505' || exception.statusCode == 409)
      ? const ProductTypeDuplicateFailure()
      : ExceptionMapper.map(exception);

  Failure _mapDeleteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == '23503'
      ? const ProductTypeInUseFailure()
      : ExceptionMapper.map(exception);
}
