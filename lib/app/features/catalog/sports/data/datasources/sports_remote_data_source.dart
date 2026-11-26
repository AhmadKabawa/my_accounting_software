import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/sports/data/models/sport_model.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_list_query.dart';

abstract interface class SportsRemoteDataSource {
  Future<ApiResult<PaginatedResult<SportModel>>> getSports(
    SportListQuery query,
  );

  Future<ApiResult<SportModel>> createSport(SportDraft draft);

  Future<ApiResult<SportModel>> updateSport({
    required int id,
    required SportDraft draft,
  });

  Future<ApiResult<Unit>> deleteSport(int id);

  Future<ApiResult<Unit>> setSportActive({
    required int id,
    required bool isActive,
  });
}
