// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function() loading,
    required TResult Function(UserEntity user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String email) resetCodeSent,
    required TResult Function(String email) codeVerified,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function()? loading,
    TResult? Function(UserEntity user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String email)? resetCodeSent,
    TResult? Function(String email)? codeVerified,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function()? loading,
    TResult Function(UserEntity user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String email)? resetCodeSent,
    TResult Function(String email)? codeVerified,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthChecking value) checking,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(Authenticated value) authenticated,
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(PasswordResetEmailSent value)
        passwordResetEmailSent,
    required TResult Function(ResetCodeSent value) resetCodeSent,
    required TResult Function(CodeVerified value) codeVerified,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthChecking value)? checking,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(Authenticated value)? authenticated,
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult? Function(ResetCodeSent value)? resetCodeSent,
    TResult? Function(CodeVerified value)? codeVerified,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthChecking value)? checking,
    TResult Function(AuthLoading value)? loading,
    TResult Function(Authenticated value)? authenticated,
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult Function(ResetCodeSent value)? resetCodeSent,
    TResult Function(CodeVerified value)? codeVerified,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AuthInitialImplCopyWith<$Res> {
  factory _$$AuthInitialImplCopyWith(
          _$AuthInitialImpl value, $Res Function(_$AuthInitialImpl) then) =
      __$$AuthInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthInitialImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthInitialImpl>
    implements _$$AuthInitialImplCopyWith<$Res> {
  __$$AuthInitialImplCopyWithImpl(
      _$AuthInitialImpl _value, $Res Function(_$AuthInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AuthInitialImpl extends AuthInitial {
  const _$AuthInitialImpl() : super._();

  @override
  String toString() {
    return 'AuthState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AuthInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function() loading,
    required TResult Function(UserEntity user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String email) resetCodeSent,
    required TResult Function(String email) codeVerified,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function()? loading,
    TResult? Function(UserEntity user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String email)? resetCodeSent,
    TResult? Function(String email)? codeVerified,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function()? loading,
    TResult Function(UserEntity user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String email)? resetCodeSent,
    TResult Function(String email)? codeVerified,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthChecking value) checking,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(Authenticated value) authenticated,
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(PasswordResetEmailSent value)
        passwordResetEmailSent,
    required TResult Function(ResetCodeSent value) resetCodeSent,
    required TResult Function(CodeVerified value) codeVerified,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthChecking value)? checking,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(Authenticated value)? authenticated,
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult? Function(ResetCodeSent value)? resetCodeSent,
    TResult? Function(CodeVerified value)? codeVerified,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthChecking value)? checking,
    TResult Function(AuthLoading value)? loading,
    TResult Function(Authenticated value)? authenticated,
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult Function(ResetCodeSent value)? resetCodeSent,
    TResult Function(CodeVerified value)? codeVerified,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class AuthInitial extends AuthState {
  const factory AuthInitial() = _$AuthInitialImpl;
  const AuthInitial._() : super._();
}

/// @nodoc
abstract class _$$AuthCheckingImplCopyWith<$Res> {
  factory _$$AuthCheckingImplCopyWith(
          _$AuthCheckingImpl value, $Res Function(_$AuthCheckingImpl) then) =
      __$$AuthCheckingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthCheckingImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthCheckingImpl>
    implements _$$AuthCheckingImplCopyWith<$Res> {
  __$$AuthCheckingImplCopyWithImpl(
      _$AuthCheckingImpl _value, $Res Function(_$AuthCheckingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AuthCheckingImpl extends AuthChecking {
  const _$AuthCheckingImpl() : super._();

  @override
  String toString() {
    return 'AuthState.checking()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AuthCheckingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function() loading,
    required TResult Function(UserEntity user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String email) resetCodeSent,
    required TResult Function(String email) codeVerified,
  }) {
    return checking();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function()? loading,
    TResult? Function(UserEntity user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String email)? resetCodeSent,
    TResult? Function(String email)? codeVerified,
  }) {
    return checking?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function()? loading,
    TResult Function(UserEntity user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String email)? resetCodeSent,
    TResult Function(String email)? codeVerified,
    required TResult orElse(),
  }) {
    if (checking != null) {
      return checking();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthChecking value) checking,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(Authenticated value) authenticated,
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(PasswordResetEmailSent value)
        passwordResetEmailSent,
    required TResult Function(ResetCodeSent value) resetCodeSent,
    required TResult Function(CodeVerified value) codeVerified,
  }) {
    return checking(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthChecking value)? checking,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(Authenticated value)? authenticated,
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult? Function(ResetCodeSent value)? resetCodeSent,
    TResult? Function(CodeVerified value)? codeVerified,
  }) {
    return checking?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthChecking value)? checking,
    TResult Function(AuthLoading value)? loading,
    TResult Function(Authenticated value)? authenticated,
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult Function(ResetCodeSent value)? resetCodeSent,
    TResult Function(CodeVerified value)? codeVerified,
    required TResult orElse(),
  }) {
    if (checking != null) {
      return checking(this);
    }
    return orElse();
  }
}

