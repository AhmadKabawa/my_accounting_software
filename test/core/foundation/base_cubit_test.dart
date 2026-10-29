import 'package:accounting_software/app/core/foundation/base_mixin/base/base_cubit/base_side_effects/base_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterCubit extends BaseCubit<int, String> {
  _CounterCubit() : super(0);

  void increment() {
    emit(state + 1);
    emitEffect('incremented to $state');
  }
}

Future<void> pump() => Future<void>.delayed(Duration.zero);

void main() {
  late _CounterCubit cubit;

  setUp(() => cubit = _CounterCubit());
  tearDown(() => cubit.close());

  test('state changes and effects are independent streams', () async {
    final states = <int>[];
    final effects = <String>[];
    cubit.stream.listen(states.add);
    cubit.effectStream.listen(effects.add);

    cubit.increment();
    await pump();

    expect(states, [1]);
    expect(effects, ['incremented to 1']);
  });

  test('a replayable effect emitted before the UI subscribes is not lost',
      () async {
    cubit.emitEffect('session expired', replayable: true);

    final effects = <String>[];
    cubit.effectStream.listen(effects.add);
    await pump();

    expect(effects, ['session expired']);
  });

  test('an ordinary effect emitted with no listener is dropped', () async {
    cubit.increment();

    final effects = <String>[];
    cubit.effectStream.listen(effects.add);
    await pump();

    expect(effects, isEmpty);
  });

  test('close completes the effect stream', () async {
    var done = false;
    cubit.effectStream.listen((_) {}, onDone: () => done = true);

    await cubit.close();
    await pump();

    expect(done, isTrue);
  });

  test('emitting an effect after close does not throw', () async {
    await cubit.close();

    expect(() => cubit.emitEffect('late'), returnsNormally);
  });
}
