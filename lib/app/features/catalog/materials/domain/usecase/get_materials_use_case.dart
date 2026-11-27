import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/repository/materials_repository.dart';

class GetMaterialsUseCase
    extends UseCase<PaginatedResult<CatalogMaterial>, MaterialListQuery> {
  GetMaterialsUseCase(this._r);
  final MaterialsRepository _r;
  @override
  Future<Either<Failure, PaginatedResult<CatalogMaterial>>> call(
    MaterialListQuery p,
  ) => _r.getMaterials(p);
}
