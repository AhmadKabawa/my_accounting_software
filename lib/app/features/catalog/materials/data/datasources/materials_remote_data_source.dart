import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/materials/data/models/material_model.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_draft.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';
abstract interface class MaterialsRemoteDataSource {
 Future<ApiResult<PaginatedResult<MaterialModel>>> getMaterials(MaterialListQuery query);
 Future<ApiResult<MaterialModel>> createMaterial(MaterialDraft draft);
 Future<ApiResult<MaterialModel>> updateMaterial({required int id,required MaterialDraft draft});
 Future<ApiResult<Unit>> deleteMaterial(int id);
 Future<ApiResult<Unit>> setMaterialActive({required int id,required bool isActive});
}