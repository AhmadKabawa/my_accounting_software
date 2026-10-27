import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';


void initHomeDI() {
  // splash Feature
  // cubit
  sl.registerFactory(() => HomeCubit());
}
