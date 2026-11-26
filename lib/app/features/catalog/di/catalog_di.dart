import 'package:accounting_software/app/features/catalog/brands/di/brands_di.dart';
import 'package:accounting_software/app/features/catalog/colors/di/colors_di.dart';
import 'package:accounting_software/app/features/catalog/categories/di/categories_di.dart';
import 'package:accounting_software/app/features/catalog/units/di/units_di.dart';

/// Catalog composition root delegates feature registrations.
void initCatalogDI() {
  initBrandsDI();
  initColorsDI();
  initCategoriesDI();
  // [cat08:begin] Units registration.
  initUnitsDI();
  // [cat08:end]
}
