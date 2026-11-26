import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum TagsKeys implements AppKey {
  title(ar: 'الوسوم', en: 'Tags'),
  add(ar: 'إضافة وسم', en: 'Add tag'),
  edit(ar: 'تعديل الوسم', en: 'Edit tag'),
  // `name` would shadow the enum value-name lookup used by the key getter.
  tagName(ar: 'اسم الوسم', en: 'Tag name'),
  slug(ar: 'المعرّف (slug)', en: 'Slug'),
  slugHint(
    ar: 'حروف إنجليزية صغيرة وأرقام وشرطات، مثل new-arrival',
    en: 'Lowercase English letters, numbers and hyphens, for example new-arrival',
  ),
  slugLatinHint(
    ar: 'اكتب المعرّف بحروف إنجليزية؛ لا يمكن توليده من اسم عربي.',
    en: 'Type the slug in English letters; it cannot be generated from this name.',
  ),
  regenerateSlug(
    ar: 'إعادة توليد المعرّف من الاسم',
    en: 'Regenerate from name',
  ),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  active(ar: 'فعّال', en: 'Active'),
  inactive(ar: 'موقوف', en: 'Inactive'),
  status(ar: 'الحالة', en: 'Status'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  searchHint(ar: 'ابحث باسم الوسم أو معرّفه', en: 'Search by tag name or slug'),
  totalTags(ar: 'إجمالي الوسوم', en: 'Total tags'),
  activeTags(ar: 'الوسوم الفعالة', en: 'Active tags'),
  inactiveTags(ar: 'الوسوم الموقوفة', en: 'Inactive tags'),
  empty(ar: 'لا توجد وسوم بعد', en: 'No tags yet'),
  emptyDescription(
    ar: 'أضف وسوماً حرة (مثل وصل حديثاً أو تخفيضات) لتصنّف بها المنتجات وتبحث عنها لاحقاً.',
    en: 'Add free-form tags (such as new arrival or sale) to label products and find them later.',
  ),
  noResults(ar: 'لا توجد نتائج مطابقة', en: 'No matching tags'),
  noResultsDescription(
    ar: 'جرّب تغيير عبارة البحث أو حالة الوسم.',
    en: 'Try changing the search term or tag status.',
  ),
  loadError(ar: 'تعذر تحميل الوسوم', en: 'Could not load tags'),
  saveError(
    ar: 'تعذر حفظ الوسم. تحقق من الاتصال والصلاحيات ثم حاول مجدداً.',
    en: 'Could not save the tag. Check your connection and permissions, then try again.',
  ),
  duplicateError(
    ar: 'اسم الوسم أو معرّفه مستخدم مسبقاً. اختر قيمة مختلفة.',
    en: 'This tag name or slug is already in use. Choose a different value.',
  ),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  nameTooLong(
    ar: 'يجب ألا يتجاوز الاسم 100 حرف.',
    en: 'The name must be 100 characters or fewer.',
  ),
  slugTooLong(
    ar: 'يجب ألا يتجاوز المعرّف 100 حرف.',
    en: 'The slug must be 100 characters or fewer.',
  ),
  slugFormat(
    ar: 'استخدم حروفاً إنجليزية صغيرة وأرقاماً وشرطات فقط، بلا شرطة في البداية أو النهاية.',
    en: 'Use only lowercase English letters, numbers and hyphens, with no leading or trailing hyphen.',
  ),
  identitySection(ar: 'هوية الوسم', en: 'Tag identity'),
  editorSubtitle(
    ar: 'أدخل اسم الوسم ومعرّفه كما سيظهران عند ربطهما بالمنتجات.',
    en: 'Enter the tag name and slug as they will appear when assigned to products.',
  ),
  activate(ar: 'إعادة تفعيل', en: 'Reactivate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  delete(ar: 'حذف', en: 'Delete'),
  deleted(ar: 'تم حذف الوسم.', en: 'Tag deleted.'),
  deleteTitle(ar: 'حذف الوسم', en: 'Delete tag'),
  deleteMessage(ar: 'هل تريد حذف الوسم {name}؟', en: 'Delete tag {name}?'),
  deactivateTitle(ar: 'إيقاف الوسم', en: 'Deactivate tag'),
  deactivateMessage(
    ar: 'سيتم إيقاف الوسم مع الاحتفاظ به وبسجلاته، ولن يظهر عند اختيار وسوم جديدة.',
    en: 'This tag will be deactivated while keeping its record. It will not be offered for new selections.',
  ),
  saved(ar: 'تم حفظ الوسم.', en: 'Tag saved.'),
  statusUpdated(ar: 'تم تحديث حالة الوسم.', en: 'Tag status updated.'),
  sortByName(ar: 'الاسم', en: 'Name'),
  sortBySlug(ar: 'المعرّف', en: 'Slug'),
  duplicate(ar: 'مضاعفة', en: 'Duplicate'),
  duplicateTitle(ar: 'مضاعفة وسم', en: 'Duplicate tag'),
  duplicateSuffix(ar: '(نسخة)', en: '(Copy)'),
  duplicateSlugSuffix(ar: '-copy', en: '-copy'),
  bulkActivate(ar: 'تفعيل المحدد', en: 'Activate selected'),
  bulkDeactivate(ar: 'إيقاف المحدد', en: 'Deactivate selected'),
  bulkDelete(ar: 'حذف المحدد', en: 'Delete selected'),
  bulkDeactivateTitle(
    ar: 'إيقاف الوسوم المحددة',
    en: 'Deactivate selected tags',
  ),
  bulkDeactivateMessage(
    ar: 'سيتم إيقاف {count} وسم مع الاحتفاظ بسجلاتها.',
    en: '{count} tags will be deactivated and retained.',
  ),
  bulkDeleteTitle(ar: 'حذف الوسوم المحددة', en: 'Delete selected tags'),
  bulkDeleteMessage(
    ar: 'سيتم حذف {count} وسم.',
    en: '{count} tags will be deleted.',
  );

  const TagsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => this == TagsKeys.tagName ? 'tags.name' : 'tags.$name';
}
