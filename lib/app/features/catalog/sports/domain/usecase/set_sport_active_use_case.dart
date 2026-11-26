import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/repositories/sports_repository.dart';

class SetSportActiveParams extends Equatable {
  const SetSportActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;

  @override
  List<Object?> get props => [id, isActive];
}

class SetSportActiveUseCase extends UseCase<Unit, SetSportActiveParams> {
  SetSportActiveUseCase(this._repository);
  final SportsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetSportActiveParams params) =>
      _repository.setSportActive(id: params.id, isActive: params.isActive);
}