abstract class AuthChecking extends AuthState {
  const factory AuthChecking() = _$AuthCheckingImpl;
  const AuthChecking._() : super._();
}

/// @nodoc
abstract class _$$AuthLoadingImplCopyWith<$Res> {
  factory _$$AuthLoadingImplCopyWith(
          _$AuthLoadingImpl value, $Res Function(_$AuthLoadingImpl) then) =
      __$$AuthLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthLoadingImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthLoadingImpl>
    implements _$$AuthLoadingImplCopyWith<$Res> {
  __$$AuthLoadingImplCopyWithImpl(
      _$AuthLoadingImpl _value, $Res Function(_$AuthLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AuthLoadingImpl extends AuthLoading {
  const _$AuthLoadingImpl() : super._();

  @override
  String toString() {
    return 'AuthState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AuthLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function() loading,
    required TResult Function(UserEntity user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String email) resetCodeSent,
    required TResult Function(String email) codeVerified,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function()? loading,
    TResult? Function(UserEntity user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String email)? resetCodeSent,
    TResult? Function(String email)? codeVerified,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function()? loading,
    TResult Function(UserEntity user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String email)? resetCodeSent,
    TResult Function(String email)? codeVerified,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthChecking value) checking,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(Authenticated value) authenticated,
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(PasswordResetEmailSent value)
        passwordResetEmailSent,
    required TResult Function(ResetCodeSent value) resetCodeSent,
    required TResult Function(CodeVerified value) codeVerified,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthChecking value)? checking,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(Authenticated value)? authenticated,
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult? Function(ResetCodeSent value)? resetCodeSent,
    TResult? Function(CodeVerified value)? codeVerified,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthChecking value)? checking,
    TResult Function(AuthLoading value)? loading,
    TResult Function(Authenticated value)? authenticated,
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult Function(ResetCodeSent value)? resetCodeSent,
    TResult Function(CodeVerified value)? codeVerified,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class AuthLoading extends AuthState {
  const factory AuthLoading() = _$AuthLoadingImpl;
  const AuthLoading._() : super._();
}

/// @nodoc
abstract class _$$AuthenticatedImplCopyWith<$Res> {
  factory _$$AuthenticatedImplCopyWith(
          _$AuthenticatedImpl value, $Res Function(_$AuthenticatedImpl) then) =
      __$$AuthenticatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({UserEntity user});

  $UserEntityCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthenticatedImpl>
    implements _$$AuthenticatedImplCopyWith<$Res> {
  __$$AuthenticatedImplCopyWithImpl(
      _$AuthenticatedImpl _value, $Res Function(_$AuthenticatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
  }) {
    return _then(_$AuthenticatedImpl(
      user: null == user
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

class _$AuthenticatedImpl extends Authenticated {
  const _$AuthenticatedImpl({required this.user}) : super._();

  @override
  final UserEntity user;

  @override
  String toString() {
    return 'AuthState.authenticated(user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticatedImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
      __$$AuthenticatedImplCopyWithImpl<_$AuthenticatedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function() loading,
    required TResult Function(UserEntity user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String email) resetCodeSent,
    required TResult Function(String email) codeVerified,
  }) {
    return authenticated(user);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function()? loading,
    TResult? Function(UserEntity user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String email)? resetCodeSent,
    TResult? Function(String email)? codeVerified,
  }) {
    return authenticated?.call(user);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function()? loading,
    TResult Function(UserEntity user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String email)? resetCodeSent,
    TResult Function(String email)? codeVerified,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthChecking value) checking,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(Authenticated value) authenticated,
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(PasswordResetEmailSent value)
        passwordResetEmailSent,
    required TResult Function(ResetCodeSent value) resetCodeSent,
    required TResult Function(CodeVerified value) codeVerified,
  }) {
    return authenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthChecking value)? checking,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(Authenticated value)? authenticated,
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult? Function(ResetCodeSent value)? resetCodeSent,
    TResult? Function(CodeVerified value)? codeVerified,
  }) {
    return authenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthChecking value)? checking,
    TResult Function(AuthLoading value)? loading,
    TResult Function(Authenticated value)? authenticated,
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult Function(ResetCodeSent value)? resetCodeSent,
    TResult Function(CodeVerified value)? codeVerified,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(this);
    }
    return orElse();
  }
}

