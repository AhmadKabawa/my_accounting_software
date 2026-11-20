import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/data/datasources/brands_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/data/datasources/brands_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/data/repositories/brands_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/domain/repositories/brands_repository.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/create_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/update_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/upload_brand_logo_use_case.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_logo_upload_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_stats_cubit.dart';

void initCatalogDI() {
  sl.registerLazySingleton<BrandsRemoteDataSource>(
    () => BrandsRemoteDataSourceImpl(sl<IApiClient>()),
  );
  sl.registerLazySingleton<BrandsRepository>(
    () => BrandsRepositoryImpl(sl<BrandsRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetBrandsUseCase(sl()));
  sl.registerLazySingleton(() => CreateBrandUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBrandUseCase(sl()));
  sl.registerLazySingleton(() => SetBrandActiveUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBrandUseCase(sl()));
  sl.registerLazySingleton(() => UploadBrandLogoUseCase(sl()));

  sl.registerFactory(() => BrandStatsCubit(getBrands: sl()));
  sl.registerFactory(
    () => BrandsListCubit(
      getBrands: sl(),
      setBrandActive: sl(),
      deleteBrand: sl(),
    ),
  );
  sl.registerFactory(
    () => BrandLogoUploadCubit(uploadLogo: sl(), picker: sl()),
  );
  sl.registerFactory(
    () => BrandFormCubit(createBrand: sl(), updateBrand: sl()),
  );
}
