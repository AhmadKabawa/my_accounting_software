import 'dart:async';

import 'package:accounting_software/app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('init runs the session check once even when called twice', () async {
    var checks = 0;
    final cubit = SplashCubit(
      checkSession: () async => checks++,
      minDuration: Duration.zero,
    );

    await Future.wait([cubit.init(), cubit.init()]);
    await cubit.init();

    expect(checks, 1);
    expect(cubit.state, isA<SplashDone>());
  });

  test('done is emitted only after the session check completes', () async {
    final check = Completer<void>();
    final cubit = SplashCubit(
      checkSession: () => check.future,
      minDuration: Duration.zero,
    );

    final running = cubit.init();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isA<SplashLoading>());

    check.complete();
    await running;
    expect(cubit.state, isA<SplashDone>());
  });

  test('a failing session check still ends the splash after minDuration',
      () async {
    final cubit = SplashCubit(
      checkSession: () async => throw StateError('boom'),
      minDuration: const Duration(milliseconds: 50),
    );

    final watch = Stopwatch()..start();
    await cubit.init();
    watch.stop();

    expect(cubit.state, isA<SplashDone>());
    expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(45));
  });
}
