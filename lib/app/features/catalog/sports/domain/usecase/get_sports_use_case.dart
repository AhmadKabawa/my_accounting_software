import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_list_query.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/repositories/sports_repository.dart';

class GetSportsUseCase extends UseCase<PaginatedResult<Sport>, SportListQuery> {
  GetSportsUseCase(this._repository);
  final SportsRepository _repository;

  @override
  Future<Either<Failure, PaginatedResult<Sport>>> call(SportListQuery params) =>
      _repository.getSports(params);
}
