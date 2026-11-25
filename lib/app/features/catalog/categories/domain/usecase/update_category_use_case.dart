import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/repositories/categories_repository.dart';

class UpdateCategoryParams extends Equatable {
  const UpdateCategoryParams({required this.id, required this.draft});

  final int id;
  final CategoryDraft draft;

  @override
  List<Object?> get props => [id, draft];
}

class UpdateCategoryUseCase extends UseCase<Category, UpdateCategoryParams> {
  UpdateCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Either<Failure, Category>> call(UpdateCategoryParams params) =>
      _repository.update(id: params.id, draft: params.draft);
}
