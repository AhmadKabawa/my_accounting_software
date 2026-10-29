// 📁 lib/core/services/local_storage/secure_storage/token_manager.dart
//
// مسؤوليته: التوكينات فقط — لا يعرف شيئاً عن UserModel

import 'dart:async';

import 'package:accounting_software/app/core/services/local_storage/storage_keys.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_service.dart';
import 'package:accounting_software/app/core/utils/logger.dart';

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
  // Secure storage has no transactions. Writes run in order.
  //
  // Two kinds of "removing the session" exist and must not be confused:
  //  * [_wipeStorage] only deletes the keys. It is used to roll back a failed
  //    write and never signals anything, so a failed *login* is reported as a
  //    failed login, not as an expired session.
  //  * [clearTokens] deletes the keys AND signals [sessionCleared]. It means
  //    "the session that was in use is gone" (expiry, rejected refresh token).
  Future<void> _wipeStorage() => Future.wait([
    _storage.delete(StorageKeys.accessToken),
    _storage.delete(StorageKeys.refreshToken),
    _storage.delete(StorageKeys.userId),
  ]);

  /// Login path: all-or-nothing. A failure rolls everything back silently
  /// (no [sessionCleared] event) and rethrows to the caller.
  Future<void> _writeAll(List<Future<void> Function()> writes) async {
    try {
      for (final write in writes) {
        await write();
      }
    } catch (_) {
      try {
        await _wipeStorage();
      } catch (e, st) {
        Logger.error(
          'TokenManager: rollback failed',
          error: e,
          stackTrace: st,
          name: 'TokenManager',
        );
      }
      rethrow;
    }
  }

  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) => _writeAll([
    () => saveAccessToken(accessToken),
    () => saveRefreshToken(refreshToken),
    () => saveUserId(userId),
  ]);

  /// Stores a renewed session (refresh path).
  ///
  /// The new access token is what keeps the user signed in, so it is written
  /// first. If it cannot be stored the session really is lost and
  /// [clearTokens] signals it. If only the rotated refresh token cannot be
  /// stored, the valid access token is kept and the error is logged instead
  /// of signing the user out.
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await saveAccessToken(accessToken);
    } catch (_) {
      await clearTokens();
      rethrow;
    }

    if (refreshToken == null) return;
    try {
      await saveRefreshToken(refreshToken);
    } catch (e, st) {
      Logger.error(
        'TokenManager: could not store the renewed refresh token; '
        'keeping the new access token',
        error: e,
        stackTrace: st,
        name: 'TokenManager',
      );
    }
  }

  /// Removes the stored session and signals [sessionCleared].
  Future<void> clearTokens() async {
    await _wipeStorage();
    _sessionCleared.add(null);
  }

  // ─── Status ────────────────────────────────────────────
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
