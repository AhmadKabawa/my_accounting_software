// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
// import 'package:accounting_software/app/features/home/presentation/cubit/home_states.dart';
// import 'package:accounting_software/app/features/home/presentation/widgets/loaded_section/featured_products_view.dart';
// import 'package:accounting_software/app/features/home/presentation/widgets/shimmer_section/featured_products_shimmer.dart';

// class FeaturedProductsSection extends StatelessWidget {
//   const FeaturedProductsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text("featured products"),
//         BlocBuilder<HomeCubit, HomeState>(
//           buildWhen: (prev, curr) =>
//               prev.featuredProductsState != curr.featuredProductsState,
//           builder: (context, state) => switch (state.flashSaleState) {
//             SectionLoading() => const FeaturedProductsShimmer(),
//             SectionLoaded(:final data) => FeaturedProductsView(
//               featuredProducts: data,
//             ),
//             SectionError(:final message) => Text(
//               " HomeErrorWidget(message: $message)",
//             ),
//             SectionInitial() => const SizedBox.shrink(),
//           },
//         ),
//       ],
//     );
//   }
// }
