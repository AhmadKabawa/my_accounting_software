import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_tokens/auth_tokens.dart';
part 'auth_tokens_model.freezed.dart';
part 'auth_tokens_model.g.dart';

@freezed
class AuthTokensModel with _$AuthTokensModel {
  const AuthTokensModel._();
  const factory AuthTokensModel({
    required String accessToken,
    String? refreshToken,
    String? userId,
  }) = _AuthTokensModel;

  // ════════════════════════════════════════════════════
  //  🔧 غيّر المفاتيح حسب الـ API
  //  Laravel Sanctum:   'token'
  //  JWT standard:      'access_token' + 'refresh_token'
  //  Supabase:          'access_token' + 'refresh_token'
  // ════════════════════════════════════════════════════
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensModelFromJson(json);

  /// 🔥 التحويل إلى Entity
  AuthTokensEntity toEntity() {
    return AuthTokensEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
  }
}
