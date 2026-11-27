import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/genders/data/datasources/genders_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/genders/data/datasources/genders_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/genders/data/datasources/gender_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/genders/data/datasources/gender_stats_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/genders/data/repositories/genders_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/repositories/genders_repository.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/create_gender_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/delete_gender_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/get_gender_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/get_genders_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/set_gender_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/update_gender_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/gender_form/gender_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/genders_list/genders_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/gender_stats/gender_stats_cubit.dart';

void initGendersDI() {
  sl.registerLazySingleton<GendersRemoteDataSource>(
    () => GendersRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<GenderStatsRemoteDataSource>(
    () => GenderStatsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<GendersRepository>(
    () => GendersRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetGendersUseCase(sl()));
  sl.registerLazySingleton(() => GetGenderStatsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteGenderUseCase(sl()));
  sl.registerLazySingleton(() => CreateGenderUseCase(sl()));
  sl.registerLazySingleton(() => UpdateGenderUseCase(sl()));
  sl.registerLazySingleton(() => SetGenderActiveUseCase(sl()));
  sl.registerFactory(
    () => GendersListCubit(
      get: sl(),
      setActive: sl(),
      delete: sl(),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory(() => GenderStatsCubit(getStats: sl()));
  sl.registerFactory(
    () => GenderFormCubit(create: sl(), update: sl(), flashMessages: sl()),
  );
}
