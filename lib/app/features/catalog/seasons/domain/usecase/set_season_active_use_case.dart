import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/repositories/seasons_repository.dart';

class SetSeasonActiveParams {
  const SetSeasonActiveParams({required this.id, required this.isActive});
  final int id;
  final bool isActive;
}

class SetSeasonActiveUseCase extends UseCase<Unit, SetSeasonActiveParams> {
  SetSeasonActiveUseCase(this._r);
  final SeasonsRepository _r;
  @override
  Future<Either<Failure, Unit>> call(SetSeasonActiveParams p) =>
      _r.setSeasonActive(id: p.id, isActive: p.isActive);
}
