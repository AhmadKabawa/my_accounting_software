// core/base/effect_mixin.dart

import 'dart:async';
import 'dart:collection';

abstract class HasEffects<E> {
  Stream<E> get effectStream;
  void emitEffect(E effect, {bool replayable = false});
}

/// One-time UI effects (messages, navigation).
///
/// The stream is broadcast, so an effect emitted while nobody listens would be
/// lost. Only effects marked `replayable` are held for the next subscriber,
/// because most effects belong to the screen that triggered them: a
/// "wrong password" message must never surface later on an unrelated screen.
/// Use `replayable: true` for effects that stay true whoever shows them
/// (e.g. "your session expired"). A held effect is dropped once it is older
/// than [replayWindow].
mixin EffectMixin<E> {
  late final _effectController = StreamController<E>.broadcast(
    onListen: _flushPending,
  );
  final Queue<_PendingEffect<E>> _pending = Queue();

  /// How long a replayable effect waits for a listener before being dropped.
  Duration get replayWindow => const Duration(seconds: 5);

  @override
  Stream<E> get effectStream => _effectController.stream;

  void emitEffect(E effect, {bool replayable = false}) {
    if (_effectController.isClosed) return;
    if (_effectController.hasListener) {
      _effectController.add(effect);
    } else if (replayable) {
      _pending.add(_PendingEffect(effect, DateTime.now()));
    }
  }

  void _flushPending() {
    final now = DateTime.now();
    while (_pending.isNotEmpty) {
      final item = _pending.removeFirst();
      if (now.difference(item.at) <= replayWindow) {
        _effectController.add(item.effect);
      }
    }
  }

  Future<void> disposeEffects() async {
    _pending.clear();
    await _effectController.close();
  }
}

class _PendingEffect<E> {
  const _PendingEffect(this.effect, this.at);
  final E effect;
  final DateTime at;
}
