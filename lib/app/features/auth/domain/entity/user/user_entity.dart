import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const UserEntity._(); // constructor خاص (اختياري)

  // ✅ يجب تعريف الحقول هنا، خارج الـ factory
  const factory UserEntity({
    required String id, // بدون this
    required String email, // بدون this
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserEntity;

  // ✅ اختياري: constructors إضافية
}
