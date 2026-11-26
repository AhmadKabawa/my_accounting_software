import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_sets_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_sets_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/repositories/option_sets_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';

void initOptionSetsDI() {
  sl.registerLazySingleton<OptionSetsRemoteDataSource>(
    () => OptionSetsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<OptionSetsRepository>(
    () => OptionSetsRepositoryImpl(sl<OptionSetsRemoteDataSource>()),
  );
}
