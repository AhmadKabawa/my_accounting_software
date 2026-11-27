import 'package:accounting_software/app/core/localization/translations/app_key.dart';
enum CategoryFailureKeys implements AppKey {
 inUse(ar:'لا يمكن حذف التصنيف لأنه مرتبط بمنتجات أو تصنيفات فرعية أو قواعد خصم؛ يمكنك إيقافه بدلاً من حذفه.',en:'This category is linked to products, child categories or discount rules. Deactivate it instead.'),
 usageUnknown(ar:'تعذر التحقق من ارتباط المنتجات بهذا التصنيف؛ أوقفه بدلاً من حذفه حتى يتوفر العدد.',en:'Product usage could not be verified. Deactivate this category instead of deleting it.'),
 slugTaken(ar:'الرابط المختصر (slug) مستخدم مسبقاً',en:'This slug is already used'),
 invalidParent(ar:'لا يمكن جعل التصنيف تحت نفسه أو تحت أحد فروعه',en:'A category cannot sit under itself or one of its own branches'),
 tooLarge(ar:'عدد التصنيفات أكبر من حدّ العرض الحالي',en:'There are more categories than the current view supports');
 const CategoryFailureKeys({required this.ar,required this.en});
 @override final String ar; @override final String en; @override String get key=>'categoryfailures.$name';
}
