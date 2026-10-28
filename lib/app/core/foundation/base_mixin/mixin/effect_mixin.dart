// core/base/effect_mixin.dart

import 'dart:async';
import 'dart:collection';

abstract class HasEffects<E> {
  Stream<E> get effectStream;
  void emitEffect(E effect);
}

/// One-time UI effects (messages, navigation).
///
/// The stream is broadcast, so an effect emitted while nobody listens would be
/// lost. Such effects are held and delivered, once and in order, to the next
/// subscriber.
mixin EffectMixin<E> {
  late final _effectController = StreamController<E>.broadcast(
    onListen: _flushPending,
  );
  final Queue<E> _pending = Queue();

  @override
  Stream<E> get effectStream => _effectController.stream;

  void emitEffect(E effect) {
    if (_effectController.isClosed) return;
    if (_effectController.hasListener) {
      _effectController.add(effect);
    } else {
      _pending.add(effect);
    }
  }

  void _flushPending() {
    while (_pending.isNotEmpty) {
      _effectController.add(_pending.removeFirst());
    }
  }

  Future<void> disposeEffects() async {
    _pending.clear();
    await _effectController.close();
  }
}
