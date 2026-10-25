import 'package:get_it/get_it.dart';
import 'package:accounting_software/app/main_navigation_bar/presentation/cubit/main_navigation_bar_cubit.dart';

final sl = GetIt.instance;

void initNavigationBarDI() {
  // splash Feature
  // cubit
  sl.registerFactory(() => MainNavigationBarCubit());
}
