import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';
import 'package:accounting_software/app/features/catalog/units/domain/repositories/units_repository.dart';

class GetUnitsUseCase extends UseCase<PaginatedResult<CatalogUnit>, UnitListQuery> {
  GetUnitsUseCase(this._repository);
  final UnitsRepository _repository;
  @override
  Future<Either<Failure, PaginatedResult<CatalogUnit>>> call(UnitListQuery params) =>
      _repository.getUnits(params);
}
