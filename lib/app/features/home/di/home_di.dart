import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/home/data/repository/sample_home_repository.dart';
import 'package:accounting_software/app/features/home/domain/repository/home_repository.dart';
import 'package:accounting_software/app/features/home/domain/usecase/get_home_summary_usecase.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';

void initHomeDI() {
  // Placeholder data source: swap for the real aggregate when modules exist.
  sl.registerLazySingleton<HomeRepository>(() => const SampleHomeRepository());
  sl.registerLazySingleton(() => GetHomeSummaryUseCase(sl()));
  sl.registerFactory(
    () => HomeCubit(getSummary: sl(), flash: sl<FlashMessages>()),
  );
}
