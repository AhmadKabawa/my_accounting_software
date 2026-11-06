import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/update_profile_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/features/profile/presentation/localization/profile_keys.dart';

enum ProfileStatus { idle, loading }

/// Profile screens: update the profile and change the password.
///
/// The loading state is local to the screen, so the app-wide session is never
/// put in "loading" (and nothing has to be restored afterwards).
class ProfileCubit extends Cubit<ProfileStatus> {
  ProfileCubit({
    required UpdateProfileUseCase updateProfile,
    required ChangePasswordUseCase changePassword,
    required SessionCubit session,
    required FlashMessages flash,
  }) : _updateProfile = updateProfile,
       _changePassword = changePassword,
       _session = session,
       _flash = flash,
       super(ProfileStatus.idle);

  final UpdateProfileUseCase _updateProfile;
  final ChangePasswordUseCase _changePassword;
  final SessionCubit _session;
  final FlashMessages _flash;

  bool get _signedIn => _session.current is SessionAuthenticated;

  void _setStatus(ProfileStatus status) {
    if (!isClosed) emit(status);
  }

  void _error(Failure failure) =>
      _flash.post(failure.messageKey, MessageType.error);

  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) async {
    if (state == ProfileStatus.loading) return;
    if (!_signedIn) return _error(UnauthorizedFailure());

    _setStatus(ProfileStatus.loading);
    final result = await _updateProfile(
      UpdateProfileParams(
        fullName: fullName,
        avatarUrl: avatarUrl,
        phone: phone,
      ),
    );
    _setStatus(ProfileStatus.idle);

    result.fold(_error, (user) {
      _session.updateUser(user);
      _flash.post(ProfileKeys.profileUpdated, MessageType.success);
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state == ProfileStatus.loading) return;
    if (!_signedIn) return _error(UnauthorizedFailure());

    _setStatus(ProfileStatus.loading);
    final result = await _changePassword(
      ChangePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    _setStatus(ProfileStatus.idle);

    result.fold(
      _error,
      (_) => _flash.post(ProfileKeys.passwordChanged, MessageType.success),
    );
  }
}
