import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/datasources/fabric_types_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/datasources/fabric_types_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/repositories/fabric_types_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/repositories/fabric_types_repository.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/get_fabric_types_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/create_fabric_type_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/update_fabric_type_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/delete_fabric_type_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/usecase/set_fabric_type_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/cubit/fabric_types_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/cubit/fabric_types_form/fabric_type_form_cubit.dart';

void initFabricTypesDI() {
  sl.registerLazySingleton<FabricTypesRemoteDataSource>(
    () => FabricTypesRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<FabricTypesRepository>(
    () => FabricTypesRepositoryImpl(sl<FabricTypesRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetFabricTypesUseCase(sl()));
  sl.registerLazySingleton(() => CreateFabricTypeUseCase(sl()));
  sl.registerLazySingleton(() => UpdateFabricTypeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteFabricTypeUseCase(sl()));
  sl.registerLazySingleton(() => SetFabricTypeActiveUseCase(sl()));
  sl.registerFactory(
    () => FabricTypesListCubit(
      getItems: sl(),
      setActive: sl(),
      deleteItem: sl(),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory(
    () => FabricTypeFormCubit(create: sl(), update: sl(), flashMessages: sl()),
  );
}
