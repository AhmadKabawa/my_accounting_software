import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_stats.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

class GetOptionSetStatsUseCase extends UseCase<OptionSetStats, NoParams> {
  GetOptionSetStatsUseCase(this._repository);
  final OptionSetsRepository _repository;
  @override
  Future<Either<Failure, OptionSetStats>> call(NoParams params) =>
      _repository.getOptionSetStats();
}
