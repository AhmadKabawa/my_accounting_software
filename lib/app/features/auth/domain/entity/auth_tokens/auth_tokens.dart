import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';

@freezed
class AuthTokensEntity with _$AuthTokensEntity {

  const factory AuthTokensEntity({
    required String accessToken,
    String? refreshToken,
    String? userId,
  }) = _AuthTokens;
}
