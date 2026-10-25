// import 'package:flutter/widgets.dart';
// import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
// import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';
// import 'package:accounting_software/app/core/presentation/responsive/helper/adaptive_helper.dart';

// import 'package:accounting_software/app/core/presentation/responsive/responsive_helper.dart';
// import 'package:accounting_software/app/features/home/presentation/widgets/vertical_product_card.dart';
// import 'package:accounting_software/app/features/products/domain/entity/product_entity.dart';

// class FlashSaleProductsView extends StatelessWidget {
//   final PaginatedResult<ProductEntity> flashSaleProducts;

//   FlashSaleProductsView({super.key, required this.flashSaleProducts});

//   @override
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

//       itemCount: flashSaleProducts.items.length,
//       itemBuilder: (context, index) =>
//           VerticalProductCard(product: flashSaleProducts.items[index]),
//     );
//   }
// }
