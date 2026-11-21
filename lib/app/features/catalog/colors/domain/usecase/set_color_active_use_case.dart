import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/repositories/colors_repository.dart';

class SetColorActiveParams extends Equatable {
  const SetColorActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class SetColorActiveUseCase extends UseCase<Unit, SetColorActiveParams> {
  SetColorActiveUseCase(this._repository);
  final ColorsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetColorActiveParams params) =>
      _repository.setColorActive(id: params.id, isActive: params.isActive);
}
