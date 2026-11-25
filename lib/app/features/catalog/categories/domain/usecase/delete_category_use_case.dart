import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/repositories/categories_repository.dart';

class DeleteCategoryUseCase extends UseCase<Unit, int> {
  DeleteCategoryUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int params) => _repository.delete(params);
}
