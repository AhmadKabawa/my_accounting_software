// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📁 lib/core/services/local_storage/shared_storage/prefs_storage_service.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'package:accounting_software/app/core/error/error_handling/exceptions/exceptions.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage_service.dart';

class PrefsStorageService implements StorageService {
  final SharedPreferences prefs;

  const PrefsStorageService({required this.prefs});

  @override
  Future<void> write<T>(StorageKey key, T value) async {
    try {
      String keyString = key.toStringKey();
      if (value is String) {
        await prefs.setString(keyString, value);
      } else if (value is bool) {
        await prefs.setBool(keyString, value);
      } else if (value is int) {
        await prefs.setInt(keyString, value);
      } else if (value is double) {
        await prefs.setDouble(keyString, value);
      } else if (value is List<String>) {
        await prefs.setStringList(keyString, value);
      } else {
        throw CacheException(
          message:
              'Type ${value.runtimeType} is not supported. '
              'Supported types: String, bool, int, double, List<String>',
        );
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to write to cache. Key: $key, Error: ${e.toString()}',
      );
    }
  }

  @override
  Future<T?> read<T>(StorageKey key) async {
    try {
      final value = prefs.get(key.toStringKey());

      if (value == null) return null;

      if (T == String && value is String) return value as T;
      if (T == bool && value is bool) return value as T;
      if (T == int && value is int) return value as T;
      if (T == double && value is double) return value as T;
      if (T == (List<String>) && value is List<String>) return value as T;

      throw CacheException(
        message: 'Cannot read type $T. Value type is ${value.runtimeType}',
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message:
            'Failed to read from cache. Key: ${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> delete(StorageKey key) async {
    try {
      await prefs.remove(key.toStringKey());
    } catch (e) {
      throw CacheException(
        message:
            'Failed to delete from cache. Key:${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await prefs.clear();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear cache. Error: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> containsKey(StorageKey key) async {
    try {
      return prefs.containsKey(key.toStringKey());
    } catch (e) {
      throw CacheException(
        message:
            'Failed to check key in cache. Key: ${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }
}
