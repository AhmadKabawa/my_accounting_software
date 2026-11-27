import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/models/fabric_type_model.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_draft.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_list_query.dart';
abstract interface class FabricTypesRemoteDataSource {
 Future<ApiResult<PaginatedResult<FabricTypeModel>>> getFabricTypes(FabricTypeListQuery query);
 Future<ApiResult<FabricTypeModel>> createFabricType(FabricTypeDraft draft);
 Future<ApiResult<FabricTypeModel>> updateFabricType({required int id,required FabricTypeDraft draft});
 Future<ApiResult<Unit>> deleteFabricType(int id);
 Future<ApiResult<Unit>> setFabricTypeActive({required int id,required bool isActive});
}