import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_draft.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_list_query.dart';
abstract interface class FabricTypesRepository {
 Future<Either<Failure,PaginatedResult<CatalogFabricType>>> getFabricTypes(FabricTypeListQuery query);
 Future<Either<Failure,CatalogFabricType>> createFabricType(FabricTypeDraft draft);
 Future<Either<Failure,CatalogFabricType>> updateFabricType({required int id,required FabricTypeDraft draft});
 Future<Either<Failure,Unit>> deleteFabricType(int id);
 Future<Either<Failure,Unit>> setFabricTypeActive({required int id,required bool isActive});
}