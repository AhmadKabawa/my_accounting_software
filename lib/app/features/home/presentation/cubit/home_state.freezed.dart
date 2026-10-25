// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SectionState<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial<T> value) initial,
    required TResult Function(_Loading<T> value) loading,
    required TResult Function(_Loaded<T> value) loaded,
    required TResult Function(_Error<T> value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial<T> value)? initial,
    TResult? Function(_Loading<T> value)? loading,
    TResult? Function(_Loaded<T> value)? loaded,
    TResult? Function(_Error<T> value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial<T> value)? initial,
    TResult Function(_Loading<T> value)? loading,
    TResult Function(_Loaded<T> value)? loaded,
    TResult Function(_Error<T> value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SectionStateCopyWith<T, $Res> {
  factory $SectionStateCopyWith(
          SectionState<T> value, $Res Function(SectionState<T>) then) =
      _$SectionStateCopyWithImpl<T, $Res, SectionState<T>>;
}

/// @nodoc
class _$SectionStateCopyWithImpl<T, $Res, $Val extends SectionState<T>>
    implements $SectionStateCopyWith<T, $Res> {
  _$SectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialImplCopyWith<T, $Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl<T> value, $Res Function(_$InitialImpl<T>) then) =
      __$$InitialImplCopyWithImpl<T, $Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<T, $Res>
    extends _$SectionStateCopyWithImpl<T, $Res, _$InitialImpl<T>>
    implements _$$InitialImplCopyWith<T, $Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl<T> _value, $Res Function(_$InitialImpl<T>) _then)
      : super(_value, _then);
}

/// @nodoc

class _$InitialImpl<T> extends _Initial<T> {
  const _$InitialImpl() : super._();

