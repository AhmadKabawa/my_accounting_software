// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthResultModel _$AuthResultModelFromJson(Map<String, dynamic> json) {
  return _AuthResultModel.fromJson(json);
}

/// @nodoc
mixin _$AuthResultModel {
  UserModel get user => throw _privateConstructorUsedError;
  AuthTokensModel get tokens => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthResultModelCopyWith<AuthResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResultModelCopyWith<$Res> {
  factory $AuthResultModelCopyWith(
          AuthResultModel value, $Res Function(AuthResultModel) then) =
      _$AuthResultModelCopyWithImpl<$Res, AuthResultModel>;
  @useResult
  $Res call({UserModel user, AuthTokensModel tokens});

  $UserModelCopyWith<$Res> get user;
  $AuthTokensModelCopyWith<$Res> get tokens;
}

/// @nodoc
class _$AuthResultModelCopyWithImpl<$Res, $Val extends AuthResultModel>
    implements $AuthResultModelCopyWith<$Res> {
  _$AuthResultModelCopyWithImpl(this._value, this._then);

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
              as UserModel,
      tokens: null == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as AuthTokensModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AuthTokensModelCopyWith<$Res> get tokens {
    return $AuthTokensModelCopyWith<$Res>(_value.tokens, (value) {
      return _then(_value.copyWith(tokens: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResultModelImplCopyWith<$Res>
    implements $AuthResultModelCopyWith<$Res> {
  factory _$$AuthResultModelImplCopyWith(_$AuthResultModelImpl value,
          $Res Function(_$AuthResultModelImpl) then) =
      __$$AuthResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserModel user, AuthTokensModel tokens});

  @override
  $UserModelCopyWith<$Res> get user;
  @override
  $AuthTokensModelCopyWith<$Res> get tokens;
}

/// @nodoc
class __$$AuthResultModelImplCopyWithImpl<$Res>
    extends _$AuthResultModelCopyWithImpl<$Res, _$AuthResultModelImpl>
    implements _$$AuthResultModelImplCopyWith<$Res> {
  __$$AuthResultModelImplCopyWithImpl(
      _$AuthResultModelImpl _value, $Res Function(_$AuthResultModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? tokens = null,
  }) {
    return _then(_$AuthResultModelImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      tokens: null == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as AuthTokensModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResultModelImpl extends _AuthResultModel {
  const _$AuthResultModelImpl({required this.user, required this.tokens})
      : super._();

  factory _$AuthResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResultModelImplFromJson(json);

  @override
  final UserModel user;
  @override
  final AuthTokensModel tokens;

  @override
  String toString() {
    return 'AuthResultModel(user: $user, tokens: $tokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResultModelImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.tokens, tokens) || other.tokens == tokens));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, user, tokens);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResultModelImplCopyWith<_$AuthResultModelImpl> get copyWith =>
      __$$AuthResultModelImplCopyWithImpl<_$AuthResultModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResultModelImplToJson(
      this,
    );
  }
}

abstract class _AuthResultModel extends AuthResultModel {
  const factory _AuthResultModel(
      {required final UserModel user,
      required final AuthTokensModel tokens}) = _$AuthResultModelImpl;
  const _AuthResultModel._() : super._();

  factory _AuthResultModel.fromJson(Map<String, dynamic> json) =
      _$AuthResultModelImpl.fromJson;

  @override
  UserModel get user;
  @override
  AuthTokensModel get tokens;
  @override
  @JsonKey(ignore: true)
  _$$AuthResultModelImplCopyWith<_$AuthResultModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
