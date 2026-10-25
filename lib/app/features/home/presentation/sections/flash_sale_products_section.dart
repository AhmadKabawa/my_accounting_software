// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
// import 'package:accounting_software/app/features/home/presentation/cubit/home_states.dart';
// import 'package:accounting_software/app/features/home/presentation/widgets/loaded_section/flash_sale_products_view.dart';
// import 'package:accounting_software/app/features/home/presentation/widgets/shimmer_section/flash_sale_products_shimmer.dart';

// class FlashSaleProductsSection extends StatelessWidget {
//   const FlashSaleProductsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text("flash sale products"),
//         BlocBuilder<HomeCubit, HomeState>(
//           buildWhen: (prev, curr) =>
//               prev.flashSaleState !=
//               curr.flashSaleState, // ✅ rebuild فقط عند تغير البانر
//           builder: (context, state) => switch (state.flashSaleState) {
//             SectionLoading() => const FlashSaleProductsShimmer(),
//             SectionLoaded(:final data) => FlashSaleProductsView(
//               flashSaleProducts: data,
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
