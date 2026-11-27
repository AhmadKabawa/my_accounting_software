import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/datasources/product_types_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/datasources/product_types_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/repositories/product_types_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/datasources/product_type_links_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/datasources/product_type_links_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/repositories/product_type_links_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_type_links_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_types_list/product_types_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_form/product_type_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_stats/product_type_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_details/product_type_details_cubit.dart';

void initProductTypesDI() {
  sl.registerLazySingleton<ProductTypesRemoteDataSource>(
    () => ProductTypesRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<ProductTypeLinksRemoteDataSource>(
    () => ProductTypeLinksRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<ProductTypeLinksRepository>(
    () =>
        ProductTypeLinksRepositoryImpl(sl<ProductTypeLinksRemoteDataSource>()),
  );
  sl.registerFactory(
    () => ProductTypeDetailsCubit(
      repository: sl<ProductTypeLinksRepository>(),
      productTypesRepository: sl<ProductTypesRepository>(),
    ),
  );
  sl.registerLazySingleton<ProductTypesRepository>(
    () => ProductTypesRepositoryImpl(sl<ProductTypesRemoteDataSource>()),
  );
  sl.registerFactory(
    () => ProductTypeStatsCubit(repository: sl<ProductTypesRepository>()),
  );
  sl.registerFactory(
    () => ProductTypeFormCubit(
      repository: sl<ProductTypesRepository>(),
      flashMessages: sl<FlashMessages>(),
    ),
  );
  sl.registerFactory(
    () => ProductTypesListCubit(
      repository: sl<ProductTypesRepository>(),
      flashMessages: sl<FlashMessages>(),
    ),
  );
}
