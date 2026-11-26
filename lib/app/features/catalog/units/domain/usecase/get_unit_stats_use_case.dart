import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_stats.dart';
import 'package:accounting_software/app/features/catalog/units/domain/repositories/units_repository.dart';

class GetUnitStatsUseCase extends UseCase<UnitStats, NoParams> {
  GetUnitStatsUseCase(this._repository);
  final UnitsRepository _repository;

  @override
  Future<Either<Failure, UnitStats>> call(NoParams params) =>
      _repository.getUnitStats();
}
