import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required Future<void> Function() checkSession,
    Duration minDuration = const Duration(seconds: 2),
  }) : _checkSession = checkSession,
       _minDuration = minDuration,
       super(const SplashState.initial());

  final Future<void> Function() _checkSession;
  final Duration _minDuration;
  bool _started = false;

  /// Runs once: waits for the session check and the minimum splash time,
  /// then signals [SplashDone]. Later calls are ignored.
  Future<void> init() async {
    if (_started) return;
    _started = true;

    emit(const SplashState.loading());
    try {
      await Future.wait([_checkSession(), Future.delayed(_minDuration)]);
    } finally {
      emit(const SplashState.done());
    }
  }
}
