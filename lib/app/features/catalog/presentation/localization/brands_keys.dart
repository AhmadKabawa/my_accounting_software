import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum BrandsKeys implements AppKey {
  title(ar: 'الماركات', en: 'Brands'),
  add(ar: 'إضافة ماركة', en: 'Add brand'),
  edit(ar: 'تعديل الماركة', en: 'Edit brand'),
  // `name` would shadow the enum value-name lookup used by the key getter.
  brandName(ar: 'اسم الماركة', en: 'Brand name'),
  slug(ar: 'المعرّف المختصر', en: 'Slug'),
  logo(ar: 'رابط الشعار', en: 'Logo URL'),
  description(ar: 'الوصف', en: 'Description'),
  active(ar: 'فعّالة', en: 'Active'),
  inactive(ar: 'غير فعّالة', en: 'Inactive'),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  delete(ar: 'حذف', en: 'Delete'),
  searchHint(ar: 'ابحث باسم الماركة أو المعرّف', en: 'Search by brand or slug'),
  empty(ar: 'لا توجد ماركات بعد', en: 'No brands yet'),
  emptyDescription(
    ar: 'أضف الماركات التي تستخدمها منتجات المتجر لتسهيل تنظيمها.',
    en: 'Add the brands used by your products to keep the catalog organized.',
  ),
  noResults(ar: 'لا توجد نتائج مطابقة', en: 'No matching brands'),
  noResultsDescription(
    ar: 'جرّب تغيير عبارة البحث أو حالة الماركة.',
    en: 'Try changing the search term or brand status.',
  ),
  loadError(ar: 'تعذر تحميل الماركات', en: 'Could not load brands'),
  saveError(
    ar: 'تعذر حفظ الماركة. تحقق من الاتصال والصلاحيات ثم حاول مجدداً.',
    en: 'Could not save the brand. Check your connection and permissions, then try again.',
  ),
  duplicateError(
    ar: 'اسم الماركة أو المعرّف المختصر مستخدم مسبقاً. اختر قيمة مختلفة.',
    en: 'The brand name or slug is already in use. Choose a different value.',
  ),
  deleteError(
    ar: 'تعذر حذف الماركة. قد تكون مرتبطة بسجلات أخرى أو لا تملك الصلاحية.',
    en: 'Could not delete the brand. It may be referenced by other records or you may lack permission.',
  ),
  slugRequired(
    ar: 'أدخل معرّفاً مختصراً باللغة الإنجليزية والأرقام.',
    en: 'Enter a slug using English letters and numbers.',
  ),
  slugHelp(
    ar: 'المعرّف المختصر مطلوب. إذا كان الاسم عربياً، أدخل slug إنجليزياً يدوياً.',
    en: 'A slug is required. For an Arabic brand name, enter an English slug manually.',
  ),
  slugFormat(
    ar: 'استخدم أحرفاً إنجليزية صغيرة وأرقاماً، ويمكن الفصل بينها بشرطة (-).',
    en: 'Use lowercase English letters and numbers, separated by hyphens.',
  ),
  nameTooLong(
    ar: 'يجب ألا يتجاوز الاسم 150 حرفاً.',
    en: 'The name must be 150 characters or fewer.',
  ),
  invalidLogoUrl(
    ar: 'أدخل رابط صورة صحيحاً يبدأ بـ http أو https.',
    en: 'Enter a valid image URL beginning with http or https.',
  ),
  slugTooLong(
    ar: 'يجب ألا يتجاوز المعرّف المختصر 150 حرفاً.',
    en: 'The slug must be 150 characters or fewer.',
  ),
  logoTooLong(
    ar: 'يجب ألا يتجاوز رابط الشعار 500 حرف.',
    en: 'The logo URL must be 500 characters or fewer.',
  ),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  confirmDelete(ar: 'هل تريد حذف هذه الماركة؟', en: 'Delete this brand?'),
  status(ar: 'الحالة', en: 'Status'),
  identitySection(ar: 'هوية الماركة', en: 'Brand identity'),
  logoSection(ar: 'الشعار', en: 'Brand logo'),
  detailsSection(ar: 'تفاصيل إضافية', en: 'Additional details'),
  editorSubtitle(
    ar: 'أدخل بيانات الماركة التي ستظهر عند ربطها بالمنتجات.',
    en: 'Enter the brand details used when assigning it to products.',
  ),
  productCount(ar: 'عدد المنتجات', en: 'Products'),
  productsLabel(ar: 'المنتجات: {count}', en: 'Products: {count}'),
  productsUnknown(ar: 'المنتجات: غير متاح', en: 'Products: n/a'),
  activate(ar: 'إعادة تفعيل', en: 'Reactivate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  deactivateTitle(ar: 'إيقاف الماركة', en: 'Deactivate brand'),
  deactivateMessage(
    ar: 'سيتم إيقاف الماركة مع الاحتفاظ بها وسجلاتها.',
    en: 'This brand will be deactivated while keeping its record and references.',
  ),
  statusUpdated(ar: 'تم تحديث حالة الماركة.', en: 'Brand status updated.'),
  brandInUse(
    ar: 'لا يمكن حذف الماركة لأنها مرتبطة بمنتجات. يمكنك إيقافها بدلاً من ذلك.',
    en: 'This brand cannot be deleted because products reference it. Deactivate it instead.',
  ),
  deleted(ar: 'تم حذف الماركة.', en: 'Brand deleted.'),
  totalBrands(ar: 'إجمالي الماركات', en: 'Total brands'),
  activeBrands(ar: 'الماركات النشطة', en: 'Active brands'),
  inactiveBrands(ar: 'الماركات الموقوفة', en: 'Inactive brands'),
  statLabel(ar: '{label}: {value}', en: '{label}: {value}');

  const BrandsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key =>
      this == BrandsKeys.brandName ? 'brands.name' : 'brands.${this.name}';
}
