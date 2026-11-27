import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/get_materials_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/set_material_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/delete_material_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/localization/materials_keys.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/cubit/materials_list_effect.dart';
class MaterialListCubit extends PagedListCubit<CatalogMaterial,MaterialListQuery,MaterialsListEffect> {
 MaterialListCubit({required GetMaterialsUseCase getItems,required SetMaterialActiveUseCase setActive,required DeleteMaterialUseCase deleteItem,required super.flashMessages}):_get=getItems,_set=setActive,_delete=deleteItem,super(initialQuery:const MaterialListQuery(page:AppConfig.defaultPage,pageSize:AppConfig.defaultPageSize));
 final GetMaterialsUseCase _get;final SetMaterialActiveUseCase _set;final DeleteMaterialUseCase _delete;
 @override Future<Either<Failure,PagedResult<CatalogMaterial>>> fetch(MaterialListQuery query)=>_get(query);
 @override Future<Either<Failure,Unit>> deleteItem(CatalogMaterial item)=>_delete(DeleteMaterialParams(item.id));
 @override AppKey get deletedMessageKey=>MaterialsKeys.deleted;
 @override MaterialsListEffect buildMutationEffect(PagedMutationKind kind)=>MaterialsMutatedEffect(switch(kind){PagedMutationKind.created=>MaterialsMutationKind.created,PagedMutationKind.updated=>MaterialsMutationKind.updated,PagedMutationKind.statusChanged=>MaterialsMutationKind.statusChanged,PagedMutationKind.deleted=>MaterialsMutationKind.deleted});
 Future<void> setStatus(MaterialStatusFilter value)=>applyQueryAndLoad(state.query.copyWith(status:value,page:1));
 Future<void> setSort(MaterialSortField field,bool ascending)=>applyQueryAndLoad(state.query.copyWith(sortField:field,sortAscending:ascending,page:1));
 Future<Either<Failure,Unit>> activate(int id)=>runMutation(()=>_set(SetMaterialActiveParams(id:id,isActive:true)),kind:PagedMutationKind.statusChanged,successMessage:MaterialsKeys.statusUpdated,flashFailure:true,rowId:id);
 Future<Either<Failure,Unit>> deactivate(int id)=>runMutation(()=>_set(SetMaterialActiveParams(id:id,isActive:false)),kind:PagedMutationKind.statusChanged,successMessage:MaterialsKeys.statusUpdated,flashFailure:true,rowId:id);
 Future<void> onSaved({required bool isNew})=>reloadAfterMutation(isNew?PagedMutationKind.created:PagedMutationKind.updated);
}