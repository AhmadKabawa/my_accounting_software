// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
// import 'package:accounting_software/app/features/home/presentation/cubit/home_states.dart';
// import 'package:accounting_software/app/features/home/presentation/widgets/loaded_section/new_products_view.dart';
// import 'package:accounting_software/app/features/home/presentation/widgets/shimmer_section/new_products_shimmer.dart';

// class NewProductsSection extends StatelessWidget {
//   const NewProductsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text("new products"),
//         BlocBuilder<HomeCubit, HomeState>(
//           buildWhen: (prev, curr) =>
//               prev.newProductsState !=
//               curr.newProductsState, // ✅ rebuild فقط عند تغير البانر
//           builder: (context, state) => switch (state.newProductsState) {
//             SectionLoading() => const NewProductsShimmer(),
//             SectionLoaded(:final data) => NewProductsView(NewProducts: data),
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
