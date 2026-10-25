// core/domain/base/paginated_result.dart

import 'package:equatable/equatable.dart';

class PaginatedResult<T> extends Equatable {
  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    this.isFromCache = false,
  });

  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool isFromCache;

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  bool get isEmpty => items.isEmpty;

  // ✅ Generic — يشتغل مع Products, Orders, Users ...
 PaginatedResult<T> appendItems(List<T> newItems) => PaginatedResult(
  items: [...items, ...newItems],
  totalCount: totalCount,
  currentPage: currentPage + 1, // ✅ منطق داخلي ثابت
  totalPages: totalPages,
  isFromCache: isFromCache,
);
  PaginatedResult<T> copyWith({bool? isFromCache, List<T>? items}) =>
      PaginatedResult(
        items: items ?? this.items,
        totalCount: totalCount,
        currentPage: currentPage,
        totalPages: totalPages,
        isFromCache: isFromCache ?? this.isFromCache,
      );

  @override
  List<Object?> get props => [
    items,
    totalCount,
    currentPage,
    totalPages,
    isFromCache,
  ];
}

// // ── الاستخدام ──────────────────────────────────
// // بدل ProductsResult منفصل لكل feature      ,ApiResult
// Future<Either<Failure, PaginatedResult<ProductEntity>>> getProducts(...)
// Future<Either<Failure, PaginatedResult<OrderEntity>>>   getOrders(...)
// Future<Either<Failure, PaginatedResult<UserEntity>>>    getUsers(...)