  @override
  String toString() {
    return 'SectionState<$T>.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? loaded,
    TResult Function(String message)? error,
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
    required TResult Function(_Initial<T> value) initial,
    required TResult Function(_Loading<T> value) loading,
    required TResult Function(_Loaded<T> value) loaded,
    required TResult Function(_Error<T> value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial<T> value)? initial,
    TResult? Function(_Loading<T> value)? loading,
    TResult? Function(_Loaded<T> value)? loaded,
    TResult? Function(_Error<T> value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial<T> value)? initial,
    TResult Function(_Loading<T> value)? loading,
    TResult Function(_Loaded<T> value)? loaded,
    TResult Function(_Error<T> value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial<T> extends SectionState<T> {
  const factory _Initial() = _$InitialImpl<T>;
  const _Initial._() : super._();
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<T, $Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl<T> value, $Res Function(_$LoadingImpl<T>) then) =
      __$$LoadingImplCopyWithImpl<T, $Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<T, $Res>
    extends _$SectionStateCopyWithImpl<T, $Res, _$LoadingImpl<T>>
    implements _$$LoadingImplCopyWith<T, $Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl<T> _value, $Res Function(_$LoadingImpl<T>) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadingImpl<T> extends _Loading<T> {
  const _$LoadingImpl() : super._();

  @override
  String toString() {
    return 'SectionState<$T>.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl<T>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? loaded,
    TResult Function(String message)? error,
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
    required TResult Function(_Initial<T> value) initial,
    required TResult Function(_Loading<T> value) loading,
    required TResult Function(_Loaded<T> value) loaded,
    required TResult Function(_Error<T> value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial<T> value)? initial,
    TResult? Function(_Loading<T> value)? loading,
    TResult? Function(_Loaded<T> value)? loaded,
    TResult? Function(_Error<T> value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial<T> value)? initial,
    TResult Function(_Loading<T> value)? loading,
    TResult Function(_Loaded<T> value)? loaded,
    TResult Function(_Error<T> value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading<T> extends SectionState<T> {
  const factory _Loading() = _$LoadingImpl<T>;
  const _Loading._() : super._();
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<T, $Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl<T> value, $Res Function(_$LoadedImpl<T>) then) =
      __$$LoadedImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T data});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<T, $Res>
    extends _$SectionStateCopyWithImpl<T, $Res, _$LoadedImpl<T>>
    implements _$$LoadedImplCopyWith<T, $Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl<T> _value, $Res Function(_$LoadedImpl<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_$LoadedImpl<T>(
      freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class _$LoadedImpl<T> extends _Loaded<T> {
  const _$LoadedImpl(this.data) : super._();

  @override
  final T data;

  @override
  String toString() {
    return 'SectionState<$T>.loaded(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<T, _$LoadedImpl<T>> get copyWith =>
      __$$LoadedImplCopyWithImpl<T, _$LoadedImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial<T> value) initial,
    required TResult Function(_Loading<T> value) loading,
    required TResult Function(_Loaded<T> value) loaded,
    required TResult Function(_Error<T> value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial<T> value)? initial,
    TResult? Function(_Loading<T> value)? loading,
    TResult? Function(_Loaded<T> value)? loaded,
    TResult? Function(_Error<T> value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial<T> value)? initial,
    TResult Function(_Loading<T> value)? loading,
    TResult Function(_Loaded<T> value)? loaded,
    TResult Function(_Error<T> value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded<T> extends SectionState<T> {
  const factory _Loaded(final T data) = _$LoadedImpl<T>;
  const _Loaded._() : super._();

  T get data;
  @JsonKey(ignore: true)
  _$$LoadedImplCopyWith<T, _$LoadedImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<T, $Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl<T> value, $Res Function(_$ErrorImpl<T>) then) =
      __$$ErrorImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<T, $Res>
    extends _$SectionStateCopyWithImpl<T, $Res, _$ErrorImpl<T>>
    implements _$$ErrorImplCopyWith<T, $Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl<T> _value, $Res Function(_$ErrorImpl<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl<T>(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl<T> extends _Error<T> {
  const _$ErrorImpl(this.message) : super._();

  @override
  final String message;

  @override
  String toString() {
    return 'SectionState<$T>.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl<T> &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<T, _$ErrorImpl<T>> get copyWith =>
      __$$ErrorImplCopyWithImpl<T, _$ErrorImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(T data) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(T data)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(T data)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial<T> value) initial,
    required TResult Function(_Loading<T> value) loading,
    required TResult Function(_Loaded<T> value) loaded,
    required TResult Function(_Error<T> value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial<T> value)? initial,
    TResult? Function(_Loading<T> value)? loading,
    TResult? Function(_Loaded<T> value)? loaded,
    TResult? Function(_Error<T> value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial<T> value)? initial,
    TResult Function(_Loading<T> value)? loading,
    TResult Function(_Loaded<T> value)? loaded,
    TResult Function(_Error<T> value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error<T> extends SectionState<T> {
  const factory _Error(final String message) = _$ErrorImpl<T>;
  const _Error._() : super._();

  String get message;
  @JsonKey(ignore: true)
  _$$ErrorImplCopyWith<T, _$ErrorImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HomeState {
// ── Banner slider ───────────────────────────────────────
  SectionState<List<HeroBannerEntity>> get bannersState =>
      throw _privateConstructorUsedError; // ── Active slider index ─────────────────────────────────
  int get currentBannerIndex =>
      throw _privateConstructorUsedError; // ── Categories ──────────────────────────────────────────
  SectionState<List<CategoryEntity>> get categoriesState =>
      throw _privateConstructorUsedError; // ── Selected category filter ────────────────────────────
  String get selectedCategoryId =>
      throw _privateConstructorUsedError; // ── Product sections ────────────────────────────────────
  SectionState<PaginatedResult<ProductEntity>> get featuredProductsState =>
      throw _privateConstructorUsedError;
  SectionState<PaginatedResult<ProductEntity>> get newProductsState =>
      throw _privateConstructorUsedError;
  SectionState<PaginatedResult<ProductEntity>> get flashSaleState =>
      throw _privateConstructorUsedError;
  SectionState<PaginatedResult<ProductEntity>> get bestProductsState =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call(
      {SectionState<List<HeroBannerEntity>> bannersState,
      int currentBannerIndex,
      SectionState<List<CategoryEntity>> categoriesState,
      String selectedCategoryId,
      SectionState<PaginatedResult<ProductEntity>> featuredProductsState,
      SectionState<PaginatedResult<ProductEntity>> newProductsState,
      SectionState<PaginatedResult<ProductEntity>> flashSaleState,
      SectionState<PaginatedResult<ProductEntity>> bestProductsState});

  $SectionStateCopyWith<List<HeroBannerEntity>, $Res> get bannersState;
  $SectionStateCopyWith<List<CategoryEntity>, $Res> get categoriesState;
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get featuredProductsState;
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get newProductsState;
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get flashSaleState;
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get bestProductsState;
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bannersState = null,
    Object? currentBannerIndex = null,
    Object? categoriesState = null,
    Object? selectedCategoryId = null,
    Object? featuredProductsState = null,
    Object? newProductsState = null,
    Object? flashSaleState = null,
    Object? bestProductsState = null,
  }) {
    return _then(_value.copyWith(
      bannersState: null == bannersState
          ? _value.bannersState
          : bannersState // ignore: cast_nullable_to_non_nullable
              as SectionState<List<HeroBannerEntity>>,
      currentBannerIndex: null == currentBannerIndex
          ? _value.currentBannerIndex
          : currentBannerIndex // ignore: cast_nullable_to_non_nullable
              as int,
      categoriesState: null == categoriesState
          ? _value.categoriesState
          : categoriesState // ignore: cast_nullable_to_non_nullable
              as SectionState<List<CategoryEntity>>,
      selectedCategoryId: null == selectedCategoryId
          ? _value.selectedCategoryId
          : selectedCategoryId // ignore: cast_nullable_to_non_nullable
              as String,
      featuredProductsState: null == featuredProductsState
          ? _value.featuredProductsState
          : featuredProductsState // ignore: cast_nullable_to_non_nullable
              as SectionState<PaginatedResult<ProductEntity>>,
      newProductsState: null == newProductsState
          ? _value.newProductsState
          : newProductsState // ignore: cast_nullable_to_non_nullable
              as SectionState<PaginatedResult<ProductEntity>>,
      flashSaleState: null == flashSaleState
          ? _value.flashSaleState
          : flashSaleState // ignore: cast_nullable_to_non_nullable
              as SectionState<PaginatedResult<ProductEntity>>,
      bestProductsState: null == bestProductsState
          ? _value.bestProductsState
          : bestProductsState // ignore: cast_nullable_to_non_nullable
              as SectionState<PaginatedResult<ProductEntity>>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SectionStateCopyWith<List<HeroBannerEntity>, $Res> get bannersState {
    return $SectionStateCopyWith<List<HeroBannerEntity>, $Res>(
        _value.bannersState, (value) {
      return _then(_value.copyWith(bannersState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SectionStateCopyWith<List<CategoryEntity>, $Res> get categoriesState {
    return $SectionStateCopyWith<List<CategoryEntity>, $Res>(
        _value.categoriesState, (value) {
      return _then(_value.copyWith(categoriesState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get featuredProductsState {
    return $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>(
        _value.featuredProductsState, (value) {
      return _then(_value.copyWith(featuredProductsState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get newProductsState {
    return $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>(
        _value.newProductsState, (value) {
      return _then(_value.copyWith(newProductsState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get flashSaleState {
    return $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>(
        _value.flashSaleState, (value) {
      return _then(_value.copyWith(flashSaleState: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get bestProductsState {
    return $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>(
        _value.bestProductsState, (value) {
      return _then(_value.copyWith(bestProductsState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
          _$HomeStateImpl value, $Res Function(_$HomeStateImpl) then) =
      __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SectionState<List<HeroBannerEntity>> bannersState,
      int currentBannerIndex,
      SectionState<List<CategoryEntity>> categoriesState,
      String selectedCategoryId,
      SectionState<PaginatedResult<ProductEntity>> featuredProductsState,
      SectionState<PaginatedResult<ProductEntity>> newProductsState,
      SectionState<PaginatedResult<ProductEntity>> flashSaleState,
      SectionState<PaginatedResult<ProductEntity>> bestProductsState});

  @override
  $SectionStateCopyWith<List<HeroBannerEntity>, $Res> get bannersState;
  @override
  $SectionStateCopyWith<List<CategoryEntity>, $Res> get categoriesState;
  @override
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get featuredProductsState;
  @override
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get newProductsState;
  @override
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get flashSaleState;
  @override
  $SectionStateCopyWith<PaginatedResult<ProductEntity>, $Res>
      get bestProductsState;
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
      _$HomeStateImpl _value, $Res Function(_$HomeStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bannersState = null,
    Object? currentBannerIndex = null,
    Object? categoriesState = null,
    Object? selectedCategoryId = null,
    Object? featuredProductsState = null,
    Object? newProductsState = null,
    Object? flashSaleState = null,
    Object? bestProductsState = null,
  }) {
    return _then(_$HomeStateImpl(
      bannersState: null == bannersState
          ? _value.bannersState
          : bannersState // ignore: cast_nullable_to_non_nullable
              as SectionState<List<HeroBannerEntity>>,
      currentBannerIndex: null == currentBannerIndex
          ? _value.currentBannerIndex
          : currentBannerIndex // ignore: cast_nullable_to_non_nullable
              as int,
      categoriesState: null == categoriesState
          ? _value.categoriesState
          : categoriesState // ignore: cast_nullable_to_non_nullable
              as SectionState<List<CategoryEntity>>,
      selectedCategoryId: null == selectedCategoryId
          ? _value.selectedCategoryId
          : selectedCategoryId // ignore: cast_nullable_to_non_nullable
              as String,
      featuredProductsState: null == featuredProductsState
          ? _value.featuredProductsState
          : featuredProductsState // ignore: cast_nullable_to_non_nullable
              as SectionState<PaginatedResult<ProductEntity>>,
      newProductsState: null == newProductsState
          ? _value.newProductsState
          : newProductsState // ignore: cast_nullable_to_non_nullable
              as SectionState<PaginatedResult<ProductEntity>>,
      flashSaleState: null == flashSaleState
          ? _value.flashSaleState
          : flashSaleState // ignore: cast_nullable_to_non_nullable
              as SectionState<PaginatedResult<ProductEntity>>,
      bestProductsState: null == bestProductsState
          ? _value.bestProductsState
          : bestProductsState // ignore: cast_nullable_to_non_nullable
              as SectionState<PaginatedResult<ProductEntity>>,
    ));
  }
}

/// @nodoc

class _$HomeStateImpl extends _HomeState {
  const _$HomeStateImpl(
      {this.bannersState = const SectionState.initial(),
      this.currentBannerIndex = 0,
      this.categoriesState = const SectionState.initial(),
      this.selectedCategoryId = 'all',
      this.featuredProductsState = const SectionState.initial(),
      this.newProductsState = const SectionState.initial(),
      this.flashSaleState = const SectionState.initial(),
      this.bestProductsState = const SectionState.initial()})
      : super._();

// ── Banner slider ───────────────────────────────────────
  @override
  @JsonKey()
  final SectionState<List<HeroBannerEntity>> bannersState;
// ── Active slider index ─────────────────────────────────
  @override
  @JsonKey()
  final int currentBannerIndex;
// ── Categories ──────────────────────────────────────────
  @override
  @JsonKey()
  final SectionState<List<CategoryEntity>> categoriesState;
// ── Selected category filter ────────────────────────────
  @override
  @JsonKey()
  final String selectedCategoryId;
// ── Product sections ────────────────────────────────────
  @override
  @JsonKey()
  final SectionState<PaginatedResult<ProductEntity>> featuredProductsState;
  @override
  @JsonKey()
  final SectionState<PaginatedResult<ProductEntity>> newProductsState;
  @override
  @JsonKey()
  final SectionState<PaginatedResult<ProductEntity>> flashSaleState;
  @override
  @JsonKey()
  final SectionState<PaginatedResult<ProductEntity>> bestProductsState;

  @override
  String toString() {
    return 'HomeState(bannersState: $bannersState, currentBannerIndex: $currentBannerIndex, categoriesState: $categoriesState, selectedCategoryId: $selectedCategoryId, featuredProductsState: $featuredProductsState, newProductsState: $newProductsState, flashSaleState: $flashSaleState, bestProductsState: $bestProductsState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.bannersState, bannersState) ||
                other.bannersState == bannersState) &&
            (identical(other.currentBannerIndex, currentBannerIndex) ||
                other.currentBannerIndex == currentBannerIndex) &&
            (identical(other.categoriesState, categoriesState) ||
                other.categoriesState == categoriesState) &&
            (identical(other.selectedCategoryId, selectedCategoryId) ||
                other.selectedCategoryId == selectedCategoryId) &&
            (identical(other.featuredProductsState, featuredProductsState) ||
                other.featuredProductsState == featuredProductsState) &&
            (identical(other.newProductsState, newProductsState) ||
                other.newProductsState == newProductsState) &&
            (identical(other.flashSaleState, flashSaleState) ||
                other.flashSaleState == flashSaleState) &&
            (identical(other.bestProductsState, bestProductsState) ||
                other.bestProductsState == bestProductsState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      bannersState,
      currentBannerIndex,
      categoriesState,
      selectedCategoryId,
      featuredProductsState,
      newProductsState,
      flashSaleState,
      bestProductsState);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState extends HomeState {
  const factory _HomeState(
      {final SectionState<List<HeroBannerEntity>> bannersState,
      final int currentBannerIndex,
      final SectionState<List<CategoryEntity>> categoriesState,
      final String selectedCategoryId,
      final SectionState<PaginatedResult<ProductEntity>> featuredProductsState,
      final SectionState<PaginatedResult<ProductEntity>> newProductsState,
      final SectionState<PaginatedResult<ProductEntity>> flashSaleState,
      final SectionState<PaginatedResult<ProductEntity>>
          bestProductsState}) = _$HomeStateImpl;
  const _HomeState._() : super._();

  @override // ── Banner slider ───────────────────────────────────────
  SectionState<List<HeroBannerEntity>> get bannersState;
  @override // ── Active slider index ─────────────────────────────────
  int get currentBannerIndex;
  @override // ── Categories ──────────────────────────────────────────
  SectionState<List<CategoryEntity>> get categoriesState;
  @override // ── Selected category filter ────────────────────────────
  String get selectedCategoryId;
  @override // ── Product sections ────────────────────────────────────
  SectionState<PaginatedResult<ProductEntity>> get featuredProductsState;
  @override
  SectionState<PaginatedResult<ProductEntity>> get newProductsState;
  @override
  SectionState<PaginatedResult<ProductEntity>> get flashSaleState;
  @override
  SectionState<PaginatedResult<ProductEntity>> get bestProductsState;
  @override
  @JsonKey(ignore: true)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
