import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/materials/data/datasources/materials_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/materials/data/datasources/materials_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/materials/data/repositories/materials_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/repository/materials_repository.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/get_materials_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/create_material_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/update_material_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/delete_material_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/usecase/set_material_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/cubit/materials_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/cubit/materials_form/material_form_cubit.dart';
void initMaterialsDI(){
 sl.registerLazySingleton<MaterialsRemoteDataSource>(()=>MaterialsRemoteDataSourceImpl(sl<IApiClient>()));
 sl.registerLazySingleton<MaterialsRepository>(()=>MaterialsRepositoryImpl(sl<MaterialsRemoteDataSource>()));
 sl.registerLazySingleton(()=>GetMaterialsUseCase(sl()));
 sl.registerLazySingleton(()=>CreateMaterialUseCase(sl()));
 sl.registerLazySingleton(()=>UpdateMaterialUseCase(sl()));
 sl.registerLazySingleton(()=>DeleteMaterialUseCase(sl()));
 sl.registerLazySingleton(()=>SetMaterialActiveUseCase(sl()));
 sl.registerFactory(()=>MaterialsListCubit(getItems:sl(),setActive:sl(),deleteItem:sl(),flashMessages:sl()));
 sl.registerFactory(()=>MaterialFormCubit(create:sl(),update:sl(),flashMessages:sl()));
}