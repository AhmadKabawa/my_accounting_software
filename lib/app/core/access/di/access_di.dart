import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/data/access_remote_data_source.dart';
import 'package:accounting_software/app/core/access/data/access_remote_data_source_impl.dart';
import 'package:accounting_software/app/core/access/data/access_repository_impl.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';

void initAccessDI() {
  sl.registerLazySingleton<AccessRemoteDataSource>(
    () => AccessRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AccessRepository>(
    () => AccessRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetMyAccessUseCase(sl()));
  sl.registerLazySingleton(() => AccessCubit(getMyAccess: sl()));
}
