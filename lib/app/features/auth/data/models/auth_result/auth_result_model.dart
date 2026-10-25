import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_tokens/auth_tokens_model.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
part 'auth_result_model.freezed.dart';
part 'auth_result_model.g.dart';

@freezed
class AuthResultModel with _$AuthResultModel {
  const AuthResultModel._();

  const factory AuthResultModel({
    required UserModel user,
    required AuthTokensModel tokens,
  }) = _AuthResultModel;

  factory AuthResultModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResultModelFromJson(json);

  AuthResultEntity toEntity() {
    return AuthResultEntity(user: user.toEntity(), tokens: tokens.toEntity());
  }
}
