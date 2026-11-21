import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/colors/data/datasources/colors_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/colors/data/datasources/colors_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/colors/data/repositories/colors_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/repositories/colors_repository.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/create_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/get_colors_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/set_color_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/update_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_cubit.dart';

void initColorsDI() {
  sl.registerLazySingleton<ColorsRemoteDataSource>(
    () => ColorsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<ColorsRepository>(
    () => ColorsRepositoryImpl(sl<ColorsRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetColorsUseCase(sl()));
  sl.registerLazySingleton(() => CreateColorUseCase(sl()));
  sl.registerLazySingleton(() => UpdateColorUseCase(sl()));
  sl.registerLazySingleton(() => SetColorActiveUseCase(sl()));

  sl.registerFactory(
    () => ColorsListCubit(
      getColors: sl(),
      setColorActive: sl(),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory(
    () => ColorFormCubit(
      createColor: sl(),
      updateColor: sl(),
      flashMessages: sl(),
    ),
  );
}
