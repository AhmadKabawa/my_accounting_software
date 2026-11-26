import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_draft.dart';
import 'package:accounting_software/app/features/catalog/units/domain/repositories/units_repository.dart';

class CreateUnitUseCase extends UseCase<CatalogUnit, UnitDraft> {
  CreateUnitUseCase(this._repository);
  final UnitsRepository _repository;
  @override
  Future<Either<Failure, CatalogUnit>> call(UnitDraft params) =>
      _repository.createUnit(params);
}
