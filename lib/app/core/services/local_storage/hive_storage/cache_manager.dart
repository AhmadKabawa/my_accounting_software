// 📁 lib/core/services/local_storage/hive_storage/managers/cache_manager.dart

import 'dart:convert';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/hive_object_box.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/hive_storage_service.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_keys.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';

class CacheManager {
  final HiveStorageService _stringCache;
  final HiveObjectBox<UserModel> _userBox;

  const CacheManager({
    required HiveStorageService stringCache,
    required HiveObjectBox<UserModel> userBox,
  }) : _stringCache = stringCache,
       _userBox = userBox;

  // ─── JSON Cache مع TTL ─────────────────────────────────────────────────────

  Future<void> cacheResponse({
    required StorageKey key,
    required Map<String, dynamic> data,
    Duration ttl = const Duration(hours: 1),
  }) async {
    final entry = _CacheEntry(data: data, expiresAt: DateTime.now().add(ttl));
    // نستخدم box مباشرة لأن المفتاح هنا String حر وليس StorageKey enum
    await _stringCache.box.put(key.toStringKey(), jsonEncode(entry.toJson()));
  }

  Map<String, dynamic>? getCachedResponse(StorageKey key) {
    final raw = _stringCache.box.get(key.toStringKey());
    if (raw == null) return null;

    try {
      final entry = _CacheEntry.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (entry.isExpired) {
        _stringCache.box.delete(key.toStringKey());
        return null;
      }
      return entry.data;
    } catch (_) {
      return null;
    }
  }

  bool isCacheValid(StorageKey key) => getCachedResponse(key) != null;

  // ─── User Cache ────────────────────────────────────────────────────────────

  static const _currentUserKey = StorageKeys.userData;

  Future<void> saveUser(UserModel user) => _userBox.put(_currentUserKey, user);
  UserModel? getUser() => _userBox.get(_currentUserKey);
  Future<void> clearUser() => _userBox.delete(_currentUserKey);
  bool hasUser() => _userBox.containsKey(_currentUserKey);

  // ─── Cleanup ───────────────────────────────────────────────────────────────

  Future<void> clearAll() =>
      Future.wait([_stringCache.clearAll(), _userBox.clear()]);

  Future<void> cleanExpired() async {
    final expired = _stringCache.allKeys.map((k) => k.toString()).where((key) {
      final raw = _stringCache.box.get(key);
      if (raw == null) return true;
      try {
        return _CacheEntry.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        ).isExpired;
      } catch (_) {
        return true;
      }
    }).toList();

    for (final key in expired) {
      await _stringCache.box.delete(key);
    }
  }
}

// ─── Private Helper ───────────────────────────────────────────────────────────
class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime expiresAt;

  const _CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'data': data,
    'expires_at': expiresAt.millisecondsSinceEpoch,
  };

  factory _CacheEntry.fromJson(Map<String, dynamic> json) => _CacheEntry(
    data: json['data'] as Map<String, dynamic>,
    expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expires_at'] as int),
  );
}
