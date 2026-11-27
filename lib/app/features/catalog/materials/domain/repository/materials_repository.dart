import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_draft.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';
abstract interface class MaterialsRepository {
 Future<Either<Failure,PaginatedResult<CatalogMaterial>>> getMaterials(MaterialListQuery query);
 Future<Either<Failure,CatalogMaterial>> createMaterial(MaterialDraft draft);
 Future<Either<Failure,CatalogMaterial>> updateMaterial({required int id,required MaterialDraft draft});
 Future<Either<Failure,Unit>> deleteMaterial(int id);
 Future<Either<Failure,Unit>> setMaterialActive({required int id,required bool isActive});
}