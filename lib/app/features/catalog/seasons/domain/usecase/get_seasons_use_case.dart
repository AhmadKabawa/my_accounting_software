import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_list_query.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/repositories/seasons_repository.dart';

class GetSeasonsUseCase
    extends UseCase<PaginatedResult<CatalogSeason>, SeasonListQuery> {
  GetSeasonsUseCase(this._r);
  final SeasonsRepository _r;
  @override
  Future<Either<Failure, PaginatedResult<CatalogSeason>>> call(
    SeasonListQuery p,
  ) => _r.getSeasons(p);
}
