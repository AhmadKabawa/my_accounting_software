import 'package:get_it/get_it.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/main_navigation_bar/presentation/cubit/main_navigation_bar_cubit.dart';

final sl = GetIt.instance;

void initHomeDI() {
  // splash Feature
  // cubit
  sl.registerFactory(() => HomeCubit());
}
