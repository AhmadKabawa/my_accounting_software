import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum ImageKeys implements AppKey {
  unsupportedType(
    ar: 'نوع الملف غير مسموح. اختر صورة JPEG أو PNG أو WebP.',
    en: 'This file type is not allowed. Choose a JPEG, PNG or WebP image.',
  ),
  tooLarge(
    ar: 'حجم الصورة أكبر من الحد المسموح.',
    en: 'The image exceeds the allowed file size.',
  ),
  readFailed(
    ar: 'تعذّرت قراءة الصورة. حاول اختيارها مرة أخرى.',
    en: 'The image could not be read. Please choose it again.',
  ),
  dropHint(ar: 'اسحب الصورة وأفلتها هنا', en: 'Drag and drop an image here');

  const ImageKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'image.$name';
}
