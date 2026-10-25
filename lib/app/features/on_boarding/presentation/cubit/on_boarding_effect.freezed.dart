// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'on_boarding_effect.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OnBoardingEffect {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() navigateHome,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? navigateHome,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? navigateHome,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NavigateToHome value) navigateHome,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToHome value)? navigateHome,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToHome value)? navigateHome,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnBoardingEffectCopyWith<$Res> {
  factory $OnBoardingEffectCopyWith(
          OnBoardingEffect value, $Res Function(OnBoardingEffect) then) =
      _$OnBoardingEffectCopyWithImpl<$Res, OnBoardingEffect>;
}

/// @nodoc
class _$OnBoardingEffectCopyWithImpl<$Res, $Val extends OnBoardingEffect>
    implements $OnBoardingEffectCopyWith<$Res> {
  _$OnBoardingEffectCopyWithImpl(this._value, this._then);

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
}

/// @nodoc
class __$$NavigateToHomeImplCopyWithImpl<$Res>
    extends _$OnBoardingEffectCopyWithImpl<$Res, _$NavigateToHomeImpl>
    implements _$$NavigateToHomeImplCopyWith<$Res> {
  __$$NavigateToHomeImplCopyWithImpl(
      _$NavigateToHomeImpl _value, $Res Function(_$NavigateToHomeImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$NavigateToHomeImpl implements NavigateToHome {
  const _$NavigateToHomeImpl();

  @override
  String toString() {
    return 'OnBoardingEffect.navigateHome()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NavigateToHomeImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() navigateHome,
  }) {
    return navigateHome();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? navigateHome,
  }) {
    return navigateHome?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? navigateHome,
    required TResult orElse(),
  }) {
    if (navigateHome != null) {
      return navigateHome();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NavigateToHome value) navigateHome,
  }) {
    return navigateHome(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NavigateToHome value)? navigateHome,
  }) {
    return navigateHome?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NavigateToHome value)? navigateHome,
    required TResult orElse(),
  }) {
    if (navigateHome != null) {
      return navigateHome(this);
    }
    return orElse();
  }
}

abstract class NavigateToHome implements OnBoardingEffect {
  const factory NavigateToHome() = _$NavigateToHomeImpl;
}
