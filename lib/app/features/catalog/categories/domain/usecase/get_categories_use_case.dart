import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/repositories/categories_repository.dart';

class GetCategoriesUseCase extends UseCase<List<Category>, NoParams> {
  GetCategoriesUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) =>
      _repository.getAll();
}
