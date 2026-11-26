import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/units/data/datasources/units_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/units/data/datasources/units_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/units/data/datasources/unit_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/units/data/datasources/unit_stats_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/units/data/repositories/units_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/units/domain/repositories/units_repository.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/create_unit_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/delete_unit_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/get_units_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/get_unit_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/set_unit_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/update_unit_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/units_list/units_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/unit_form/unit_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/unit_stats/unit_stats_cubit.dart';

void initUnitsDI() {
  sl.registerLazySingleton<UnitsRemoteDataSource>(
    () => UnitsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<UnitStatsRemoteDataSource>(
    () => UnitStatsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<UnitsRepository>(
    () => UnitsRepositoryImpl(
      sl<UnitsRemoteDataSource>(),
      sl<UnitStatsRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(() => GetUnitsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnitStatsUseCase(sl()));
  sl.registerLazySingleton(() => CreateUnitUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUnitUseCase(sl()));
  sl.registerLazySingleton(() => SetUnitActiveUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUnitUseCase(sl()));
  sl.registerFactory(
    () =>
        UnitFormCubit(createUnit: sl(), updateUnit: sl(), flashMessages: sl()),
  );
  sl.registerFactory(() => UnitStatsCubit(getUnitStats: sl()));
  sl.registerFactory(
    () => UnitsListCubit(
      getUnits: sl(),
      setUnitActive: sl(),
      deleteUnit: sl(),
      flashMessages: sl(),
    ),
  );
}
