import 'package:freezed_annotation/freezed_annotation.dart';
import '../user/user_entity.dart';
import '../auth_tokens/auth_tokens.dart';

part 'auth_result.freezed.dart';

@freezed
class AuthResultEntity with _$AuthResultEntity {
  const AuthResultEntity._();
  const factory AuthResultEntity({
    required UserEntity user,
    required AuthTokensEntity tokens,
  }) = _AuthResult;
}
