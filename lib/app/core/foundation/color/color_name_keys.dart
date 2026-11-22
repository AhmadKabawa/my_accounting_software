import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Translatable display labels for [ColorName] suggestions.
enum ColorNameKeys implements AppKey {
  black(ar: 'أسود', en: 'Black'),
  charcoal(ar: 'فحمي', en: 'Charcoal'),
  gray(ar: 'رمادي', en: 'Gray'),
  silver(ar: 'فضي', en: 'Silver'),
  white(ar: 'أبيض', en: 'White'),
  ivory(ar: 'عاجي', en: 'Ivory'),
  beige(ar: 'بيج', en: 'Beige'),
  cream(ar: 'كريمي', en: 'Cream'),
  brown(ar: 'بني', en: 'Brown'),
  chocolate(ar: 'شوكولاتة', en: 'Chocolate'),
  tan(ar: 'قمحي', en: 'Tan'),
  camel(ar: 'جملي', en: 'Camel'),
  taupe(ar: 'تاوب', en: 'Taupe'),
  burgundy(ar: 'عنابي', en: 'Burgundy'),
  maroon(ar: 'ماروني', en: 'Maroon'),
  red(ar: 'أحمر', en: 'Red'),
  coral(ar: 'مرجاني', en: 'Coral'),
  salmon(ar: 'سلموني', en: 'Salmon'),
  pink(ar: 'وردي', en: 'Pink'),
  rose(ar: 'روز', en: 'Rose'),
  fuchsia(ar: 'فوشيا', en: 'Fuchsia'),
  magenta(ar: 'ماجنتا', en: 'Magenta'),
  purple(ar: 'بنفسجي', en: 'Purple'),
  violet(ar: 'بنفسجي فاتح', en: 'Violet'),
  lavender(ar: 'لافندر', en: 'Lavender'),
  lilac(ar: 'ليلكي', en: 'Lilac'),
  indigo(ar: 'نيلي', en: 'Indigo'),
  navy(ar: 'كحلي', en: 'Navy'),
  blue(ar: 'أزرق', en: 'Blue'),
  royalBlue(ar: 'أزرق ملكي', en: 'Royal blue'),
  skyBlue(ar: 'سماوي', en: 'Sky blue'),
  babyBlue(ar: 'أزرق فاتح', en: 'Baby blue'),
  turquoise(ar: 'فيروزي', en: 'Turquoise'),
  teal(ar: 'تركوازي', en: 'Teal'),
  aqua(ar: 'أكوا', en: 'Aqua'),
  mint(ar: 'نعناعي', en: 'Mint'),
  sage(ar: 'سيج', en: 'Sage'),
  olive(ar: 'زيتي', en: 'Olive'),
  lime(ar: 'ليموني', en: 'Lime'),
  green(ar: 'أخضر', en: 'Green'),
  forestGreen(ar: 'أخضر غابي', en: 'Forest green'),
  emerald(ar: 'زمردي', en: 'Emerald'),
  seaGreen(ar: 'أخضر بحري', en: 'Sea green'),
  mustard(ar: 'خردلي', en: 'Mustard'),
  yellow(ar: 'أصفر', en: 'Yellow'),
  gold(ar: 'ذهبي', en: 'Gold'),
  orange(ar: 'برتقالي', en: 'Orange'),
  peach(ar: 'خوخي', en: 'Peach'),
  rust(ar: 'صدئي', en: 'Rust'),
  terracotta(ar: 'تيراكوتا', en: 'Terracotta');

  const ColorNameKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'colorname.$name';
}
