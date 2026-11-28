import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/datasources/seasons_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/datasources/seasons_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/seasons/data/repositories/seasons_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/repositories/seasons_repository.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/usecase/get_seasons_use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/usecase/create_season_use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/usecase/update_season_use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/usecase/delete_season_use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/usecase/set_season_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/cubit/seasons_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/cubit/seasons_form/season_form_cubit.dart';

void initSeasonsDI() {
  sl.registerLazySingleton<SeasonsRemoteDataSource>(
    () => SeasonsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<SeasonsRepository>(
    () => SeasonsRepositoryImpl(sl<SeasonsRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetSeasonsUseCase(sl()));
  sl.registerLazySingleton(() => CreateSeasonUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSeasonUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSeasonUseCase(sl()));
  sl.registerLazySingleton(() => SetSeasonActiveUseCase(sl()));
  sl.registerFactory(
    () => SeasonsListCubit(
      getItems: sl(),
      setActive: sl(),
      deleteItem: sl(),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory(
    () => SeasonFormCubit(create: sl(), update: sl(), flashMessages: sl()),
  );
}