abstract class Authenticated extends AuthState {
  const factory Authenticated({required final UserEntity user}) =
      _$AuthenticatedImpl;
  const Authenticated._() : super._();

  UserEntity get user;
  @JsonKey(ignore: true)
  _$$AuthenticatedImplCopyWith<_$AuthenticatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnauthenticatedImplCopyWith<$Res> {
  factory _$$UnauthenticatedImplCopyWith(_$UnauthenticatedImpl value,
          $Res Function(_$UnauthenticatedImpl) then) =
      __$$UnauthenticatedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UnauthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$UnauthenticatedImpl>
    implements _$$UnauthenticatedImplCopyWith<$Res> {
  __$$UnauthenticatedImplCopyWithImpl(
      _$UnauthenticatedImpl _value, $Res Function(_$UnauthenticatedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$UnauthenticatedImpl extends Unauthenticated {
  const _$UnauthenticatedImpl() : super._();

  @override
  String toString() {
    return 'AuthState.unauthenticated()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UnauthenticatedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function() loading,
    required TResult Function(UserEntity user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String email) resetCodeSent,
    required TResult Function(String email) codeVerified,
  }) {
    return unauthenticated();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function()? loading,
    TResult? Function(UserEntity user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String email)? resetCodeSent,
    TResult? Function(String email)? codeVerified,
  }) {
    return unauthenticated?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function()? loading,
    TResult Function(UserEntity user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String email)? resetCodeSent,
    TResult Function(String email)? codeVerified,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthChecking value) checking,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(Authenticated value) authenticated,
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(PasswordResetEmailSent value)
        passwordResetEmailSent,
    required TResult Function(ResetCodeSent value) resetCodeSent,
    required TResult Function(CodeVerified value) codeVerified,
  }) {
    return unauthenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthChecking value)? checking,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(Authenticated value)? authenticated,
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult? Function(ResetCodeSent value)? resetCodeSent,
    TResult? Function(CodeVerified value)? codeVerified,
  }) {
    return unauthenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthChecking value)? checking,
    TResult Function(AuthLoading value)? loading,
    TResult Function(Authenticated value)? authenticated,
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult Function(ResetCodeSent value)? resetCodeSent,
    TResult Function(CodeVerified value)? codeVerified,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(this);
    }
    return orElse();
  }
}

abstract class Unauthenticated extends AuthState {
  const factory Unauthenticated() = _$UnauthenticatedImpl;
  const Unauthenticated._() : super._();
}

