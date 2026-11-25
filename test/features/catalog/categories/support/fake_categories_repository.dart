import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/repositories/categories_repository.dart';

class FakeCategoriesRepository implements CategoriesRepository {
  FakeCategoriesRepository({List<Category> categories = const []})
    : categories = categories;

  List<Category> categories;
  int getAllCalls = 0;
  final List<int> deletedIds = [];
  final List<(int, bool)> statusUpdates = [];
  Either<Failure, Unit> mutationResult = const Right(unit);

  @override
  Future<Either<Failure, List<Category>>> getAll() async {
    getAllCalls++;
    return Right(categories);
  }

  @override
  Future<Either<Failure, Category>> create(CategoryDraft draft) async =>
      Right(categories.first);

  @override
  Future<Either<Failure, Category>> update({
    required int id,
    required CategoryDraft draft,
  }) async => Right(categories.firstWhere((item) => item.id == id));

  @override
  Future<Either<Failure, Unit>> delete(int id) async {
    deletedIds.add(id);
    return mutationResult;
  }

  @override
  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  }) async {
    statusUpdates.add((id, isActive));
    return mutationResult;
  }
}
