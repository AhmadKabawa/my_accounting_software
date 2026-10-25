// 📁 hive_object_box.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';

class HiveObjectBox<T> {
  final Box<T> _box;

  const HiveObjectBox(this._box);

  // ─── Write ─────────────────────────────────────────────────

  Future<void> put(StorageKey key, T value) {
    return _box.put(key.toStringKey(), value);
  }

  Future<void> putAll(Map<StorageKey, T> entries) {
    final mapped = {
      for (final entry in entries.entries) entry.key.toStringKey(): entry.value,
    };

    return _box.putAll(mapped);
  }

  /// auto-increment key
  Future<int> add(T value) {
    return _box.add(value);
  }

  // ─── Read ──────────────────────────────────────────────────

  T? get(StorageKey key, {T? defaultValue}) {
    return _box.get(key.toStringKey(), defaultValue: defaultValue);
  }

  List<T> getAll() {
    return _box.values.toList();
  }

  List<T?> getMany(List<StorageKey> keys) {
    return keys.map((k) => _box.get(k.toStringKey())).toList();
  }

  // ─── Delete ────────────────────────────────────────────────

  Future<void> delete(StorageKey key) {
    return _box.delete(key.toStringKey());
  }

  Future<int> clear() {
    return _box.clear();
  }

  // ─── Query ─────────────────────────────────────────────────

  bool containsKey(StorageKey key) {
    return _box.containsKey(key.toStringKey());
  }

  int get length => _box.length;

  bool get isEmpty => _box.isEmpty;

  bool get isNotEmpty => _box.isNotEmpty;

  List<T> where(bool Function(T) test) {
    return _box.values.where(test).toList();
  }

  T? firstWhere(bool Function(T) test) {
    try {
      return _box.values.firstWhere(test);
    } catch (_) {
      return null;
    }
  }

  // ─── Reactive ──────────────────────────────────────────────

  ValueListenable<Box<T>> listenable({List<StorageKey>? keys}) {
    return _box.listenable(keys: keys?.map((k) => k.toStringKey()).toList());
  }

  Stream<BoxEvent> watch([StorageKey? key]) {
    return _box.watch(key: key?.toStringKey());
  }

  // ─── Optional helper ───────────────────────────────────────

  Box<T> get rawBox => _box;
}
