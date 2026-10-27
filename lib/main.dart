import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app.dart';
import 'package:accounting_software/app/core/utils/observer/app_bloc_observer.dart';
import 'package:accounting_software/app/core/foundation/localization/cubit/locale_cubit.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/asset_loader.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/hive_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // .env is optional: values fall back to EnvConfig defaults when it is absent.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('No .env file loaded: $e');
  }
  await HiveManager.init();
  Bloc.observer = AppBlocObserver();
  // await SupabaseService.initialize();

  // di
  await initServiceLocator();

  runApp(
    EasyLocalization(
      saveLocale: true, // 🔥 هذا هو المهم
      path: 'assets/translations', // مكان ملفات الترجمة
      supportedLocales: LocaleCubit.supportedLocales,
      fallbackLocale: LocaleCubit.fallbackLocale,
      assetLoader: const MyDartLoader(),
      // startLocale: localeState.locale,
      child: const MyApp(),
    ),
  );
}
