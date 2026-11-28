import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_draft.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/repositories/seasons_repository.dart';

class CreateSeasonUseCase extends UseCase<CatalogSeason, SeasonDraft> {
  CreateSeasonUseCase(this._r);
  final SeasonsRepository _r;
  @override
  Future<Either<Failure, CatalogSeason>> call(SeasonDraft p) =>
      _r.createSeason(p);
}
