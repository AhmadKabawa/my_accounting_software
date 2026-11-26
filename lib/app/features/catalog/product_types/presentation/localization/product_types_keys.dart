import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum ProductTypesKeys implements AppKey {
  title(ar: 'أنواع المنتجات', en: 'Product types'),
  hubDescription(
    ar: 'تعريف أنواع المنتجات وربطها بإعدادات المقاسات والخصائص.',
    en: 'Define product types and connect their size and attribute settings.',
  ),
  add(ar: 'إضافة نوع منتج', en: 'Add product type'),
  edit(ar: 'تعديل نوع المنتج', en: 'Edit product type'),
  nameLabel(ar: 'اسم النوع', en: 'Type name'),
  codeLabel(ar: 'الرمز', en: 'Code'),
  descriptionLabel(ar: 'الوصف', en: 'Description'),
  sortOrderLabel(ar: 'ترتيب العرض', en: 'Display order'),
  activeOnCreate(ar: 'نشط عند الإنشاء', en: 'Active on create'),
  active(ar: 'نشط', en: 'Active'),
  inactive(ar: 'موقوف', en: 'Inactive'),
  status(ar: 'الحالة', en: 'Status'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  searchHint(ar: 'ابحث باسم النوع أو رمزه', en: 'Search by type name or code'),
  products(ar: 'المنتجات', en: 'Products'),
  productsCount(ar: '{count} منتج', en: '{count} products'),
  sizeGroups(ar: 'مجموعات المقاسات', en: 'Size groups'),
  sizeGroupsCount(ar: '{count} مجموعة', en: '{count} groups'),
  sizeSystem(ar: 'نظام المقاسات', en: 'Size system'),
  dataType(ar: 'نوع البيانات', en: 'Data type'),
  attributes(ar: 'الخصائص', en: 'Attributes'),
  attributesCount(ar: '{count} خاصية', en: '{count} attributes'),
  optionSets(ar: 'مجموعات الخيارات', en: 'Option sets'),
  optionSetsCount(ar: '{count} مجموعة', en: '{count} option sets'),
  careInstructions(ar: 'تعليمات العناية', en: 'Care instructions'),
  updatedAt(ar: 'آخر تحديث', en: 'Last updated'),
  empty(ar: 'لا توجد أنواع منتجات بعد', en: 'No product types yet'),
  emptyDescription(
    ar: 'أضف نوع المنتج قبل إنشاء المنتجات وربط إعداداتها.',
    en: 'Add a product type before creating products and configuring their settings.',
  ),
  noResults(ar: 'لا توجد نتائج مطابقة', en: 'No matching product types'),
  noResultsDescription(
    ar: 'غيّر عبارة البحث أو فلتر الحالة ثم حاول مجدداً.',
    en: 'Change the search term or status filter and try again.',
  ),
  loadError(
    ar: 'تعذر تحميل أنواع المنتجات',
    en: 'Could not load product types',
  ),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  nameTooLong(
    ar: 'يجب ألا يتجاوز الاسم 150 حرفاً.',
    en: 'Name must be 150 characters or fewer.',
  ),
  codeTooLong(
    ar: 'يجب ألا يتجاوز الرمز 50 حرفاً.',
    en: 'Code must be 50 characters or fewer.',
  ),
  sortOrderInvalid(ar: 'أدخل عدداً صحيحاً.', en: 'Enter a whole number.'),
  codeLocked(
    ar: 'لا يمكن تغيير الرمز بعد استخدام النوع أو تعذر التحقق من ارتباطاته.',
    en: 'The code cannot change after use or when its references cannot be verified.',
  ),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  delete(ar: 'حذف', en: 'Delete'),
  activate(ar: 'إعادة تفعيل', en: 'Reactivate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  deleteTitle(ar: 'حذف نوع المنتج', en: 'Delete product type'),
  deleteMessage(
    ar: 'هل تريد حذف نوع المنتج {name}؟',
    en: 'Delete product type {name}?',
  ),
  deactivateTitle(ar: 'إيقاف نوع المنتج', en: 'Deactivate product type'),
  deactivateMessage(
    ar: 'سيبقى النوع والمنتجات الحالية مرتبطة به، ولن يظهر للاختيارات الجديدة.',
    en: 'The type and existing products remain linked; it will no longer be offered for new selections.',
  ),
  inUseTitle(ar: 'نوع المنتج مستخدم', en: 'Product type is in use'),
  inUseMessage(
    ar: 'لا يمكن حذف هذا النوع. يمكنك إيقافه بدلاً من ذلك.',
    en: 'This type cannot be deleted. You can deactivate it instead.',
  ),
  usageUnknown(ar: '—', en: '—'),
  totalStats(ar: 'الكل', en: 'All'),
  activeStats(ar: 'النشطة', en: 'Active'),
  inactiveStats(ar: 'الموقوفة', en: 'Inactive'),
  unusedStats(ar: 'بلا منتجات', en: 'Without products'),
  saved(ar: 'تم حفظ نوع المنتج.', en: 'Product type saved.'),
  deleted(ar: 'تم حذف نوع المنتج.', en: 'Product type deleted.'),
  statusUpdated(ar: 'تم تحديث الحالة.', en: 'Status updated.'),
  detailTitle(ar: 'تفاصيل نوع المنتج', en: 'Product type details'),
  addSizeGroup(ar: 'ربط مجموعة مقاسات', en: 'Link size group'),
  addAttribute(ar: 'ربط خاصية', en: 'Link attribute'),
  addOptionSet(ar: 'ربط مجموعة خيارات', en: 'Link option set'),
  addLink(ar: 'إضافة ربط', en: 'Add link'),
  removeLink(ar: 'إزالة الربط', en: 'Remove link'),
  isDefault(ar: 'افتراضية', en: 'Default'),
  isRequired(ar: 'إلزامية', en: 'Required'),
  gender(ar: 'الجنس', en: 'Gender'),
  sortOrder(ar: 'الترتيب', en: 'Order'),
  noSizeGroups(
    ar: 'لا مجموعة مقاسات لهذا النوع',
    en: 'No size groups for this type',
  ),
  noAttributes(ar: 'لا خصائص لهذا النوع', en: 'No attributes for this type'),
  noOptionSets(
    ar: 'لا مجموعات خيارات لهذا النوع',
    en: 'No option sets for this type',
  ),
  noAvailableOptions(
    ar: 'لا توجد خيارات نشطة متاحة للربط',
    en: 'No active options are available to link',
  ),
  removeLinkConfirmation(
    ar: 'سيُحذف صف الربط فقط ولن تتأثر المنتجات الموجودة. هل تريد المتابعة؟',
    en: 'Only the link row will be removed; existing products will not change. Continue?',
  ),
  publishedProductsWarning(
    ar: 'يوجد {count} منتج منشور. قد يمنع التحقق من النشر تغيير حالة منتج لاحقاً.',
    en: '{count} products are published. The publish guard may reject a later product status change.',
  ),
  busy(ar: 'جارٍ المعالجة', en: 'Processing'),
  retry(ar: 'إعادة المحاولة', en: 'Retry');

  const ProductTypesKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'producttypes.$name';
}