/// @nodoc
abstract class _$$PasswordResetEmailSentImplCopyWith<$Res> {
  factory _$$PasswordResetEmailSentImplCopyWith(
          _$PasswordResetEmailSentImpl value,
          $Res Function(_$PasswordResetEmailSentImpl) then) =
      __$$PasswordResetEmailSentImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PasswordResetEmailSentImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$PasswordResetEmailSentImpl>
    implements _$$PasswordResetEmailSentImplCopyWith<$Res> {
  __$$PasswordResetEmailSentImplCopyWithImpl(
      _$PasswordResetEmailSentImpl _value,
      $Res Function(_$PasswordResetEmailSentImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$PasswordResetEmailSentImpl extends PasswordResetEmailSent {
  const _$PasswordResetEmailSentImpl() : super._();

  @override
  String toString() {
    return 'AuthState.passwordResetEmailSent()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordResetEmailSentImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function() loading,
    required TResult Function(UserEntity user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String email) resetCodeSent,
    required TResult Function(String email) codeVerified,
  }) {
    return passwordResetEmailSent();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function()? loading,
    TResult? Function(UserEntity user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String email)? resetCodeSent,
    TResult? Function(String email)? codeVerified,
  }) {
    return passwordResetEmailSent?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function()? loading,
    TResult Function(UserEntity user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String email)? resetCodeSent,
    TResult Function(String email)? codeVerified,
    required TResult orElse(),
  }) {
    if (passwordResetEmailSent != null) {
      return passwordResetEmailSent();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthChecking value) checking,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(Authenticated value) authenticated,
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(PasswordResetEmailSent value)
        passwordResetEmailSent,
    required TResult Function(ResetCodeSent value) resetCodeSent,
    required TResult Function(CodeVerified value) codeVerified,
  }) {
    return passwordResetEmailSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthChecking value)? checking,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(Authenticated value)? authenticated,
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult? Function(ResetCodeSent value)? resetCodeSent,
    TResult? Function(CodeVerified value)? codeVerified,
  }) {
    return passwordResetEmailSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthChecking value)? checking,
    TResult Function(AuthLoading value)? loading,
    TResult Function(Authenticated value)? authenticated,
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult Function(ResetCodeSent value)? resetCodeSent,
    TResult Function(CodeVerified value)? codeVerified,
    required TResult orElse(),
  }) {
    if (passwordResetEmailSent != null) {
      return passwordResetEmailSent(this);
    }
    return orElse();
  }
}

abstract class PasswordResetEmailSent extends AuthState {
  const factory PasswordResetEmailSent() = _$PasswordResetEmailSentImpl;
  const PasswordResetEmailSent._() : super._();
}

/// @nodoc
abstract class _$$ResetCodeSentImplCopyWith<$Res> {
  factory _$$ResetCodeSentImplCopyWith(
          _$ResetCodeSentImpl value, $Res Function(_$ResetCodeSentImpl) then) =
      __$$ResetCodeSentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$ResetCodeSentImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$ResetCodeSentImpl>
    implements _$$ResetCodeSentImplCopyWith<$Res> {
  __$$ResetCodeSentImplCopyWithImpl(
      _$ResetCodeSentImpl _value, $Res Function(_$ResetCodeSentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
  }) {
    return _then(_$ResetCodeSentImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ResetCodeSentImpl extends ResetCodeSent {
  const _$ResetCodeSentImpl({required this.email}) : super._();

  @override
  final String email;

  @override
  String toString() {
    return 'AuthState.resetCodeSent(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResetCodeSentImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ResetCodeSentImplCopyWith<_$ResetCodeSentImpl> get copyWith =>
      __$$ResetCodeSentImplCopyWithImpl<_$ResetCodeSentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function() loading,
    required TResult Function(UserEntity user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String email) resetCodeSent,
    required TResult Function(String email) codeVerified,
  }) {
    return resetCodeSent(email);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function()? loading,
    TResult? Function(UserEntity user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String email)? resetCodeSent,
    TResult? Function(String email)? codeVerified,
  }) {
    return resetCodeSent?.call(email);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function()? loading,
    TResult Function(UserEntity user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String email)? resetCodeSent,
    TResult Function(String email)? codeVerified,
    required TResult orElse(),
  }) {
    if (resetCodeSent != null) {
      return resetCodeSent(email);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthChecking value) checking,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(Authenticated value) authenticated,
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(PasswordResetEmailSent value)
        passwordResetEmailSent,
    required TResult Function(ResetCodeSent value) resetCodeSent,
    required TResult Function(CodeVerified value) codeVerified,
  }) {
    return resetCodeSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthChecking value)? checking,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(Authenticated value)? authenticated,
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult? Function(ResetCodeSent value)? resetCodeSent,
    TResult? Function(CodeVerified value)? codeVerified,
  }) {
    return resetCodeSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthChecking value)? checking,
    TResult Function(AuthLoading value)? loading,
    TResult Function(Authenticated value)? authenticated,
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult Function(ResetCodeSent value)? resetCodeSent,
    TResult Function(CodeVerified value)? codeVerified,
    required TResult orElse(),
  }) {
    if (resetCodeSent != null) {
      return resetCodeSent(this);
    }
    return orElse();
  }
}

