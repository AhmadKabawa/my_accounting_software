import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';

abstract interface class CategoriesRepository {
  /// Every category, in one list (the tree is built by the caller).
  Future<Either<Failure, List<Category>>> getAll();

  Future<Either<Failure, Category>> create(CategoryDraft draft);

  Future<Either<Failure, Category>> update({
    required int id,
    required CategoryDraft draft,
  });

  Future<Either<Failure, Unit>> delete(int id);

  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  });
}
