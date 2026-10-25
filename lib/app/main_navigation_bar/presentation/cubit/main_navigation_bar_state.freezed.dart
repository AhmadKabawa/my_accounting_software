// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_navigation_bar_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MainNavigationBarState {
  /// الفهرس الحالي للصفحة  @Default(0)
  int get currentIndex => throw _privateConstructorUsedError;

  ///  عدد الصفحات@  Default(4)
  int get pageCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MainNavigationBarStateCopyWith<MainNavigationBarState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MainNavigationBarStateCopyWith<$Res> {
  factory $MainNavigationBarStateCopyWith(MainNavigationBarState value,
          $Res Function(MainNavigationBarState) then) =
      _$MainNavigationBarStateCopyWithImpl<$Res, MainNavigationBarState>;
  @useResult
  $Res call({int currentIndex, int pageCount});
}

/// @nodoc
class _$MainNavigationBarStateCopyWithImpl<$Res,
        $Val extends MainNavigationBarState>
    implements $MainNavigationBarStateCopyWith<$Res> {
  _$MainNavigationBarStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentIndex = null,
    Object? pageCount = null,
  }) {
    return _then(_value.copyWith(
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      pageCount: null == pageCount
          ? _value.pageCount
          : pageCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MainNavigationBarStateImplCopyWith<$Res>
    implements $MainNavigationBarStateCopyWith<$Res> {
  factory _$$MainNavigationBarStateImplCopyWith(
          _$MainNavigationBarStateImpl value,
          $Res Function(_$MainNavigationBarStateImpl) then) =
      __$$MainNavigationBarStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int currentIndex, int pageCount});
}

/// @nodoc
class __$$MainNavigationBarStateImplCopyWithImpl<$Res>
    extends _$MainNavigationBarStateCopyWithImpl<$Res,
        _$MainNavigationBarStateImpl>
    implements _$$MainNavigationBarStateImplCopyWith<$Res> {
  __$$MainNavigationBarStateImplCopyWithImpl(
      _$MainNavigationBarStateImpl _value,
      $Res Function(_$MainNavigationBarStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentIndex = null,
    Object? pageCount = null,
  }) {
    return _then(_$MainNavigationBarStateImpl(
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      pageCount: null == pageCount
          ? _value.pageCount
          : pageCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MainNavigationBarStateImpl implements _MainNavigationBarState {
  const _$MainNavigationBarStateImpl(
      {required this.currentIndex, required this.pageCount});

  /// الفهرس الحالي للصفحة  @Default(0)
  @override
  final int currentIndex;

  ///  عدد الصفحات@  Default(4)
  @override
  final int pageCount;

  @override
  String toString() {
    return 'MainNavigationBarState(currentIndex: $currentIndex, pageCount: $pageCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MainNavigationBarStateImpl &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentIndex, pageCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MainNavigationBarStateImplCopyWith<_$MainNavigationBarStateImpl>
      get copyWith => __$$MainNavigationBarStateImplCopyWithImpl<
          _$MainNavigationBarStateImpl>(this, _$identity);
}

abstract class _MainNavigationBarState implements MainNavigationBarState {
  const factory _MainNavigationBarState(
      {required final int currentIndex,
      required final int pageCount}) = _$MainNavigationBarStateImpl;

  @override

  /// الفهرس الحالي للصفحة  @Default(0)
  int get currentIndex;
  @override

  ///  عدد الصفحات@  Default(4)
  int get pageCount;
  @override
  @JsonKey(ignore: true)
  _$$MainNavigationBarStateImplCopyWith<_$MainNavigationBarStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
