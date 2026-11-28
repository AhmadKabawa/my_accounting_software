import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/models/season_model.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_draft.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_list_query.dart';

abstract interface class SeasonsRemoteDataSource {
  Future<ApiResult<PaginatedResult<SeasonModel>>> getSeasons(
    SeasonListQuery query,
  );
  Future<ApiResult<SeasonModel>> createSeason(SeasonDraft draft);
  Future<ApiResult<SeasonModel>> updateSeason({
    required int id,
    required SeasonDraft draft,
  });
  Future<ApiResult<Unit>> deleteSeason(int id);
  Future<ApiResult<Unit>> setSeasonActive({
    required int id,
    required bool isActive,
  });
}
