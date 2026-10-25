// ════════════════════════════════════════════════════════════
//  presentation/cubit/home_cubit.dart
//  Single cubit that orchestrates the entire home screen.
//  Each section is independently loadable and paginatable.
// ════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  // Pagination guards — prevent duplicate in-flight requests
  // bool _isLoadingMoreNew = false;
  // bool _isLoadingMoreFlash = false;
  // bool _isLoadingMoreFeatured = false;
  // bool _isLoadingMoreBest = false;

  HomeCubit() : super(const HomeState());

  // ════════════════════════════════════════════════════════
  //  INIT — called once when the screen mounts
  // ════════════════════════════════════════════════════════

  Future<void> init() => Future.wait([
    loadBanners(),
    loadCategories(),
    loadFeaturedProducts(),
    loadNewProducts(),
    loadFlashSaleProducts(),
    loadBestProducts(),
  ]);

  // ════════════════════════════════════════════════════════
  //  BANNER
  // ════════════════════════════════════════════════════════

  Future<void> loadBanners() async {}

  void changeBannerIndex(int index) {}

  // ════════════════════════════════════════════════════════
  //  CATEGORIES
  // ════════════════════════════════════════════════════════

  Future<void> loadCategories() async {}

  void selectCategory(String categoryId) {
    // TODO: trigger re-fetch of product sections filtered by category
  }

  // ════════════════════════════════════════════════════════
  //  FEATURED PRODUCTS
  // ════════════════════════════════════════════════════════

  Future<void> loadFeaturedProducts() async {}

  Future<void> loadMoreFeaturedProducts() async {}

  // ════════════════════════════════════════════════════════
  //  NEW PRODUCTS
  // ════════════════════════════════════════════════════════

  Future<void> loadNewProducts() async {}

  Future<void> loadMoreNewProducts() async {}

  // ════════════════════════════════════════════════════════
  //  FLASH SALE PRODUCTS
  // ════════════════════════════════════════════════════════

  Future<void> loadFlashSaleProducts() async {}

  Future<void> loadMoreFlashSaleProducts() async {}

  // ════════════════════════════════════════════════════════
  //  BEST PRODUCTS
  // ════════════════════════════════════════════════════════

  Future<void> loadBestProducts() async {}

  Future<void> loadMoreBestProducts() async {}
}
// // ════════════════════════════════════════════════════════════
// //  presentation/cubit/home_cubit.dart
// //  Single cubit that orchestrates the entire home screen.
// //  Each section is independently loadable and paginatable.
// // ════════════════════════════════════════════════════════════

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:accounting_software/app/features/home/domain/usecases/get_banners_usecase.dart';
// import 'package:accounting_software/app/features/home/domain/usecases/get_best_products_usecase.dart';
// import 'package:accounting_software/app/features/home/domain/usecases/get_categories_usecase.dart';
// import 'package:accounting_software/app/features/home/domain/usecases/get_featured_products_usecase.dart';
// import 'package:accounting_software/app/features/home/domain/usecases/get_flash_sale_products_usecase.dart';
// import 'package:accounting_software/app/features/home/domain/usecases/get_new_products_usecase.dart';
// import 'package:accounting_software/app/features/home/domain/usecases/get_products_params.dart';
// import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';

// class HomeCubit extends Cubit<HomeState> {
//   HomeCubit({
//     required GetBannersUseCase getBannersUseCase,
//     required GetCategoriesUseCase getCategoriesUseCase,
//     required GetFeaturedProductsUseCase getFeaturedProductsUseCase,
//     required GetNewProductsUseCase getNewProductsUseCase,
//     required GetFlashSaleProductsUseCase getFlashSaleProductsUseCase,
//     required GetBestProductsUseCase getBestProductsUseCase,
//   })  : _getBanners = getBannersUseCase,
//         _getCategories = getCategoriesUseCase,
//         _getFeatured = getFeaturedProductsUseCase,
//         _getNew = getNewProductsUseCase,
//         _getFlashSale = getFlashSaleProductsUseCase,
//         _getBest = getBestProductsUseCase,
//         super(const HomeState());

