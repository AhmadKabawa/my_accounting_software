import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_draft.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';

abstract interface class UnitsRepository {
  Future<Either<Failure, PaginatedResult<CatalogUnit>>> getUnits(
    UnitListQuery query,
  );
  Future<Either<Failure, CatalogUnit>> createUnit(UnitDraft draft);
  Future<Either<Failure, CatalogUnit>> updateUnit({
    required int id,
    required UnitDraft draft,
  });
  Future<Either<Failure, Unit>> setUnitActive({
    required int id,
    required bool isActive,
  });
  Future<Either<Failure, Unit>> deleteUnit(int id);
}
