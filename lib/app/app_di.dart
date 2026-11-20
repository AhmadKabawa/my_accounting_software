import 'package:accounting_software/app/core/access/di/access_di.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/platform/image_picker/file_picker_image_picker.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/features/auth/data/auth_endpoints.dart';
import 'package:accounting_software/app/features/auth/di/auth_di.dart';
import 'package:accounting_software/app/features/catalog/di/catalog_di.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/on_boarding/di/on_boarding_di.dart';
import 'package:accounting_software/app/features/splash/di/splash_di.dart';

/// Composition root: infrastructure first, then core access and features.
Future<void> initServiceLocator() async {
  await initCoreDI(refreshEndpoint: AuthEndpoints.token);
  initAccessDI();
  await initAuthStorage();
  initAuthDI();
  sl.registerLazySingleton<ImagePickerPort>(() => const FilePickerImagePicker());
  initCatalogDI();
  initOnBoardingDI();
  initSplashDI(checkSession: sl<SessionCubit>().checkAuthentication);
}
