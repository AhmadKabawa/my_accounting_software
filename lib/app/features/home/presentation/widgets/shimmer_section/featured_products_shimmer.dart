// import 'package:flutter/material.dart';
// import 'package:accounting_software/app/core/presentation/responsive/helper/adaptive_helper.dart';
// import 'package:accounting_software/app/core/presentation/responsive/helper/responsive_helper.dart';
// import 'package:shimmer/shimmer.dart';

// class FeaturedProductsShimmer extends StatelessWidget {
//   const FeaturedProductsShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;

//     return Shimmer.fromColors(
//       baseColor: scheme.surfaceContainerHighest,
//       highlightColor: scheme.surface,
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         padding: Rh.padding(context, mobileH: AppSpacing.md),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: Ah.crossAxisCount(
//             context,
//             mobile: 2,
//             tablet: 3,
//             desktop: 4,
//           ),
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           mainAxisExtent: 288,
//         ),
//         itemCount: Ah.crossAxisCount(context, mobile: 2, tablet: 3, desktop: 4),
//         itemBuilder: (_, _) => Container(
//           decoration: BoxDecoration(
//             color: scheme.surface,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             children: [
//               // Product Image Shimmer
//               Expanded(
//                 flex: 6,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: scheme.surface,

//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),
//               // Product Details Shimmer
//               Expanded(
//                 flex: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         height: 20,
//                         color: scheme.surface,
//                       ),
//                       const SizedBox(height: 16),
//                       Container(width: 100, height: 16, color: scheme.surface),
//                       const Spacer(),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Container(
//                             width: 60,
//                             height: 20,
//                             color: scheme.surface,
//                           ),
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: scheme.surface,

//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
