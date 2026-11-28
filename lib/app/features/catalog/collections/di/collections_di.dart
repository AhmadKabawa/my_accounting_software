import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/storage/storage_image_uploader.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/collections/data/datasources/collections_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/collections/data/datasources/collections_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/collections/data/repositories/collections_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/repositories/collections_repository.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/get_collections_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/create_collection_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/update_collection_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/delete_collection_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/set_collection_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/upload_collection_image_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/cubit/collections_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/cubit/collections_form/collection_form_cubit.dart';

void initCollectionsDI() {
  sl.registerLazySingleton<CollectionsRemoteDataSource>(
    () => CollectionsRemoteDataSourceImpl(
      sl<IApiClient>(),
      sl<StorageImageUploader>(),
    ),
  );
  sl.registerLazySingleton<CollectionsRepository>(
    () => CollectionsRepositoryImpl(sl<CollectionsRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetCollectionsUseCase(sl()));
  sl.registerLazySingleton(() => CreateCollectionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCollectionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCollectionUseCase(sl()));
  sl.registerLazySingleton(() => SetCollectionActiveUseCase(sl()));
  sl.registerLazySingleton(() => UploadCollectionImageUseCase(sl()));
  sl.registerFactory(
    () => CollectionsListCubit(
      getItems: sl(),
      setActive: sl(),
      deleteItem: sl(),
      flashMessages: sl<FlashMessages>(),
    ),
  );
  sl.registerFactory(
    () => CollectionFormCubit(
      create: sl(),
      update: sl(),
      uploadImage: sl(),
      flashMessages: sl<FlashMessages>(),
    ),
  );
}
