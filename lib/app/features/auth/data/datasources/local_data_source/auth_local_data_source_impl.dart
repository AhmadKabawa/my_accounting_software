import 'package:accounting_software/app/core/error/error_handling/exceptions/exceptions.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/cache_manager.dart';
import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';
import 'package:accounting_software/app/features/auth/data/datasources/local_data_source/auth_local_data_source.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_tokens/auth_tokens_model.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TokenManager _tokenManager;
  final CacheManager _cacheManager;

  const AuthLocalDataSourceImpl({
    required TokenManager tokenManager,
    required CacheManager cacheManager,
  }) : _tokenManager = tokenManager,
       _cacheManager = cacheManager;

  // ============================================================
  // Private Safe Executor ⭐ (Important)
  // ============================================================

  Future<T> _safeExecute<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  // ============================================================
  // User Cache
  // ============================================================

  @override
  Future<void> cacheUser(UserModel user) =>
      _safeExecute(() => _cacheManager.saveUser(user));

  @override
  Future<UserModel?> getCachedUser() =>
      _safeExecute(() async => _cacheManager.getUser());

  @override
  Future<void> clearUser() => _safeExecute(() => _cacheManager.clearUser());

  // ============================================================
  // Tokens
  // ============================================================

  @override
  Future<void> saveToken(AuthTokensModel tokens) => _safeExecute(
    () => _tokenManager.saveAuthTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken ?? '',
      userId: tokens.userId ?? '',
    ),
  );
  @override
  Future<AuthTokensModel?> getTokens() => _safeExecute(() async {
    final access = await _tokenManager.getAccessToken();
    final refresh = await _tokenManager.getRefreshToken();

    // إذا لا يوجد access token → المستخدم غير مسجل
    if (access == null || access.isEmpty) return null;

    return AuthTokensModel(accessToken: access, refreshToken: refresh);
  });

  @override
  Future<void> clearTokens() => _safeExecute(() => _tokenManager.clearTokens());

  // ============================================================
  // Cache Clearing
  // ============================================================

  @override
  Future<void> clearAll() => _safeExecute(
    () => Future.wait([_tokenManager.clearTokens(), _cacheManager.clearUser()]),
  );

  // ============================================================
  // Auth Status
  // ============================================================

  @override
  Future<bool> isLoggedIn() => _safeExecute(() => _tokenManager.isLoggedIn());
}
