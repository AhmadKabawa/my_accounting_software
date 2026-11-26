import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_stats.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_list_query.dart';

abstract interface class SportsRepository {
  Future<Either<Failure, SportStats>> getSportStats();

  Future<Either<Failure, Unit>> deleteSport(int id);

  Future<Either<Failure, PaginatedResult<Sport>>> getSports(
    SportListQuery query,
  );

  Future<Either<Failure, Sport>> createSport(SportDraft draft);

  Future<Either<Failure, Sport>> updateSport({
    required int id,
    required SportDraft draft,
  });

  Future<Either<Failure, Unit>> setSportActive({
    required int id,
    required bool isActive,
  });
}
