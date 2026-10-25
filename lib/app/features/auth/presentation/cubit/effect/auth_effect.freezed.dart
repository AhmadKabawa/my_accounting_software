// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_effect.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthEffect {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(UserEntity user) navigateToHome,
    required TResult Function() navigateToForgotPassword,
    required TResult Function(String messageKey, MessageType type) showMessage,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(UserEntity user)? navigateToHome,
    TResult? Function()? navigateToForgotPassword,
    TResult? Function(String messageKey, MessageType type)? showMessage,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(UserEntity user)? navigateToHome,
    TResult Function()? navigateToForgotPassword,
    TResult Function(String messageKey, MessageType type)? showMessage,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NavigateToHome value) navigateToHome,
    required TResult Function(_NavigateToForgotPassword value)
        navigateToForgotPassword,
    required TResult Function(_ShowMessage value) showMessage,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NavigateToHome value)? navigateToHome,
    TResult? Function(_NavigateToForgotPassword value)?
        navigateToForgotPassword,
    TResult? Function(_ShowMessage value)? showMessage,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NavigateToHome value)? navigateToHome,
    TResult Function(_NavigateToForgotPassword value)? navigateToForgotPassword,
    TResult Function(_ShowMessage value)? showMessage,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthEffectCopyWith<$Res> {
  factory $AuthEffectCopyWith(
          AuthEffect value, $Res Function(AuthEffect) then) =
      _$AuthEffectCopyWithImpl<$Res, AuthEffect>;
}

/// @nodoc
class _$AuthEffectCopyWithImpl<$Res, $Val extends AuthEffect>
    implements $AuthEffectCopyWith<$Res> {
  _$AuthEffectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$NavigateToHomeImplCopyWith<$Res> {
  factory _$$NavigateToHomeImplCopyWith(_$NavigateToHomeImpl value,
          $Res Function(_$NavigateToHomeImpl) then) =
      __$$NavigateToHomeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({UserEntity user});

  $UserEntityCopyWith<$Res> get user;
}

/// @nodoc
class __$$NavigateToHomeImplCopyWithImpl<$Res>
    extends _$AuthEffectCopyWithImpl<$Res, _$NavigateToHomeImpl>
    implements _$$NavigateToHomeImplCopyWith<$Res> {
  __$$NavigateToHomeImplCopyWithImpl(
      _$NavigateToHomeImpl _value, $Res Function(_$NavigateToHomeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
  }) {
    return _then(_$NavigateToHomeImpl(
      null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserEntity,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $UserEntityCopyWith<$Res> get user {
    return $UserEntityCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value));
    });
  }
}

/// @nodoc

class _$NavigateToHomeImpl implements _NavigateToHome {
  const _$NavigateToHomeImpl(this.user);

  @override
  final UserEntity user;

  @override
  String toString() {
    return 'AuthEffect.navigateToHome(user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigateToHomeImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigateToHomeImplCopyWith<_$NavigateToHomeImpl> get copyWith =>
      __$$NavigateToHomeImplCopyWithImpl<_$NavigateToHomeImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(UserEntity user) navigateToHome,
    required TResult Function() navigateToForgotPassword,
    required TResult Function(String messageKey, MessageType type) showMessage,
  }) {
    return navigateToHome(user);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(UserEntity user)? navigateToHome,
    TResult? Function()? navigateToForgotPassword,
    TResult? Function(String messageKey, MessageType type)? showMessage,
  }) {
    return navigateToHome?.call(user);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(UserEntity user)? navigateToHome,
    TResult Function()? navigateToForgotPassword,
    TResult Function(String messageKey, MessageType type)? showMessage,
    required TResult orElse(),
  }) {
    if (navigateToHome != null) {
      return navigateToHome(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NavigateToHome value) navigateToHome,
    required TResult Function(_NavigateToForgotPassword value)
        navigateToForgotPassword,
    required TResult Function(_ShowMessage value) showMessage,
  }) {
    return navigateToHome(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NavigateToHome value)? navigateToHome,
    TResult? Function(_NavigateToForgotPassword value)?
        navigateToForgotPassword,
    TResult? Function(_ShowMessage value)? showMessage,
  }) {
    return navigateToHome?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NavigateToHome value)? navigateToHome,
    TResult Function(_NavigateToForgotPassword value)? navigateToForgotPassword,
    TResult Function(_ShowMessage value)? showMessage,
    required TResult orElse(),
  }) {
    if (navigateToHome != null) {
      return navigateToHome(this);
    }
    return orElse();
  }
}

abstract class _NavigateToHome implements AuthEffect {
  const factory _NavigateToHome(final UserEntity user) = _$NavigateToHomeImpl;

