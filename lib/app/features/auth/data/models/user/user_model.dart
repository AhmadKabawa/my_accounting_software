import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/hive_box_names.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
@HiveType(typeId: HiveBoxTypeId.user)
class UserModel with _$UserModel {
  const UserModel._();
  const factory UserModel({
    @HiveField(0) required String id,

    @HiveField(1) required String email,

    @HiveField(2) String? fullName,

    @HiveField(3) String? phone,

    @HiveField(4) String? avatarUrl,

    @HiveField(5) DateTime? createdAt,

    @HiveField(6) DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert UserModel to UserEntity
  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    fullName: fullName,
    avatarUrl: avatarUrl,
    createdAt: createdAt,
    phone: phone,
    updatedAt: updatedAt,
  );

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    email: entity.email,
    fullName: entity.fullName,
    avatarUrl: entity.avatarUrl,
    createdAt: entity.createdAt,
    phone: entity.phone,
    updatedAt: entity.updatedAt,
  );
}
