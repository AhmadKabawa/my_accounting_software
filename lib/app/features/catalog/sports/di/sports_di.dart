import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/sports/data/datasources/sports_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/sports/data/datasources/sport_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/sports/data/datasources/sport_stats_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/sports/data/datasources/sports_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/sports/data/repositories/sports_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/repositories/sports_repository.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/create_sport_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/delete_sport_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/get_sport_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/get_sports_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/set_sport_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/update_sport_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sport_form/sport_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sports_list/sports_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sport_stats/sport_stats_cubit.dart';

void initSportsDI() {
  sl.registerLazySingleton<SportsRemoteDataSource>(
    () => SportsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<SportStatsRemoteDataSource>(
    () => SportStatsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<SportsRepository>(
    () => SportsRepositoryImpl(
      sl<SportsRemoteDataSource>(),
      sl<SportStatsRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton(() => GetSportsUseCase(sl()));
  sl.registerLazySingleton(() => GetSportStatsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSportUseCase(sl()));
  sl.registerLazySingleton(() => CreateSportUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSportUseCase(sl()));
  sl.registerLazySingleton(() => SetSportActiveUseCase(sl()));

  sl.registerFactory(
    () => SportsListCubit(
      getSports: sl(),
      setSportActive: sl(),
      deleteSport: sl(),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory(() => SportStatsCubit(getSportStats: sl()));
  sl.registerFactory(
    () => SportFormCubit(
      createSport: sl(),
      updateSport: sl(),
      flashMessages: sl(),
    ),
  );
}
