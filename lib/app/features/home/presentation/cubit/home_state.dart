// ════════════════════════════════════════════════════════════
//  presentation/cubit/home_state.dart
//  All state variants live here. Generated file: home_state.freezed.dart
// ════════════════════════════════════════════════════════════

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/home/domain/entity/banner_entity.dart';
import 'package:accounting_software/app/features/home/domain/entity/category_entity.dart';
import 'package:accounting_software/app/features/home/domain/entity/product_entity.dart';

part 'home_state.freezed.dart';

// ════════════════════════════════════════════════════════════
//  SectionState<T>
//  A generic wrapper for any async data section (loading / loaded / error)
// ════════════════════════════════════════════════════════════

@freezed
class SectionState<T> with _$SectionState<T> {
  const SectionState._();

  const factory SectionState.initial() = _Initial<T>;
  const factory SectionState.loading() = _Loading<T>;
  const factory SectionState.loaded(T data) = _Loaded<T>;
  const factory SectionState.error(String message) = _Error<T>;

  // ── Convenience helpers ───────────────────────────────────

  bool get isInitial => this is _Initial<T>;
  bool get isLoading => this is _Loading<T>;
  bool get hasData => this is _Loaded<T>;
  bool get hasError => this is _Error<T>;

  T? get dataOrNull => maybeWhen(loaded: (d) => d, orElse: () => null);
}

// ════════════════════════════════════════════════════════════
//  HomeState  — root state held by HomeCubit
// ════════════════════════════════════════════════════════════

@freezed
class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    // ── Banner slider ───────────────────────────────────────
    @Default(SectionState.initial())
    SectionState<List<HeroBannerEntity>> bannersState,

    // ── Active slider index ─────────────────────────────────
    @Default(0) int currentBannerIndex,

    // ── Categories ──────────────────────────────────────────
    @Default(SectionState.initial())
    SectionState<List<CategoryEntity>> categoriesState,

    // ── Selected category filter ────────────────────────────
    @Default('all') String selectedCategoryId,

    // ── Product sections ────────────────────────────────────
    @Default(SectionState.initial())
    SectionState<PaginatedResult<ProductEntity>> featuredProductsState,

    @Default(SectionState.initial())
    SectionState<PaginatedResult<ProductEntity>> newProductsState,

    @Default(SectionState.initial())
    SectionState<PaginatedResult<ProductEntity>> flashSaleState,

    @Default(SectionState.initial())
    SectionState<PaginatedResult<ProductEntity>> bestProductsState,
  }) = _HomeState;
}


// // home_state.dart

// import 'package:dartz/dartz.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
// import 'package:accounting_software/app/core/foundation/base_mixin/base/base_usecases/use_case_no_params.dart';
// import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
// part 'home_states.freezed.dart';

// @freezed
// class SectionState<T> with _$SectionState<T> {
//   const SectionState._(); // private constructor for freezed
//   const factory SectionState.initial() = _Initial<T>;

//   const factory SectionState.loading() = _Loading<T>;

//   const factory SectionState.loaded(T data) = _Loaded<T>;

//   const factory SectionState.error(String message) = _Error<T>;
// }

// // ════════════════════════════════════════════════
// @freezed
// class HomeState with _$HomeState {
//   const HomeState._();
//   const factory HomeState({
//     @Default(SectionState.initial())
//     SectionState<PaginatedResult<ProductEntity>> featuredProductsState,

//     @Default(SectionState.initial())
//     SectionState<PaginatedResult<ProductEntity>> newProductsState,

//     @Default(SectionState.initial())
//     SectionState<PaginatedResult<ProductEntity>> flashSaleState,
//   }) = _HomeState;
// }

// class GetProductsUseCase
//     extends UseCaseNoParams<PaginatedResult<ProductEntity>> {
//   GetProductsUseCase();
  
//   @override
//   Future<Either<Failure, PaginatedResult<ProductEntity>>> call() {
//     // TODO: implement call
//     throw UnimplementedError();
//   }

 
 
// }

// class ProductEntity {
//   final String id;
//   final String name;
//   final String? description;
//   final double price;
//   final double? salePrice;
//   final String categoryId;
//   final String? brandId;
//   final int stock;
//   final List<String> images;
//   final String? thumbnail;
//   final double rating;
//   final int reviewsCount;
//   final bool isFeatured;
//   final bool isActive;
//   final Map<String, dynamic>? attributes;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final String? categoryName;
//   final String? brandName;

//   const ProductEntity({
//     required this.id,
//     required this.name,
//     this.description,
//     required this.price,
//     this.salePrice,
//     required this.categoryId,
//     this.brandId,
//     required this.stock,
//     required this.images,
//     this.thumbnail,
//     this.rating = 0,
//     this.reviewsCount = 0,
//     this.isFeatured = false,
//     this.isActive = true,
//     this.attributes,
//     this.createdAt,
//     this.updatedAt,
//     this.categoryName,
//     this.brandName,
//   });
//   double get discountPercentage {
//     if (salePrice == null || salePrice! >= price) return 0;
//     return ((price - salePrice!) / price) * 100;
//   }

//   bool get hasDiscount => salePrice != null && salePrice! < price;

//   double get effectivePrice => salePrice ?? price;

//   bool get isInStock => stock > 0;

//   StockStatus get stockStatus {
//     if (stock <= 0) return StockStatus.outOfStock;
//     if (stock <= 5) return StockStatus.lowStock;
//     return StockStatus.inStock;
//   }
// }

// enum StockStatus { outOfStock, lowStock, inStock }
