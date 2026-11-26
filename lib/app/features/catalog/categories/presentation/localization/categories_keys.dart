import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum CategoriesKeys implements AppKey {
  title(ar: 'التصنيفات', en: 'Categories'),
  details(ar: 'تفاصيل التصنيف', en: 'Category details'),
  closeDetails(ar: 'إغلاق التفاصيل', en: 'Close details'),
  directChildren(ar: 'التصنيفات الفرعية المباشرة', en: 'Direct subcategories'),
  descendantCount(ar: 'كل الأحفاد', en: 'All descendants'),
  add(ar: 'إضافة تصنيف', en: 'Add category'),
  addChild(ar: 'إضافة تصنيف فرعي', en: 'Add subcategory'),
  edit(ar: 'تعديل التصنيف', en: 'Edit category'),
  duplicate(ar: 'نسخ التصنيف', en: 'Duplicate category'),
  // `name` would shadow the enum value-name lookup used by the key getter.
  categoryName(ar: 'اسم التصنيف', en: 'Category name'),
  parent(ar: 'التصنيف الأب', en: 'Parent category'),
  parentHint(
    ar: 'اتركه فارغاً لإنشاء تصنيف رئيسي.',
    en: 'Leave empty to create a top-level category.',
  ),
  noParent(ar: 'بدون أب (تصنيف رئيسي)', en: 'No parent (top level)'),
  slug(ar: 'الرابط المختصر (slug)', en: 'Slug'),
  slugHint(
    ar: 'حروف إنجليزية صغيرة وأرقام وشرطات، مثل men-shoes. يُولَّد من الاسم اللاتيني ويمكنك تعديله.',
    en: 'Lowercase English letters, numbers and hyphens, like men-shoes. Generated from a Latin name; you can edit it.',
  ),
  regenerateSlug(ar: 'توليد من الاسم', en: 'Generate from name'),
  description(ar: 'الوصف', en: 'Description'),
  imageSection(ar: 'صورة التصنيف', en: 'Category image'),
  uploadImage(ar: 'رفع الصورة', en: 'Upload image'),
  replaceImage(ar: 'استبدال الصورة', en: 'Replace image'),
  removeImage(ar: 'إزالة الصورة', en: 'Remove image'),
  imageUploadPermission(
    ar: 'رفضت سياسة Storage رفع الصورة. يلزم منح masterdata.manage صلاحية الكتابة على مجلد categories داخل product-images.',
    en: 'Storage rejected this upload. The categories folder in product-images needs a write policy for masterdata.manage.',
  ),
  duplicateSuffix(ar: 'نسخة', en: 'Copy'),
  sortOrder(ar: 'ترتيب الظهور (اختياري)', en: 'Display order (optional)'),
  sortOrderHint(
    ar: 'الأصغر أولاً بين التصنيفات التي تحت الأب نفسه.',
    en: 'Lower first among categories under the same parent.',
  ),
  identitySection(ar: 'هوية التصنيف', en: 'Category identity'),
  placementSection(ar: 'الموضع في الشجرة', en: 'Position in the tree'),
  editorSubtitle(
    ar: 'حدد اسم التصنيف وموضعه في الشجرة كما سيظهر عند ربطه بالمنتجات.',
    en: 'Set the category name and its place in the tree as it will appear when assigned to products.',
  ),
  siblingNameWarning(
    ar: 'يوجد تصنيف بالاسم نفسه تحت الأب نفسه. يمكنك المتابعة، لكن قد يلتبس على المستخدمين.',
    en: 'A category with this name already exists under the same parent. You can continue, but it may confuse users.',
  ),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  active(ar: 'فعّال', en: 'Active'),
  activeOnCreate(ar: 'نشط عند الإنشاء', en: 'Active on create'),
  inactive(ar: 'موقوف', en: 'Inactive'),
  underInactiveParent(ar: 'تحت أب موقوف', en: 'Under inactive parent'),
  status(ar: 'الحالة', en: 'Status'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  level(ar: 'المستوى', en: 'Level'),
  allLevels(ar: 'كل المستويات', en: 'All levels'),
  roots(ar: 'التصنيفات الرئيسية', en: 'Root categories'),
  leaves(ar: 'التصنيفات الورقية', en: 'Leaf categories'),
  usage(ar: 'الاستخدام', en: 'Usage'),
  allUsage(ar: 'كل الاستخدامات', en: 'All usage'),
  withProducts(ar: 'بمنتجات', en: 'With products'),
  withoutProducts(ar: 'بلا منتجات', en: 'Without products'),
  sortByName(ar: 'الاسم', en: 'Name'),
  sortByOrder(ar: 'ترتيب العرض', en: 'Display order'),
  sortByProducts(ar: 'عدد المنتجات', en: 'Product count'),
  totalCategories(ar: 'كل التصنيفات', en: 'All categories'),
  activeCategories(ar: 'النشطة', en: 'Active'),
  inactiveCategories(ar: 'الموقوفة', en: 'Inactive'),
  rootStats(ar: 'الجذور', en: 'Roots'),
  leafStats(ar: 'بلا أبناء', en: 'Leaves'),
  noProductStats(ar: 'بلا منتجات', en: 'No products'),
  clearFilters(ar: 'مسح الفلاتر', en: 'Clear filters'),
  searchHint(
    ar: 'ابحث باسم التصنيف أو الرابط المختصر',
    en: 'Search by category name or slug',
  ),
  expandAll(ar: 'توسيع الكل', en: 'Expand all'),
  collapseAll(ar: 'طي الكل', en: 'Collapse all'),
  expandRow(ar: 'فتح الفروع', en: 'Show subcategories'),
  collapseRow(ar: 'طي الفروع', en: 'Hide subcategories'),
  flatResultsNote(
    ar: 'نتائج البحث والفلترة تُعرض مسطحة مع مسار التصنيف.',
    en: 'Search and filter results are shown flat, with the category path.',
  ),
  childrenCount(ar: '{count} فرعي', en: '{count} sub'),
  productsCount(ar: '{count} منتج', en: '{count} products'),
  slugLabel(ar: 'الرابط: {slug}', en: 'Slug: {slug}'),
  topLevel(ar: 'رئيسي', en: 'Top level'),
  path(ar: 'المسار', en: 'Path'),
  products(ar: 'المنتجات', en: 'Products'),
  updatedAt(ar: 'آخر تحديث', en: 'Last updated'),
  subcategories(ar: 'الفروع', en: 'Subcategories'),
  empty(ar: 'لا توجد تصنيفات بعد', en: 'No categories yet'),
  emptyDescription(
    ar: 'أنشئ تصنيفات رئيسية وفرعية لتنظيم منتجاتك.',
    en: 'Create top-level and sub categories to organize your products.',
  ),
  noResults(ar: 'لا توجد نتائج مطابقة', en: 'No matching categories'),
  noResultsDescription(
    ar: 'جرّب تغيير عبارة البحث أو حالة التصنيف.',
    en: 'Try changing the search term or category status.',
  ),
  loadError(ar: 'تعذر تحميل التصنيفات', en: 'Could not load categories'),
  saveError(
    ar: 'تعذر حفظ التصنيف. تحقق من الاتصال والصلاحيات ثم حاول مجدداً.',
    en: 'Could not save the category. Check your connection and permissions, then try again.',
  ),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  nameTooLong(
    ar: 'يجب ألا يتجاوز الاسم 150 حرفاً.',
    en: 'The name must be 150 characters or fewer.',
  ),
  slugTooLong(
    ar: 'يجب ألا يتجاوز الرابط المختصر 150 حرفاً.',
    en: 'The slug must be 150 characters or fewer.',
  ),
  slugFormat(
    ar: 'استخدم حروفاً إنجليزية صغيرة وأرقاماً وشرطات فقط، دون شرطة في البداية أو النهاية.',
    en: 'Use lowercase English letters, numbers and hyphens only, with no leading or trailing hyphen.',
  ),
  imageFormat(
    ar: 'أدخل رابطاً صحيحاً يبدأ بـ http أو https.',
    en: 'Enter a valid link starting with http or https.',
  ),
  imageTooLong(
    ar: 'يجب ألا يتجاوز الرابط 500 حرف.',
    en: 'The link must be 500 characters or fewer.',
  ),
  sortOrderFormat(
    ar: 'أدخل رقماً صحيحاً صفراً أو أكبر.',
    en: 'Enter a whole number, zero or greater.',
  ),
  activate(ar: 'إعادة تفعيل', en: 'Reactivate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  delete(ar: 'حذف', en: 'Delete'),
  bulkActivate(ar: 'تفعيل المحدد', en: 'Activate selected'),
  bulkDeactivate(ar: 'إيقاف المحدد', en: 'Deactivate selected'),
  bulkDelete(ar: 'حذف المحدد', en: 'Delete selected'),
  bulkDeactivateTitle(
    ar: 'إيقاف التصنيفات المحددة',
    en: 'Deactivate selected categories',
  ),
  bulkDeactivateMessage(
    ar: 'سيتم إيقاف التصنيفات المحددة مع إبقاء التصنيفات الفرعية فعّالة.',
    en: 'Selected categories will be deactivated; their subcategories remain active.',
  ),
  bulkDeleteTitle(
    ar: 'حذف التصنيفات المحددة',
    en: 'Delete selected categories',
  ),
  bulkDeleteMessage(
    ar: 'سيتم حذف الفروع قبل الآباء. العناصر التي لا يمكن حذفها ستظهر ضمن نتائج العملية.',
    en: 'Children are deleted before parents. Categories that cannot be deleted will be listed in the operation results.',
  ),
  tableView(ar: 'عرض الجدول', en: 'Table view'),
  deleted(ar: 'تم حذف التصنيف.', en: 'Category deleted.'),
  deleteTitle(ar: 'حذف التصنيف', en: 'Delete category'),
  deleteMessage(
    ar: 'هل تريد حذف التصنيف {name}؟',
    en: 'Delete category {name}?',
  ),
  deactivateTitle(ar: 'إيقاف التصنيف', en: 'Deactivate category'),
  deactivateMessage(
    ar: 'سيتم إيقاف التصنيف مع الاحتفاظ به وبسجلاته، ولن يظهر عند اختيار تصنيفات جديدة.',
    en: 'This category will be deactivated while keeping its record. It will not be offered for new selections.',
  ),
  deactivateWithChildrenMessage(
    ar: 'سيتم إيقاف التصنيف. له {count} تصنيف فرعي فعّال سيبقى فعّالاً.',
    en: 'This category will be deactivated. Its {count} active subcategories will stay active.',
  ),
  saved(ar: 'تم حفظ التصنيف.', en: 'Category saved.'),
  statusUpdated(ar: 'تم تحديث حالة التصنيف.', en: 'Category status updated.');

  const CategoriesKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => this == CategoriesKeys.categoryName
      ? 'categories.name'
      : 'categories.$name';
}
