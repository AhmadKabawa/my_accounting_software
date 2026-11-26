import 'package:accounting_software/app/features/catalog/brands/di/brands_di.dart';
import 'package:accounting_software/app/features/catalog/colors/di/colors_di.dart';
import 'package:accounting_software/app/features/catalog/categories/di/categories_di.dart';
// [cat10:begin] Product types DI import.
import 'package:accounting_software/app/features/catalog/product_types/di/product_types_di.dart';
// [cat10:end]

/// Catalog composition root delegates feature registrations.
void initCatalogDI() {
  initBrandsDI();
  initColorsDI();
  initCategoriesDI();
  // [cat10:begin] Product types DI initialization.
  initProductTypesDI();
  // [cat10:end]
}
