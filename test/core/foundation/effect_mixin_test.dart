import 'dart:async';

import 'package:accounting_software/app/core/foundation/base_mixin/mixin/effect_mixin.dart';
import 'package:flutter_test/flutter_test.dart';

class _Probe with EffectMixin<int> {
  @override
  Duration get replayWindow => const Duration(milliseconds: 50);
}

Future<void> pump() => Future<void>.delayed(Duration.zero);

void main() {
  late _Probe probe;

  setUp(() => probe = _Probe());
  tearDown(() => probe.disposeEffects());

  test('replayable effects emitted before any listener arrive in order',
      () async {
    probe
      ..emitEffect(1, replayable: true)
      ..emitEffect(2, replayable: true);

    final received = <int>[];
    probe.effectStream.listen(received.add);
    await pump();

    expect(received, [1, 2]);
  });

  test('a delivered effect is never replayed to a later listener', () async {
    probe.emitEffect(1, replayable: true);
    final first = <int>[];
    final sub = probe.effectStream.listen(first.add);
    await pump();
    await sub.cancel();

    final second = <int>[];
    probe.effectStream.listen(second.add);
    await pump();

    expect(first, [1]);
    expect(second, isEmpty);
  });

  test('effects emitted between two listeners are not lost', () async {
    final sub = probe.effectStream.listen((_) {});
    await sub.cancel();

    probe.emitEffect(7, replayable: true);

    final received = <int>[];
    probe.effectStream.listen(received.add);
    await pump();

    expect(received, [7]);
  });

  test('a non-replayable effect is dropped when nobody listens', () async {
    probe.emitEffect(9);

    final received = <int>[];
    probe.effectStream.listen(received.add);
    await pump();

    expect(received, isEmpty);
  });

  test('a replayable effect older than the replay window is dropped',
      () async {
    probe.emitEffect(4, replayable: true);
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final received = <int>[];
    probe.effectStream.listen(received.add);
    await pump();

    expect(received, isEmpty);
  });

  test('with a listener attached effects go straight through', () async {
    final received = <int>[];
    probe.effectStream.listen(received.add);

    probe.emitEffect(3);
    await pump();

    expect(received, [3]);
  });

  test('two live listeners both receive a new effect once', () async {
    final a = <int>[];
    final b = <int>[];
    probe.effectStream.listen(a.add);
    probe.effectStream.listen(b.add);

    probe.emitEffect(5);
    await pump();

    expect([a, b], [
      [5],
      [5],
    ]);
  });

  test('emitting after dispose is ignored', () async {
    await probe.disposeEffects();
    expect(() => probe.emitEffect(1), returnsNormally);
  });
}
