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
  open(ar: 'فتح', en: 'Open');

  const CatalogHubKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'cataloghub.$name';
}
