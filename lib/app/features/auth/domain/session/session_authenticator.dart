import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';

/// Reports a successful Auth response; SessionCubit resolves the server-owned
/// password-change flag before publishing an authenticated session.
abstract interface class SessionAuthenticator {
  void onAuthenticated(UserEntity user);
}
