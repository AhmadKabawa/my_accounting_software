import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_draft.dart';
import 'package:accounting_software/app/features/catalog/units/domain/repositories/units_repository.dart';

class UpdateUnitParams {
  const UpdateUnitParams({required this.id, required this.draft});
  final int id;
  final UnitDraft draft;
}

class UpdateUnitUseCase extends UseCase<CatalogUnit, UpdateUnitParams> {
  UpdateUnitUseCase(this._repository);
  final UnitsRepository _repository;
  @override
  Future<Either<Failure, CatalogUnit>> call(UpdateUnitParams params) =>
      _repository.updateUnit(id: params.id, draft: params.draft);
}
