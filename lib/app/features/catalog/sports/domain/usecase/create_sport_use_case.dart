import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/repositories/sports_repository.dart';

class CreateSportUseCase extends UseCase<Sport, SportDraft> {
  CreateSportUseCase(this._repository);
  final SportsRepository _repository;

  @override
  Future<Either<Failure, Sport>> call(SportDraft params) =>
      _repository.createSport(params);
}
