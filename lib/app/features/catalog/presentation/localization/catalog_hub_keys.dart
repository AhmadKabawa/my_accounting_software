import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum CatalogHubKeys implements AppKey {
  title(ar: 'الكتالوج', en: 'Catalog'),
  subtitle(
    ar: 'نظّم بيانات المنتجات الأساسية من مكان واحد.',
    en: 'Organize your core product data from one place.',
  ),
  brandsDescription(
    ar: 'أدر ماركات المنتجات وشعاراتها وحالتها.',
    en: 'Manage product brands, their logos and status.',
  ),
  colorsDescription(
    ar: 'أدر ألوان المنتجات ورموزها وقيمها المرئية.',
    en: 'Manage product colors, their codes and sample values.',
  ),
  unitsDescription(
    ar: 'إدارة وحدات القياس والرموز وأنواعها.',
    en: 'Manage measurement units, symbols and types.',
  ),
  optionSetsDescription(
    ar: 'إدارة مجموعات الخيارات والقيم المرتبطة بها.',
    en: 'Manage option sets and their values.',
  ),
  attributesDescription(
    ar: 'إدارة خصائص المنتجات وأنواع البيانات والارتباطات.',
    en: 'Manage product attributes, data types and references.',
  ),
  categoriesDescription(
    ar: 'نظّم المنتجات ضمن تصنيفات رئيسية وفرعية واضحة.',
    en: 'Organize products into clear parent categories and subcategories.',
  ),
  sportsDescription(
    ar: 'حدّد الرياضات التي تناسبها منتجاتك مثل كرة القدم والجري.',
    en: 'Define the sports your products suit, such as football and running.',
  ),
  tagsDescription(
    ar: 'أنشئ وسوماً حرة لتصنيف المنتجات والبحث عنها بسرعة.',
    en: 'Create free-form tags to label products and find them quickly.',
  ),
  open(ar: 'فتح', en: 'Open');

  const CatalogHubKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'cataloghub.$name';
}
