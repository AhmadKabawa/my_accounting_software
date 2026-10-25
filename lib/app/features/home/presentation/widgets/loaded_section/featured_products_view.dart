// import 'package:flutter/widgets.dart';
// import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
// import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';
// import 'package:accounting_software/app/core/presentation/responsive/helper/adaptive_helper.dart';
// import 'package:accounting_software/app/core/presentation/responsive/responsive_helper.dart';
// import 'package:accounting_software/app/features/home/presentation/widgets/vertical_product_card.dart';
// import 'package:accounting_software/app/features/products/domain/entity/product_entity.dart';

// class FeaturedProductsView extends StatelessWidget {
//   final PaginatedResult<ProductEntity> featuredProducts;

//   FeaturedProductsView({super.key, required this.featuredProducts});

//   @override
// /*************  ✨ Windsurf Command ⭐  *************/
// /// Builds a GridView with a SliverGridDelegateWithFixedCrossAxisCount.
// /// The grid is arranged according to the screen size with a fixed
// /// main axis spacing and cross axis spacing.
// /// The grid has a fixed main axis extent and a dynamic cross axis count.
/// The grid is populated with VerticalProductCard widgets, each displaying
/// a product from the PaginatedResult of products.
// /*******  e5f669be-d642-4f12-ae3b-66800b307cad  *******/
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),

//       padding: Ah.adaptivePadding(context, mobileH: AppSpacing.md),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: Ah.crossAxisCount(
//           context,
//           mobile: 2,
//           tablet: 3,
//           desktop: 4,
//         ),
//         mainAxisSpacing: 16,
//         crossAxisSpacing: 16,
//         mainAxisExtent: 288,
//       ),

//       itemCount: featuredProducts.items.length,
//       itemBuilder: (context, index) =>
//           VerticalProductCard(product: featuredProducts.items[index]),
//     );
//   }
// }