//   final GetBannersUseCase _getBanners;
//   final GetCategoriesUseCase _getCategories;
//   final GetFeaturedProductsUseCase _getFeatured;
//   final GetNewProductsUseCase _getNew;
//   final GetFlashSaleProductsUseCase _getFlashSale;
//   final GetBestProductsUseCase _getBest;

//   // Pagination guards — prevent duplicate in-flight requests
//   bool _isLoadingMoreNew = false;
//   bool _isLoadingMoreFlash = false;
//   bool _isLoadingMoreFeatured = false;
//   bool _isLoadingMoreBest = false;

//   // ════════════════════════════════════════════════════════
//   //  INIT — called once when the screen mounts
//   // ════════════════════════════════════════════════════════

//   Future<void> init() => Future.wait([
//         loadBanners(),
//         loadCategories(),
//         loadFeaturedProducts(),
//         loadNewProducts(),
//         loadFlashSaleProducts(),
//         loadBestProducts(),
//       ]);

//   // ════════════════════════════════════════════════════════
//   //  BANNER
//   // ════════════════════════════════════════════════════════

//   Future<void> loadBanners() async {
//     if (state.bannersState.isLoading) return;

//     emit(state.copyWith(bannersState: const SectionState.loading()));

//     final result = await _getBanners();

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           bannersState: SectionState.error(failure.messageKey.tran),
//         ),
//       ),
//       (banners) => emit(
//         state.copyWith(bannersState: SectionState.loaded(banners)),
//       ),
//     );
//   }

//   void changeBannerIndex(int index) {
//     emit(state.copyWith(currentBannerIndex: index));
//   }

//   // ════════════════════════════════════════════════════════
//   //  CATEGORIES
//   // ════════════════════════════════════════════════════════

//   Future<void> loadCategories() async {
//     if (state.categoriesState.isLoading) return;

//     emit(state.copyWith(categoriesState: const SectionState.loading()));

//     final result = await _getCategories();

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           categoriesState: SectionState.error(failure.messageKey.tran),
//         ),
//       ),
//       (categories) => emit(
//         state.copyWith(categoriesState: SectionState.loaded(categories)),
//       ),
//     );
//   }

//   void selectCategory(String categoryId) {
//     if (state.selectedCategoryId == categoryId) return;
//     emit(state.copyWith(selectedCategoryId: categoryId));
//     // TODO: trigger re-fetch of product sections filtered by category
//   }

//   // ════════════════════════════════════════════════════════
//   //  FEATURED PRODUCTS
//   // ════════════════════════════════════════════════════════

//   Future<void> loadFeaturedProducts() async {
//     if (state.featuredProductsState.isLoading) return;

//     emit(
//       state.copyWith(
//         featuredProductsState: const SectionState.loading(),
//       ),
//     );

//     final result = await _getFeatured(const GetProductsParams());

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           featuredProductsState: SectionState.error(failure.messageKey.tran),
//         ),
//       ),
//       (page) => emit(
//         state.copyWith(featuredProductsState: SectionState.loaded(page)),
//       ),
//     );
//   }

//   Future<void> loadMoreFeaturedProducts() async {
//     if (_isLoadingMoreFeatured) return;

//     await state.featuredProductsState.maybeWhen(
//       loaded: (section) async {
//         if (!section.hasNextPage) return;

//         _isLoadingMoreFeatured = true;

//         try {
//           final result = await _getFeatured(
//             GetProductsParams(page: section.currentPage + 1),
//           );

//           result.fold(
//             (failure) => emit(
//               state.copyWith(
//                 featuredProductsState:
//                     SectionState.error(failure.messageKey.tran),
//               ),
//             ),
//             (newPage) => emit(
//               state.copyWith(
//                 featuredProductsState: SectionState.loaded(
//                   section.appendItems(newPage.items),
//                 ),
//               ),
//             ),
//           );
//         } finally {
//           _isLoadingMoreFeatured = false;
//         }
//       },
//       orElse: () {},
//     );
//   }

//   // ════════════════════════════════════════════════════════
//   //  NEW PRODUCTS
//   // ════════════════════════════════════════════════════════

