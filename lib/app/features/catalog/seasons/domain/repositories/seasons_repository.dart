import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_draft.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_list_query.dart';

abstract interface class SeasonsRepository {
  Future<Either<Failure, PaginatedResult<CatalogSeason>>> getSeasons(
    SeasonListQuery query,
  );
  Future<Either<Failure, CatalogSeason>> createSeason(SeasonDraft draft);
  Future<Either<Failure, CatalogSeason>> updateSeason({
    required int id,
    required SeasonDraft draft,
  });
  Future<Either<Failure, Unit>> deleteSeason(int id);
  Future<Either<Failure, Unit>> setSeasonActive({
    required int id,
    required bool isActive,
  });
}
