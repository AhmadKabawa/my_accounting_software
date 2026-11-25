import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/repositories/categories_repository.dart';

class CreateCategoryUseCase extends UseCase<Category, CategoryDraft> {
  CreateCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Either<Failure, Category>> call(CategoryDraft params) =>
      _repository.create(params);
}
