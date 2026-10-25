// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthResultEntity {
  UserEntity get user => throw _privateConstructorUsedError;
  AuthTokensEntity get tokens => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AuthResultEntityCopyWith<AuthResultEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResultEntityCopyWith<$Res> {
  factory $AuthResultEntityCopyWith(
          AuthResultEntity value, $Res Function(AuthResultEntity) then) =
      _$AuthResultEntityCopyWithImpl<$Res, AuthResultEntity>;
  @useResult
  $Res call({UserEntity user, AuthTokensEntity tokens});

  $UserEntityCopyWith<$Res> get user;
  $AuthTokensEntityCopyWith<$Res> get tokens;
}

/// @nodoc
class _$AuthResultEntityCopyWithImpl<$Res, $Val extends AuthResultEntity>
    implements $AuthResultEntityCopyWith<$Res> {
  _$AuthResultEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? tokens = null,
  }) {
    return _then(_value.copyWith(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserEntity,
      tokens: null == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as AuthTokensEntity,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserEntityCopyWith<$Res> get user {
    return $UserEntityCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AuthTokensEntityCopyWith<$Res> get tokens {
    return $AuthTokensEntityCopyWith<$Res>(_value.tokens, (value) {
      return _then(_value.copyWith(tokens: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResultImplCopyWith<$Res>
    implements $AuthResultEntityCopyWith<$Res> {
  factory _$$AuthResultImplCopyWith(
          _$AuthResultImpl value, $Res Function(_$AuthResultImpl) then) =
      __$$AuthResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserEntity user, AuthTokensEntity tokens});

  @override
  $UserEntityCopyWith<$Res> get user;
  @override
  $AuthTokensEntityCopyWith<$Res> get tokens;
}

/// @nodoc
class __$$AuthResultImplCopyWithImpl<$Res>
    extends _$AuthResultEntityCopyWithImpl<$Res, _$AuthResultImpl>
    implements _$$AuthResultImplCopyWith<$Res> {
  __$$AuthResultImplCopyWithImpl(
      _$AuthResultImpl _value, $Res Function(_$AuthResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? tokens = null,
  }) {
    return _then(_$AuthResultImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserEntity,
      tokens: null == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as AuthTokensEntity,
    ));
  }
}

/// @nodoc

class _$AuthResultImpl extends _AuthResult {
  const _$AuthResultImpl({required this.user, required this.tokens})
      : super._();

  @override
  final UserEntity user;
  @override
  final AuthTokensEntity tokens;

  @override
  String toString() {
    return 'AuthResultEntity(user: $user, tokens: $tokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResultImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.tokens, tokens) || other.tokens == tokens));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user, tokens);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResultImplCopyWith<_$AuthResultImpl> get copyWith =>
      __$$AuthResultImplCopyWithImpl<_$AuthResultImpl>(this, _$identity);
}

abstract class _AuthResult extends AuthResultEntity {
  const factory _AuthResult(
      {required final UserEntity user,
      required final AuthTokensEntity tokens}) = _$AuthResultImpl;
  const _AuthResult._() : super._();

  @override
  UserEntity get user;
  @override
  AuthTokensEntity get tokens;
  @override
  @JsonKey(ignore: true)
  _$$AuthResultImplCopyWith<_$AuthResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