abstract class ResetCodeSent extends AuthState {
  const factory ResetCodeSent({required final String email}) =
      _$ResetCodeSentImpl;
  const ResetCodeSent._() : super._();

  String get email;
  @JsonKey(ignore: true)
  _$$ResetCodeSentImplCopyWith<_$ResetCodeSentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CodeVerifiedImplCopyWith<$Res> {
  factory _$$CodeVerifiedImplCopyWith(
          _$CodeVerifiedImpl value, $Res Function(_$CodeVerifiedImpl) then) =
      __$$CodeVerifiedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$CodeVerifiedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$CodeVerifiedImpl>
    implements _$$CodeVerifiedImplCopyWith<$Res> {
  __$$CodeVerifiedImplCopyWithImpl(
      _$CodeVerifiedImpl _value, $Res Function(_$CodeVerifiedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
  }) {
    return _then(_$CodeVerifiedImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CodeVerifiedImpl extends CodeVerified {
  const _$CodeVerifiedImpl({required this.email}) : super._();

  @override
  final String email;

  @override
  String toString() {
    return 'AuthState.codeVerified(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CodeVerifiedImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CodeVerifiedImplCopyWith<_$CodeVerifiedImpl> get copyWith =>
      __$$CodeVerifiedImplCopyWithImpl<_$CodeVerifiedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function() loading,
    required TResult Function(UserEntity user) authenticated,
    required TResult Function() unauthenticated,
    required TResult Function() passwordResetEmailSent,
    required TResult Function(String email) resetCodeSent,
    required TResult Function(String email) codeVerified,
  }) {
    return codeVerified(email);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function()? loading,
    TResult? Function(UserEntity user)? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function()? passwordResetEmailSent,
    TResult? Function(String email)? resetCodeSent,
    TResult? Function(String email)? codeVerified,
  }) {
    return codeVerified?.call(email);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function()? loading,
    TResult Function(UserEntity user)? authenticated,
    TResult Function()? unauthenticated,
    TResult Function()? passwordResetEmailSent,
    TResult Function(String email)? resetCodeSent,
    TResult Function(String email)? codeVerified,
    required TResult orElse(),
  }) {
    if (codeVerified != null) {
      return codeVerified(email);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthChecking value) checking,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(Authenticated value) authenticated,
    required TResult Function(Unauthenticated value) unauthenticated,
    required TResult Function(PasswordResetEmailSent value)
        passwordResetEmailSent,
    required TResult Function(ResetCodeSent value) resetCodeSent,
    required TResult Function(CodeVerified value) codeVerified,
  }) {
    return codeVerified(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthChecking value)? checking,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(Authenticated value)? authenticated,
    TResult? Function(Unauthenticated value)? unauthenticated,
    TResult? Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult? Function(ResetCodeSent value)? resetCodeSent,
    TResult? Function(CodeVerified value)? codeVerified,
  }) {
    return codeVerified?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthChecking value)? checking,
    TResult Function(AuthLoading value)? loading,
    TResult Function(Authenticated value)? authenticated,
    TResult Function(Unauthenticated value)? unauthenticated,
    TResult Function(PasswordResetEmailSent value)? passwordResetEmailSent,
    TResult Function(ResetCodeSent value)? resetCodeSent,
    TResult Function(CodeVerified value)? codeVerified,
    required TResult orElse(),
  }) {
    if (codeVerified != null) {
      return codeVerified(this);
    }
    return orElse();
  }
}

abstract class CodeVerified extends AuthState {
  const factory CodeVerified({required final String email}) =
      _$CodeVerifiedImpl;
  const CodeVerified._() : super._();

  String get email;
  @JsonKey(ignore: true)
  _$$CodeVerifiedImplCopyWith<_$CodeVerifiedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
