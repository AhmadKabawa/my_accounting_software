import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_service.dart';

/// In-memory [StorageService] for unit tests.
class MemoryStorage implements StorageService {
  final Map<StorageKey, Object?> values = {};

  @override
  Future<void> write<T>(StorageKey key, T value) async => values[key] = value;

  @override
  Future<T?> read<T>(StorageKey key) async => values[key] as T?;

  @override
  Future<void> delete(StorageKey key) async => values.remove(key);

  @override
  Future<void> clearAll() async => values.clear();

  @override
  Future<bool> containsKey(StorageKey key) async => values.containsKey(key);
}