  UserEntity get user;
  @JsonKey(ignore: true)
  _$$NavigateToHomeImplCopyWith<_$NavigateToHomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NavigateToForgotPasswordImplCopyWith<$Res> {
  factory _$$NavigateToForgotPasswordImplCopyWith(
          _$NavigateToForgotPasswordImpl value,
          $Res Function(_$NavigateToForgotPasswordImpl) then) =
      __$$NavigateToForgotPasswordImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NavigateToForgotPasswordImplCopyWithImpl<$Res>
    extends _$AuthEffectCopyWithImpl<$Res, _$NavigateToForgotPasswordImpl>
    implements _$$NavigateToForgotPasswordImplCopyWith<$Res> {
  __$$NavigateToForgotPasswordImplCopyWithImpl(
      _$NavigateToForgotPasswordImpl _value,
      $Res Function(_$NavigateToForgotPasswordImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$NavigateToForgotPasswordImpl implements _NavigateToForgotPassword {
  const _$NavigateToForgotPasswordImpl();

  @override
  String toString() {
    return 'AuthEffect.navigateToForgotPassword()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigateToForgotPasswordImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(UserEntity user) navigateToHome,
    required TResult Function() navigateToForgotPassword,
    required TResult Function(String messageKey, MessageType type) showMessage,
  }) {
    return navigateToForgotPassword();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(UserEntity user)? navigateToHome,
    TResult? Function()? navigateToForgotPassword,
    TResult? Function(String messageKey, MessageType type)? showMessage,
  }) {
    return navigateToForgotPassword?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(UserEntity user)? navigateToHome,
    TResult Function()? navigateToForgotPassword,
    TResult Function(String messageKey, MessageType type)? showMessage,
    required TResult orElse(),
  }) {
    if (navigateToForgotPassword != null) {
      return navigateToForgotPassword();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NavigateToHome value) navigateToHome,
    required TResult Function(_NavigateToForgotPassword value)
        navigateToForgotPassword,
    required TResult Function(_ShowMessage value) showMessage,
  }) {
    return navigateToForgotPassword(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NavigateToHome value)? navigateToHome,
    TResult? Function(_NavigateToForgotPassword value)?
        navigateToForgotPassword,
    TResult? Function(_ShowMessage value)? showMessage,
  }) {
    return navigateToForgotPassword?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NavigateToHome value)? navigateToHome,
    TResult Function(_NavigateToForgotPassword value)? navigateToForgotPassword,
    TResult Function(_ShowMessage value)? showMessage,
    required TResult orElse(),
  }) {
    if (navigateToForgotPassword != null) {
      return navigateToForgotPassword(this);
    }
    return orElse();
  }
}

abstract class _NavigateToForgotPassword implements AuthEffect {
  const factory _NavigateToForgotPassword() = _$NavigateToForgotPasswordImpl;
}

/// @nodoc
abstract class _$$ShowMessageImplCopyWith<$Res> {
  factory _$$ShowMessageImplCopyWith(
          _$ShowMessageImpl value, $Res Function(_$ShowMessageImpl) then) =
      __$$ShowMessageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String messageKey, MessageType type});
}

/// @nodoc
class __$$ShowMessageImplCopyWithImpl<$Res>
    extends _$AuthEffectCopyWithImpl<$Res, _$ShowMessageImpl>
    implements _$$ShowMessageImplCopyWith<$Res> {
  __$$ShowMessageImplCopyWithImpl(
      _$ShowMessageImpl _value, $Res Function(_$ShowMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageKey = null,
    Object? type = null,
  }) {
    return _then(_$ShowMessageImpl(
      messageKey: null == messageKey
          ? _value.messageKey
          : messageKey // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
    ));
  }
}

/// @nodoc

class _$ShowMessageImpl implements _ShowMessage {
  const _$ShowMessageImpl({required this.messageKey, required this.type});

  @override
  final String messageKey;
  @override
  final MessageType type;

  @override
  String toString() {
    return 'AuthEffect.showMessage(messageKey: $messageKey, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShowMessageImpl &&
            (identical(other.messageKey, messageKey) ||
                other.messageKey == messageKey) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(runtimeType, messageKey, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShowMessageImplCopyWith<_$ShowMessageImpl> get copyWith =>
      __$$ShowMessageImplCopyWithImpl<_$ShowMessageImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(UserEntity user) navigateToHome,
    required TResult Function() navigateToForgotPassword,
    required TResult Function(String messageKey, MessageType type) showMessage,
  }) {
    return showMessage(messageKey, type);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(UserEntity user)? navigateToHome,
    TResult? Function()? navigateToForgotPassword,
    TResult? Function(String messageKey, MessageType type)? showMessage,
  }) {
    return showMessage?.call(messageKey, type);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(UserEntity user)? navigateToHome,
    TResult Function()? navigateToForgotPassword,
    TResult Function(String messageKey, MessageType type)? showMessage,
    required TResult orElse(),
  }) {
    if (showMessage != null) {
      return showMessage(messageKey, type);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_NavigateToHome value) navigateToHome,
    required TResult Function(_NavigateToForgotPassword value)
        navigateToForgotPassword,
    required TResult Function(_ShowMessage value) showMessage,
  }) {
    return showMessage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_NavigateToHome value)? navigateToHome,
    TResult? Function(_NavigateToForgotPassword value)?
        navigateToForgotPassword,
    TResult? Function(_ShowMessage value)? showMessage,
  }) {
    return showMessage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_NavigateToHome value)? navigateToHome,
    TResult Function(_NavigateToForgotPassword value)? navigateToForgotPassword,
    TResult Function(_ShowMessage value)? showMessage,
    required TResult orElse(),
  }) {
    if (showMessage != null) {
      return showMessage(this);
    }
    return orElse();
  }
}

abstract class _ShowMessage implements AuthEffect {
  const factory _ShowMessage(
      {required final String messageKey,
      required final MessageType type}) = _$ShowMessageImpl;

  String get messageKey;
  MessageType get type;
  @JsonKey(ignore: true)
  _$$ShowMessageImplCopyWith<_$ShowMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
