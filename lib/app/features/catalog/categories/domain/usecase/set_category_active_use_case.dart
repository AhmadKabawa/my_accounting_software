import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/repositories/categories_repository.dart';

class SetCategoryActiveParams extends Equatable {
  const SetCategoryActiveParams({required this.id, required this.isActive});

  final int id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class SetCategoryActiveUseCase extends UseCase<Unit, SetCategoryActiveParams> {
  SetCategoryActiveUseCase(this._repository);

  final CategoriesRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetCategoryActiveParams params) =>
      _repository.setActive(id: params.id, isActive: params.isActive);
}
