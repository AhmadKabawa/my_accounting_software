import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_stats.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/repositories/colors_repository.dart';

class GetColorStatsUseCase extends UseCase<ColorStats, NoParams> {
  GetColorStatsUseCase(this._repository);

  final ColorsRepository _repository;

  @override
  Future<Either<Failure, ColorStats>> call(NoParams params) =>
      _repository.getColorStats();
}
