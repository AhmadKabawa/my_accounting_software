import 'package:accounting_software/app/features/auth/data/models/auth_tokens/auth_tokens_model.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';

/// Local data source for authentication
/// Handles caching user data
abstract class AuthLocalDataSource {
  /// Cache user data
  Future<void> cacheUser(UserModel user);

  /// Get cached user
  Future<UserModel?> getCachedUser();

  Future<void> clearUser(); // ← اسم أوضح من clearCache

  Future<void> saveToken(AuthTokensModel tokens);

  Future<AuthTokensModel?> getTokens();
  Future<void> clearTokens();

  /// Helpers
  Future<bool> isLoggedIn();
  Future<void> clearAll(); // يمسح User + Tokens معاً
}
