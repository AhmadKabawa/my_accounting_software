import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';

/// What the sign-in / sign-up flows need from the session: to report that the
/// server accepted the user. `SessionCubit` implements it, and so does a fake
/// in tests, so `AuthFlowCubit` does not depend on a concrete cubit.
abstract interface class SessionAuthenticator {
  void onAuthenticated(UserEntity user);
}
