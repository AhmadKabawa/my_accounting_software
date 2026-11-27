import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attributes_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attributes_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/repositories/attributes_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/repositories/attributes_repository.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attributes_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/create_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/update_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/set_attribute_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attributes_list/attributes_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_form/attribute_form_cubit.dart';

void initAttributesDI() {
  sl.registerLazySingleton<AttributesRemoteDataSource>(
    () => AttributesRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<AttributesRepository>(
    () => AttributesRepositoryImpl(sl<AttributesRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetAttributesUseCase(sl()));
  sl.registerLazySingleton(() => CreateAttributeUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAttributeUseCase(sl()));
  sl.registerLazySingleton(() => SetAttributeActiveUseCase(sl()));
  sl.registerFactory(() => AttributesListCubit(getAttributes: sl(), setActive: sl(), flashMessages: sl()));
  sl.registerFactory(() => AttributeFormCubit(createAttribute: sl(), updateAttribute: sl(), flashMessages: sl()));
}