//   Future<void> loadNewProducts() async {
//     if (state.newProductsState.isLoading) return;

//     emit(state.copyWith(newProductsState: const SectionState.loading()));

//     final result = await _getNew(const GetProductsParams());

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           newProductsState: SectionState.error(failure.messageKey.tran),
//         ),
//       ),
//       (page) =>
//           emit(state.copyWith(newProductsState: SectionState.loaded(page))),
//     );
//   }

//   Future<void> loadMoreNewProducts() async {
//     if (_isLoadingMoreNew) return;

//     await state.newProductsState.maybeWhen(
//       loaded: (section) async {
//         if (!section.hasNextPage) return;

//         _isLoadingMoreNew = true;

//         try {
//           final result = await _getNew(
//             GetProductsParams(page: section.currentPage + 1),
//           );

//           result.fold(
//             (failure) => emit(
//               state.copyWith(
//                 newProductsState: SectionState.error(failure.messageKey.tran),
//               ),
//             ),
//             (newPage) => emit(
//               state.copyWith(
//                 newProductsState: SectionState.loaded(
//                   section.appendItems(newPage.items),
//                 ),
//               ),
//             ),
//           );
//         } finally {
//           _isLoadingMoreNew = false;
//         }
//       },
//       orElse: () {},
//     );
//   }

//   // ════════════════════════════════════════════════════════
//   //  FLASH SALE PRODUCTS
//   // ════════════════════════════════════════════════════════

//   Future<void> loadFlashSaleProducts() async {
//     if (state.flashSaleState.isLoading) return;

//     emit(state.copyWith(flashSaleState: const SectionState.loading()));

//     final result = await _getFlashSale(const GetProductsParams());

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           flashSaleState: SectionState.error(failure.messageKey.tran),
//         ),
//       ),
//       (page) =>
//           emit(state.copyWith(flashSaleState: SectionState.loaded(page))),
//     );
//   }

//   Future<void> loadMoreFlashSaleProducts() async {
//     if (_isLoadingMoreFlash) return;

//     await state.flashSaleState.maybeWhen(
//       loaded: (section) async {
//         if (!section.hasNextPage) return;

//         _isLoadingMoreFlash = true;

//         try {
//           final result = await _getFlashSale(
//             GetProductsParams(page: section.currentPage + 1),
//           );

//           result.fold(
//             (failure) => emit(
//               state.copyWith(
//                 flashSaleState: SectionState.error(failure.messageKey.tran),
//               ),
//             ),
//             (newPage) => emit(
//               state.copyWith(
//                 flashSaleState: SectionState.loaded(
//                   section.appendItems(newPage.items),
//                 ),
//               ),
//             ),
//           );
//         } finally {
//           _isLoadingMoreFlash = false;
//         }
//       },
//       orElse: () {},
//     );
//   }

//   // ════════════════════════════════════════════════════════
//   //  BEST PRODUCTS
//   // ════════════════════════════════════════════════════════

//   Future<void> loadBestProducts() async {
//     if (state.bestProductsState.isLoading) return;

//     emit(state.copyWith(bestProductsState: const SectionState.loading()));

//     final result = await _getBest(const GetProductsParams());

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           bestProductsState: SectionState.error(failure.messageKey.tran),
//         ),
//       ),
//       (page) =>
//           emit(state.copyWith(bestProductsState: SectionState.loaded(page))),
//     );
//   }

//   Future<void> loadMoreBestProducts() async {
//     if (_isLoadingMoreBest) return;

//     await state.bestProductsState.maybeWhen(
//       loaded: (section) async {
//         if (!section.hasNextPage) return;

//         _isLoadingMoreBest = true;

//         try {
//           final result = await _getBest(
//             GetProductsParams(page: section.currentPage + 1),
//           );

//           result.fold(
//             (failure) => emit(
//               state.copyWith(
//                 bestProductsState:
//                     SectionState.error(failure.messageKey.tran),
//               ),
//             ),
//             (newPage) => emit(
//               state.copyWith(
//                 bestProductsState: SectionState.loaded(
//                   section.appendItems(newPage.items),
//                 ),
//               ),
//             ),
//           );
//         } finally {
//           _isLoadingMoreBest = false;
//         }
//       },
//       orElse: () {},
//     );
//   }
// }

// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:accounting_software/app/features/home/presentation/cubit/home_states.dart';

// // class HomeCubit extends Cubit<HomeState> {
// //   final GetProductsUseCase _getProductsUseCase;

// //   bool _isLoadingMoreNew = false;
// //   bool _isLoadingMoreFlash = false;
// //   bool _isLoadingMoreFeatured = false;

// //   HomeCubit({required GetProductsUseCase getProductsUseCase})
// //     : _getProductsUseCase = getProductsUseCase,
// //       super(const HomeState());

// //   // ─────────────────────────────────────────
// //   Future<void> init() async {
// //     await Future.wait([
// //       // _loadNewProducts(),
// //       // _loadFlashSaleProducts(),
// //       // _loadFeaturedProducts(),
// //     ]);
// //   }

// //   // ── Load First Page ───────────────────────

// //   Future<void> _loadNewProducts() async {
// //     final isLoading = state.newProductsState.maybeWhen(
// //       loading: () => true,
// //       orElse: () => false,
// //     );

// //     if (isLoading) return;

// //     emit(state.copyWith(newProductsState: const SectionState.loading()));

// //     final result = await _getProductsUseCase();

// //     result.fold(
// //       (failure) => emit(
// //         state.copyWith(
// //           newProductsState: SectionState.error(failure.messageKey.tran),
// //         ),
// //       ),
// //       (pageResult) => emit(
// //         state.copyWith(newProductsState: SectionState.loaded(pageResult)),
// //       ),
// //     );
// //   }

// //   // ─────────────────────────────────────────

// //   Future<void> _loadFlashSaleProducts() async {
// //     final isLoading = state.flashSaleState.maybeWhen(
// //       loading: () => true,
// //       orElse: () => false,
// //     );

// //     if (isLoading) return;

// //     emit(state.copyWith(flashSaleState: const SectionState.loading()));

// //     final result = await _getProductsUseCase();

// //     result.fold(
// //       (failure) => emit(
// //         state.copyWith(
// //           flashSaleState: SectionState.error(failure.messageKey.tran),
// //         ),
// //       ),
// //       (pageResult) =>
// //           emit(state.copyWith(flashSaleState: SectionState.loaded(pageResult))),
// //     );
// //   }

// //   // ─────────────────────────────────────────

// //   Future<void> _loadFeaturedProducts() async {
// //     final isLoading = state.featuredProductsState.maybeWhen(
// //       loading: () => true,
// //       orElse: () => false,
// //     );

// //     if (isLoading) return;

// //     emit(state.copyWith(featuredProductsState: const SectionState.loading()));

// //     final result = await _getProductsUseCase();

// //     result.fold(
// //       (failure) => emit(
// //         state.copyWith(
// //           featuredProductsState: SectionState.error(failure.messageKey.tran),
// //         ),
// //       ),
// //       (pageResult) => emit(
// //         state.copyWith(featuredProductsState: SectionState.loaded(pageResult)),
// //       ),
// //     );
// //   }

// //   // ── Load More ─────────────────────────────

// //   Future<void> loadMoreNewProducts() async {
// //     if (_isLoadingMoreNew) return;

// //     await state.newProductsState.maybeWhen(
// //       loaded: (section) async {
// //         if (!section.hasNextPage) return;

// //         _isLoadingMoreNew = true;

// //         try {
// //           final nextPage = section.currentPage + 1;

// //           final result = await _getProductsUseCase();

// //           result.fold(
// //             (failure) => emit(
// //               state.copyWith(
// //                 newProductsState: SectionState.error(failure.messageKey.tran),
// //               ),
// //             ),
// //             (newData) {
// //               final merged = section.appendItems(newData.items);

// //               emit(
// //                 state.copyWith(newProductsState: SectionState.loaded(merged)),
// //               );
// //             },
// //           );
// //         } finally {
// //           _isLoadingMoreNew = false;
// //         }
// //       },
// //       orElse: () {},
// //     );
// //   }
// // }
