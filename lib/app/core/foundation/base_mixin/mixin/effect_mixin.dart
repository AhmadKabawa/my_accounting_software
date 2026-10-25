// core/base/effect_mixin.dart

import 'dart:async';
import 'dart:collection';



abstract class HasEffects<E> {
  Stream<E> get effectStream;
  void emitEffect(E effect);
}

mixin EffectMixin<E> {
  final _effectController = StreamController<E>.broadcast();
  final Queue<E> _effectQueue = Queue();

  @override
  Stream<E> get effectStream => _effectController.stream;

  void emitEffect(E effect) {
    if (!_effectController.isClosed) {
      _effectQueue.add(effect);
      _processQueue();
    }
  }

  void _processQueue() {
    if (_effectQueue.isEmpty) return;

    final effect = _effectQueue.removeFirst();
    _effectController.add(effect);
  }

  Future<void> disposeEffects() async {
    await _effectController.close();
  }
}