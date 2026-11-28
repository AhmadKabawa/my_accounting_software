import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/datasources/care_instructions_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/datasources/care_instructions_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/data/repositories/care_instructions_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/repositories/care_instructions_repository.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/get_care_instructions_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/create_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/update_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/delete_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/set_care_instruction_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instructions_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instruction_form_cubit.dart';

void initCareInstructionsDI() {
  sl.registerLazySingleton<CareInstructionsRemoteDataSource>(() => CareInstructionsRemoteDataSourceImpl(sl<IApiClient>()));
  sl.registerLazySingleton<CareInstructionsRepository>(() => CareInstructionsRepositoryImpl(sl<CareInstructionsRemoteDataSource>()));
  sl.registerLazySingleton(() => GetCareInstructionsUseCase(sl()));
  sl.registerLazySingleton(() => CreateCareInstructionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCareInstructionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCareInstructionUseCase(sl()));
  sl.registerLazySingleton(() => SetCareInstructionActiveUseCase(sl()));
  sl.registerFactory(() => CareInstructionsListCubit(
    getItems: sl(), setActive: sl(), deleteItem: sl(), flashMessages: sl(),
  ));
  sl.registerFactory(() => CareInstructionFormCubit(create: sl(), update: sl(), flashMessages: sl()));
}
