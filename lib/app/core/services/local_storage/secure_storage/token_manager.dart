// 📁 lib/core/services/local_storage/secure_storage/token_manager.dart
//
// مسؤوليته: التوكينات فقط — لا يعرف شيئاً عن UserModel

import 'dart:async';

import 'package:accounting_software/app/core/services/local_storage/storage_keys.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_service.dart';

class TokenManager {
  final StorageService _storage;
  TokenManager({required StorageService storage}) : _storage = storage;

  // Synchronous so a listener sees the event before the caller's await
  // resumes (lets AuthCubit tell a deliberate sign-out from an expiry).
  final _sessionCleared = StreamController<void>.broadcast(sync: true);

  /// Fires whenever the stored session is removed ([clearTokens]).
  Stream<void> get sessionCleared => _sessionCleared.stream;

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

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(StorageKeys.accessToken),
      _storage.delete(StorageKeys.refreshToken),
      _storage.delete(StorageKeys.userId),
    ]);
    _sessionCleared.add(null);
  }

  // ─── Status ────────────────────────────────────────────
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
