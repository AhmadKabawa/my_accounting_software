import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/repositories/tags_repository.dart';

class SetTagActiveParams extends Equatable {
  const SetTagActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class SetTagActiveUseCase extends UseCase<Unit, SetTagActiveParams> {
  SetTagActiveUseCase(this._repository);
  final TagsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetTagActiveParams params) =>
      _repository.setTagActive(id: params.id, isActive: params.isActive);
}
