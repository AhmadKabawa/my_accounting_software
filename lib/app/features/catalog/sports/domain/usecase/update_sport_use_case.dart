import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/repositories/sports_repository.dart';

class UpdateSportParams extends Equatable {
  const UpdateSportParams({required this.id, required this.draft});
  final int id;
  final SportDraft draft;

  @override
  List<Object?> get props => [id, draft];
}

class UpdateSportUseCase extends UseCase<Sport, UpdateSportParams> {
  UpdateSportUseCase(this._repository);
  final SportsRepository _repository;

  @override
  Future<Either<Failure, Sport>> call(UpdateSportParams params) =>
      _repository.updateSport(id: params.id, draft: params.draft);
}
