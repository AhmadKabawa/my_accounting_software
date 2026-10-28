import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/exceptions.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_service.dart';

class SecureStorageService implements StorageService {
  final FlutterSecureStorage _secureStorage;

  SecureStorageService({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  // ─── الكتابة (تحويل كل شيء إلى String) ─────────────────────────────────────
  @override
  Future<void> write<T>(StorageKey key, T value) async {
    try {
      final stringValue = switch (value) {
        String() => value,
        bool() || int() || double() => value.toString(),
        List<dynamic>() || Map<dynamic, dynamic>() => jsonEncode(value),
        _ => throw CacheException(
          message:
              'SecureStorage only supports: String, bool, int, double, '
              'List, Map. Got: ${value.runtimeType}',
        ),
      };

      await _secureStorage.write(key: key.toStringKey(), value: stringValue);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message:
            'Failed to write to secure storage. Key: ${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }

  // ─── القراءة (تحويل من String إلى النوع المطلوب) ───────────────────────────
  @override
  Future<T?> read<T>(StorageKey key) async {
    try {
      final stringValue = await _secureStorage.read(key: key.toStringKey());

      if (stringValue == null) return null;

      // محاولة تحويل إلى النوع المطلوب
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

      throw CacheException(
        message: 'Type $T is not supported by SecureStorage',
      );
    } on FormatException catch (e) {
      throw CacheException(
        message:
            'Failed to parse ${key.toStringKey()} value to type $T. Error: ${e.toString()}',
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message:
            'Failed to read from secure storage. Key: ${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }

  // ─── الحذف ─────────────────────────────────────────────────────────────────
  @override
  Future<void> delete(StorageKey key) async {
    try {
      await _secureStorage.delete(key: key.toStringKey());
    } catch (e) {
      throw CacheException(
        message:
            'Failed to delete from secure storage. Key: ${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }

  // ─── مسح الكل ──────────────────────────────────────────────────────────────
  @override
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear secure storage. Error: ${e.toString()}',
      );
    }
  }

  // ─── التحقق من وجود مفتاح ───────────────────────────────────────────────────
  @override
  Future<bool> containsKey(StorageKey key) async {
    try {
      return await _secureStorage.containsKey(key: key.toStringKey());
    } catch (e) {
      throw CacheException(
        message:
            'Failed to check key in secure storage. Key: ${key.toStringKey()}, Error: ${e.toString()}',
      );
    }
  }
}
