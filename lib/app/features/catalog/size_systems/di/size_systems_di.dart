import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/data/datasources/size_groups_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/data/datasources/size_groups_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/data/repositories/size_groups_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/repositories/size_groups_repository.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/usecase/size_groups_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/gender_options/gender_options_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/size_group_form/size_group_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/size_groups_list/size_groups_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/datasources/sizes_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/datasources/sizes_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/repositories/sizes_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/repositories/sizes_repository.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/usecase/sizes_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/size_form/size_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/size_range/size_range_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/sizes_list/sizes_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/data/datasources/size_systems_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/data/datasources/size_systems_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/data/repositories/size_systems_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/repositories/size_systems_repository.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/usecase/size_systems_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_system_form/size_system_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_system_stats/size_system_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_systems_list/size_systems_list_cubit.dart';

void initSizeSystemsDI() {
  _initSystems();
  _initGroups();
  _initSizes();
}

void _initSystems() {
  sl.registerLazySingleton<SizeSystemsRemoteDataSource>(
    () => SizeSystemsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<SizeSystemsRepository>(
    () => SizeSystemsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetSizeSystemsUseCase(sl()));
  sl.registerLazySingleton(() => GetSizeSystemStatsUseCase(sl()));
  sl.registerLazySingleton(() => CreateSizeSystemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSizeSystemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSizeSystemUseCase(sl()));
  sl.registerLazySingleton(() => SetSizeSystemActiveUseCase(sl()));
  sl.registerFactory(
    () => SizeSystemsListCubit(
      get: sl(),
      setActive: sl(),
      delete: sl(),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory(() => SizeSystemStatsCubit(getStats: sl()));
  sl.registerFactory(
    () => SizeSystemFormCubit(create: sl(), update: sl(), flashMessages: sl()),
  );
}

void _initGroups() {
  sl.registerLazySingleton<SizeGroupsRemoteDataSource>(
    () => SizeGroupsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<SizeGroupsRepository>(
    () => SizeGroupsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetSizeGroupsUseCase(sl()));
  sl.registerLazySingleton(() => GetGenderOptionsUseCase(sl()));
  sl.registerLazySingleton(() => CreateSizeGroupUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSizeGroupUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSizeGroupUseCase(sl()));
  sl.registerLazySingleton(() => SetSizeGroupActiveUseCase(sl()));
  sl.registerFactoryParam<SizeGroupsListCubit, int, void>(
    (systemId, _) => SizeGroupsListCubit(
      sizeSystemId: systemId,
      get: sl(),
      setActive: sl(),
      delete: sl(),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory(() => GenderOptionsCubit(getGenders: sl()));
  sl.registerFactory(
    () => SizeGroupFormCubit(create: sl(), update: sl(), flashMessages: sl()),
  );
}

void _initSizes() {
  sl.registerLazySingleton<SizesRemoteDataSource>(
    () => SizesRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<SizesRepository>(() => SizesRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetSizesUseCase(sl()));
  sl.registerLazySingleton(() => CreateSizeUseCase(sl()));
  sl.registerLazySingleton(() => CreateSizesBatchUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSizeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSizeUseCase(sl()));
  sl.registerLazySingleton(() => SetSizeActiveUseCase(sl()));
  sl.registerFactoryParam<SizesListCubit, int, void>(
    (groupId, _) => SizesListCubit(
      sizeGroupId: groupId,
      get: sl(),
      setActive: sl(),
      delete: sl(),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory(
    () => SizeFormCubit(create: sl(), update: sl(), flashMessages: sl()),
  );
  sl.registerFactory(
    () => SizeRangeCubit(createBatch: sl(), flashMessages: sl()),
  );
}
