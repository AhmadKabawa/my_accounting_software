import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/message_view_widgets.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';

part 'auth_effect.freezed.dart';

@freezed
sealed class AuthEffect with _$AuthEffect {
  const factory AuthEffect.navigateToHome(UserEntity user) = _NavigateToHome;
  const factory AuthEffect.navigateToForgotPassword() =
      _NavigateToForgotPassword;
  // const factory AuthEffect.showSuccessMessage(String message) = _ShowSuccessMessage;
  const factory AuthEffect.showMessage({
    required String messageKey,
    required MessageType type,
  }) = _ShowMessage;
}
