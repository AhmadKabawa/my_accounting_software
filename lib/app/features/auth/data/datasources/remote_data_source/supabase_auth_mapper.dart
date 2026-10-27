import 'package:accounting_software/app/features/auth/data/models/auth_result/auth_result_model.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_tokens/auth_tokens_model.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';

/// Maps Supabase Auth (GoTrue) JSON to the app's models.
///
/// GoTrue returns snake_case fields and keeps profile data in `user_metadata`,
/// which the generated camelCase `fromJson` of the models cannot read.
UserModel userFromSupabase(Map<String, dynamic> json) {
  final meta = (json['user_metadata'] as Map?)?.cast<String, dynamic>() ?? {};
  final phone = json['phone'] as String?;
  return UserModel(
    id: json['id'] as String,
    email: (json['email'] as String?) ?? '',
    fullName: meta['full_name'] as String?,
    phone: (phone == null || phone.isEmpty) ? meta['phone'] as String? : phone,
    avatarUrl: meta['avatar_url'] as String?,
    createdAt: _date(json['created_at']),
    updatedAt: _date(json['updated_at']),
  );
}

/// Throws [FormatException] when the response carries no session, e.g. a
/// sign-up that still requires e-mail confirmation.
AuthResultModel sessionFromSupabase(Map<String, dynamic> json) {
  final accessToken = json['access_token'] as String?;
  final userJson = (json['user'] as Map?)?.cast<String, dynamic>();
  if (accessToken == null || userJson == null) {
    throw const FormatException(
      'Supabase response has no session (e-mail confirmation may be required)',
    );
  }
  final user = userFromSupabase(userJson);
  return AuthResultModel(
    user: user,
    tokens: AuthTokensModel(
      accessToken: accessToken,
      refreshToken: json['refresh_token'] as String?,
      userId: user.id,
    ),
  );
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;
