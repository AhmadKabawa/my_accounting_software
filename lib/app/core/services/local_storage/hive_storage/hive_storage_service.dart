import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/exceptions.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_service.dart';

//للشي البسيط زي ال theme وال language ممكن SharedPreferences
class HiveStorageService implements StorageService {
  final Box<String> box;

  const HiveStorageService({required Box<String> box}) : box = box;

  // ─── الكتابة (تحويل كل شيء إلى String) ─────────────────────────────────────
  @override
  Future<void> write<T>(StorageKey key, T value) async {
    try {
      String stringValue;

      if (value is String) {
        stringValue = value;
      } else if (value is bool) {
        stringValue = value.toString();
      } else if (value is int) {
        stringValue = value.toString();
      } else if (value is double) {
        stringValue = value.toString();
      } else if (value is List<String>) {
        stringValue = jsonEncode(value);
      } else if (value is Map<String, dynamic>) {
        stringValue = jsonEncode(value);
      } else if (value is List<dynamic>) {
        stringValue = jsonEncode(value);
      } else if (value is Map<dynamic, dynamic>) {
        stringValue = jsonEncode(value);
      } else {
        throw CacheException(
          message:
              'HiveStorage only supports: String, bool, int, double, '
              'List, Map. Got: ${value.runtimeType}',
        );
      }

      await box.put(key.toStringKey(), stringValue);
    } catch (e) {
      if (e is CacheException) rethrow;

      throw CacheException(
        message:
            'Failed to write to Hive storage. '
            'Key: ${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }

  // ─── القراءة (تحويل من String إلى النوع المطلوب) ───────────────────────────
  @override
  Future<T?> read<T>(StorageKey key) async {
    try {
      final stringValue = box.get(key.toStringKey());

      if (stringValue == null) return null;

      if (T == String) {
        return stringValue as T;
      } else if (T == bool) {
        return (stringValue.toLowerCase() == 'true') as T;
      } else if (T == int) {
        return int.parse(stringValue) as T;
      } else if (T == double) {
        return double.parse(stringValue) as T;
      } else if (T == List<String>) {
        final List<dynamic> list = jsonDecode(stringValue);

        return list.map((e) => e.toString()).toList() as T;
      } else if (T == List<dynamic>) {
        return jsonDecode(stringValue) as T;
      } else if (T == Map<String, dynamic>) {
        return jsonDecode(stringValue) as T;
      } else if (T == Map<dynamic, dynamic>) {
        return jsonDecode(stringValue) as T;
      }

      throw CacheException(message: 'Type $T is not supported by HiveStorage');
    } on FormatException catch (e) {
      throw CacheException(
        message:
            'Failed to parse ${key.toStringKey()} '
            'value to type $T. Error: ${e.toString()}',
      );
    } catch (e) {
      if (e is CacheException) rethrow;

      throw CacheException(
        message:
            'Failed to read from Hive storage. '
            'Key: ${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }

  // ─── الحذف ─────────────────────────────────────────────────────────────────
  @override
  Future<void> delete(StorageKey key) async {
    try {
      await box.delete(key.toStringKey());
    } catch (e) {
      throw CacheException(
        message:
            'Failed to delete from Hive storage. '
            'Key: ${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }

  // ─── مسح الكل ──────────────────────────────────────────────────────────────
  @override
  Future<void> clearAll() async {
    try {
      await box.clear();
    } catch (e) {
      throw CacheException(
        message:
            'Failed to clear Hive storage. '
            'Error: ${e.toString()}',
      );
    }
  }

  // ─── التحقق من وجود مفتاح ───────────────────────────────────────────────────
  @override
  Future<bool> containsKey(StorageKey key) async {
    try {
      return box.containsKey(key.toStringKey());
    } catch (e) {
      throw CacheException(
        message:
            'Failed to check key in Hive storage. '
            'Key: ${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }

  // ─── Hive extras (اختياري) ────────────────────────────────────────────────

  List<String> get allValues => box.values.toList();

  Iterable<dynamic> get allKeys => box.keys;

  int get length => box.length;

  Stream<BoxEvent> watch(StorageKey key) {
    return box.watch(key: key.toStringKey());
  }

  Stream<BoxEvent> watchAll() {
    return box.watch();
  }
}
