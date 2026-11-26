import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_sets_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_sets_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_set_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_set_stats_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/repositories/option_sets_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_option_sets_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/create_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/update_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_option_set_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/delete_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/set_option_set_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_options_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/create_option_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/update_option_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/set_option_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_sets_list/option_sets_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_stats/option_set_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_form/option_set_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_options/option_set_options_cubit.dart';

void initOptionSetsDI() {
  sl.registerLazySingleton<OptionSetsRemoteDataSource>(
    () => OptionSetsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<OptionSetStatsRemoteDataSource>(
    () => OptionSetStatsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<OptionSetsRepository>(
    () => OptionSetsRepositoryImpl(
      sl<OptionSetsRemoteDataSource>(),
      sl<OptionSetStatsRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(() => GetOptionSetsUseCase(sl()));
  sl.registerLazySingleton(() => CreateOptionSetUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOptionSetUseCase(sl()));
  sl.registerLazySingleton(() => GetOptionSetStatsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteOptionSetUseCase(sl()));
  sl.registerLazySingleton(() => SetOptionSetActiveUseCase(sl()));
  sl.registerLazySingleton(() => GetOptionsUseCase(sl()));
  sl.registerLazySingleton(() => CreateOptionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOptionUseCase(sl()));
  sl.registerLazySingleton(() => SetOptionActiveUseCase(sl()));
  sl.registerFactory(() => OptionSetStatsCubit(getStats: sl()));
  sl.registerFactory(
    () => OptionSetFormCubit(create: sl(), update: sl(), flashMessages: sl()),
  );
  sl.registerFactory(
    () => OptionSetOptionsCubit(
      getOptions: sl(),
      createOption: sl(),
      updateOption: sl(),
      setOptionActive: sl(),
    ),
  );
  sl.registerFactory(
    () => OptionSetsListCubit(
      getOptionSets: sl(),
      setActive: sl(),
      deleteOptionSet: sl(),
      flashMessages: sl(),
    ),
  );
}
