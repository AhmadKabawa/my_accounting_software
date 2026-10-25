// 📁 lib/core/services/local_storage/secure_storage/token_manager.dart
//
// مسؤوليته: التوكينات فقط — لا يعرف شيئاً عن UserModel

import 'package:accounting_software/app/core/services/local_storage/storage_keys.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_service.dart';

class TokenManager {
  final StorageService _storage;
  const TokenManager({required StorageService storage}) : _storage = storage;

  // ─── Access Token ──────────────────────────────────────
  Future<void> saveAccessToken(String token) =>
      _storage.write<String>(StorageKeys.accessToken, token);

  Future<String?> getAccessToken() =>
      _storage.read<String>(StorageKeys.accessToken);

  Future<void> deleteAccessToken() => _storage.delete(StorageKeys.accessToken);

  // ─── Refresh Token ─────────────────────────────────────
  Future<void> saveRefreshToken(String token) =>
      _storage.write<String>(StorageKeys.refreshToken, token);

  Future<String?> getRefreshToken() =>
      _storage.read<String>(StorageKeys.refreshToken);

  // ─── User ID ───────────────────────────────────────────
  Future<void> saveUserId(String id) =>
      _storage.write<String>(StorageKeys.userId, id);

  Future<String?> getUserId() => _storage.read<String>(StorageKeys.userId);

  // ─── Batch Operations ──────────────────────────────────
  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) => Future.wait([
    saveAccessToken(accessToken),
    saveRefreshToken(refreshToken),
    saveUserId(userId),
  ]);

  Future<void> clearTokens() => Future.wait([
    _storage.delete(StorageKeys.accessToken),
    _storage.delete(StorageKeys.refreshToken),
    _storage.delete(StorageKeys.userId),
  ]);

  // ─── Status ────────────────────────────────────────────
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
