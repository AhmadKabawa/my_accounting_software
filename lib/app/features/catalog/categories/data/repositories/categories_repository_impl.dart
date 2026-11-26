import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/base/repository_executor.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/categories/data/datasources/categories_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/categories/data/models/category_model.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failures.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/repositories/categories_repository.dart';

class CategoriesRepositoryImpl
    with RepositoryExecutor
    implements CategoriesRepository {
  const CategoriesRepositoryImpl(this._remote);

  final CategoriesRemoteDataSource _remote;

  /// SQLSTATE of a UNIQUE violation (`categories.slug`).
  static const _uniqueViolation = '23505';

  /// SQLSTATE of a foreign-key violation (products or child categories).
  static const _foreignKeyViolation = '23503';

  /// PostgREST truncates a response at 1000 rows by default.
  static const pageSize = 1000;

  /// D-CAT-2: the whole tree is loaded at once. Past this many rows the tree
  /// needs another design (lazy levels), so loading is refused, not truncated.
  static const maxCategories = 2000;

  @override
  Future<Either<Failure, List<Category>>> getAll() => execute(() async {
    final first = await _remote.getPage(page: 1, limit: pageSize);
    switch (first) {
      case ApiFailure<PaginatedResult<CategoryModel>>(:final exception):
        return Left(ExceptionMapper.map(exception));
      case ApiSuccess<PaginatedResult<CategoryModel>>(:final data):
        if (data.totalCount > maxCategories) {
          return const Left(CategoryTreeTooLargeFailure());
        }
        final models = [...data.items];
        for (var page = 2; page <= data.totalPages; page++) {
          final next = await _remote.getPage(page: page, limit: pageSize);
          switch (next) {
            case ApiFailure<PaginatedResult<CategoryModel>>(:final exception):
              return Left(ExceptionMapper.map(exception));
            case ApiSuccess<PaginatedResult<CategoryModel>>(data: final more):
              models.addAll(more.items);
          }
        }
        return Right([for (final model in models) model.toEntity()]);
    }
  });

  @override
  Future<Either<Failure, Category>> create(CategoryDraft draft) =>
      execute(() async {
        final result = await _remote.create(draft);
        return switch (result) {
          ApiSuccess<CategoryModel>(:final data) => Right(data.toEntity()),
          ApiFailure<CategoryModel>(:final exception) => Left(
            _mapWriteFailure(exception),
          ),
        };
      });

  @override
  Future<Either<Failure, Category>> update({
    required int id,
    required CategoryDraft draft,
  }) => execute(() async {
    final result = await _remote.update(id: id, draft: draft);
    return switch (result) {
      ApiSuccess<CategoryModel>(:final data) => Right(data.toEntity()),
      ApiFailure<CategoryModel>(:final exception) => Left(
        _mapWriteFailure(exception),
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

  @override
  Future<Either<Failure, String>> uploadImage(ImageUpload image) =>
      execute(() async {
        final result = await _remote.uploadImage(image);
        return switch (result) {
          ApiSuccess<String>(:final data) => Right(data),
          ApiFailure<String>(:final exception) => Left(ExceptionMapper.map(exception)),
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

  Failure _mapDeleteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == _foreignKeyViolation
      ? const CategoryInUseFailure()
      : ExceptionMapper.map(exception);

  Failure _mapWriteFailure(AppException exception) =>
      exception is ApiException && exception.errorCode == _uniqueViolation
      ? const CategorySlugTakenFailure()
      : ExceptionMapper.map(exception);
}
