import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/tags/data/datasources/tags_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/tags/data/datasources/tag_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/tags/data/datasources/tag_stats_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/tags/data/datasources/tags_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/tags/data/repositories/tags_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/repositories/tags_repository.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/create_tag_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/delete_tag_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/get_tag_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/get_tags_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/set_tag_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/update_tag_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tag_form/tag_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tags_list/tags_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tag_stats/tag_stats_cubit.dart';

void initTagsDI() {
  sl.registerLazySingleton<TagsRemoteDataSource>(
    () => TagsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<TagStatsRemoteDataSource>(
    () => TagStatsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<TagsRepository>(
    () => TagsRepositoryImpl(
      sl<TagsRemoteDataSource>(),
      sl<TagStatsRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton(() => GetTagsUseCase(sl()));
  sl.registerLazySingleton(() => GetTagStatsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTagUseCase(sl()));
  sl.registerLazySingleton(() => CreateTagUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTagUseCase(sl()));
  sl.registerLazySingleton(() => SetTagActiveUseCase(sl()));

  sl.registerFactory(
    () => TagsListCubit(
      getTags: sl(),
      setTagActive: sl(),
      deleteTag: sl(),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory(() => TagStatsCubit(getTagStats: sl()));
  sl.registerFactory(
    () => TagFormCubit(createTag: sl(), updateTag: sl(), flashMessages: sl()),
  );
}
