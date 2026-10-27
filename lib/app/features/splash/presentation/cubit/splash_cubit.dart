import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState.initial());

  Future<void> init() async {
    if (state is SplashDone) return;
    await Future.delayed(const Duration(seconds: 2));
    emit(const SplashState.done());
  }
}
