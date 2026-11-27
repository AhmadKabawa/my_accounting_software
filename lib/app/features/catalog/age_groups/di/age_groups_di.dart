import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/datasources/age_groups_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/datasources/age_groups_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/age_groups/data/repositories/age_groups_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/repositories/age_groups_repository.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/usecase/age_groups_use_cases.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/cubit/age_group_form/age_group_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/cubit/age_groups_list/age_groups_list_cubit.dart';
void initAgeGroupsDI(){
  sl.registerLazySingleton<AgeGroupsRemoteDataSource>(()=>AgeGroupsRemoteDataSourceImpl(sl<IApiClient>()));
  sl.registerLazySingleton<AgeGroupsRepository>(()=>AgeGroupsRepositoryImpl(sl()));
  sl.registerLazySingleton(()=>GetAgeGroupsUseCase(sl()));
  sl.registerLazySingleton(()=>CreateAgeGroupUseCase(sl()));
  sl.registerLazySingleton(()=>UpdateAgeGroupUseCase(sl()));
  sl.registerLazySingleton(()=>DeleteAgeGroupUseCase(sl()));
  sl.registerLazySingleton(()=>SetAgeGroupActiveUseCase(sl()));
  sl.registerFactory(()=>AgeGroupsListCubit(get:sl(),setActive:sl(),delete:sl(),flashMessages:sl()));
  sl.registerFactory(()=>AgeGroupFormCubit(create:sl(),update:sl(),flashMessages:sl()));
}
