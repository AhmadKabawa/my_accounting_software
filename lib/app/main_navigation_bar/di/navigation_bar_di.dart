import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/main_navigation_bar/presentation/cubit/main_navigation_bar_cubit.dart';


void initNavigationBarDI() {
  // splash Feature
  // cubit
  sl.registerFactory(() => MainNavigationBarCubit());
}
