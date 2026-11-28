import 'package:accounting_software/app/features/catalog/brands/di/brands_di.dart';
import 'package:accounting_software/app/features/catalog/colors/di/colors_di.dart';
import 'package:accounting_software/app/features/catalog/categories/di/categories_di.dart';
import 'package:accounting_software/app/features/catalog/tags/di/tags_di.dart';
import 'package:accounting_software/app/features/catalog/sports/di/sports_di.dart';
import 'package:accounting_software/app/features/catalog/genders/di/genders_di.dart';
import 'package:accounting_software/app/features/catalog/age_groups/di/age_groups_di.dart';
import 'package:accounting_software/app/features/catalog/units/di/units_di.dart';
import 'package:accounting_software/app/features/catalog/option_sets/di/option_sets_di.dart';
import 'package:accounting_software/app/features/catalog/attributes/di/attributes_di.dart';
import 'package:accounting_software/app/features/catalog/product_types/di/product_types_di.dart';
import 'package:accounting_software/app/features/catalog/materials/di/materials_di.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/di/fabric_types_di.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/di/care_instructions_di.dart';

/// Catalog composition root delegates feature registrations.
void initCatalogDI() {
  initBrandsDI();
  initColorsDI();
  initCategoriesDI();
  initTagsDI();
  initSportsDI();
  initGendersDI();
  initAgeGroupsDI();
  initUnitsDI();
  initOptionSetsDI();
  initAttributesDI();
  initProductTypesDI();
  initMaterialsDI();
  initFabricTypesDI();
  initCareInstructionsDI();
}
