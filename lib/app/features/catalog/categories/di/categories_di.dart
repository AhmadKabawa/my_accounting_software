import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/categories/data/datasources/categories_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/categories/data/datasources/categories_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/categories/data/repositories/categories_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/repositories/categories_repository.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/create_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/delete_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/get_categories_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/set_category_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/usecase/update_category_use_case.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/categories_list/categories_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/cubit/category_form/category_form_cubit.dart';

class CategoryFormArgs {
  const CategoryFormArgs({this.category, this.tree, this.initialParentId});

  final Category? category;
  final CategoryTree? tree;
  final int? initialParentId;
}

void initCategoriesDI() {
  sl.registerLazySingleton<CategoriesRemoteDataSource>(
    () => CategoriesRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(sl<CategoriesRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => SetCategoryActiveUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));

  sl.registerFactory(
    () => CategoriesListCubit(
      getCategories: sl(),
      setCategoryActive: sl(),
      deleteCategory: sl(),
      flashMessages: sl<FlashMessages>(),
    ),
  );
  sl.registerFactoryParam<CategoryFormCubit, CategoryFormArgs, void>(
    (args, _) => CategoryFormCubit(
      createCategory: sl(),
      updateCategory: sl(),
      flashMessages: sl<FlashMessages>(),
      category: args.category,
      tree: args.tree,
      initialParentId: args.initialParentId,
    ),
  );
}
