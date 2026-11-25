import 'package:accounting_software/app/features/catalog/brands/di/brands_di.dart';
import 'package:accounting_software/app/features/catalog/colors/di/colors_di.dart';
import 'package:accounting_software/app/features/catalog/categories/di/categories_di.dart';

/// Catalog composition root delegates feature registrations.
void initCatalogDI() {
  initBrandsDI();
  initColorsDI();
  initCategoriesDI();
}
