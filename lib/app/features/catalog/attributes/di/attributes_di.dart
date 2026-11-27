import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attributes_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attributes_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attribute_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attribute_stats_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/repositories/attributes_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attributes_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_unit_choices_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_option_set_choices_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/create_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/update_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/set_attribute_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/delete_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attributes_list/attributes_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_form/attribute_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_stats/attribute_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_lookups/attribute_lookups_cubit.dart';

void initAttributesDI() {
  sl.registerLazySingleton<AttributesRemoteDataSource>(
    () => AttributesRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<AttributeStatsRemoteDataSource>(
    () => AttributeStatsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<AttributesRepository>(
    () => AttributesRepositoryImpl(
      sl<AttributesRemoteDataSource>(),
      sl<AttributeStatsRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(() => GetAttributesUseCase(sl()));
  sl.registerLazySingleton(() => GetAttributeStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetAttributeUnitChoicesUseCase(sl()));
  sl.registerLazySingleton(() => GetAttributeOptionSetChoicesUseCase(sl()));
  sl.registerLazySingleton(() => CreateAttributeUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAttributeUseCase(sl()));
  sl.registerLazySingleton(() => SetAttributeActiveUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAttributeUseCase(sl()));
  sl.registerFactory(
    () => AttributesListCubit(
      getAttributes: sl(),
      setActive: sl(),
      deleteAttribute: sl(),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory(() => AttributeStatsCubit(getStats: sl()));
  sl.registerFactory(
    () => AttributeLookupsCubit(getUnits: sl(), getOptionSets: sl()),
  );
  sl.registerFactory(
    () => AttributeFormCubit(
      createAttribute: sl(),
      updateAttribute: sl(),
      flashMessages: sl(),
    ),
  );
}
