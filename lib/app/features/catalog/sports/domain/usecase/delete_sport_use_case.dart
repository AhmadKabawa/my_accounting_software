import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/repositories/sports_repository.dart';

class DeleteSportParams extends Equatable {
  const DeleteSportParams(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class DeleteSportUseCase extends UseCase<Unit, DeleteSportParams> {
  DeleteSportUseCase(this._repository);

  final SportsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteSportParams params) =>
      _repository.deleteSport(params.id);
}
