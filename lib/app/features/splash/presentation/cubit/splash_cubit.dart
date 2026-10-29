import 'package:accounting_software/app/core/utils/logger.dart';
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
  ///
  /// A failing check is logged and does not abort the splash: the check is
  /// responsible for leaving the session in a definite state (AuthCubit falls
  /// back to Unauthenticated), and the minimum duration is still honoured.
  Future<void> init() async {
    if (_started) return;
    _started = true;

    emit(const SplashState.loading());
    await Future.wait([_runCheck(), Future<void>.delayed(_minDuration)]);
    emit(const SplashState.done());
  }

  Future<void> _runCheck() async {
    try {
      await _checkSession();
    } catch (e, st) {
      Logger.error(
        'Splash: session check failed',
        error: e,
        stackTrace: st,
        name: 'SplashCubit',
      );
    }
  }
}
