import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Shared labels for reusable catalog/list UI primitives.
enum CatalogUiKeys implements AppKey {
  search(ar: 'بحث', en: 'Search'),
  chooseOption(ar: 'اختر قيمة', en: 'Choose an option'),
  noOptions(ar: 'لا توجد خيارات مطابقة', en: 'No matching options'),
  filters(ar: 'الفلاتر', en: 'Filters'),
  activeFilters(ar: 'الفلاتر النشطة', en: 'Active filters'),
  clearAll(ar: 'مسح الكل', en: 'Clear all'),
  apply(ar: 'تطبيق', en: 'Apply'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  previousPage(ar: 'السابق', en: 'Previous'),
  nextPage(ar: 'التالي', en: 'Next'),
  loadMore(ar: 'تحميل المزيد', en: 'Load more'),
  rowsPerPage(ar: 'عدد الصفوف', en: 'Rows per page'),
  page(ar: 'صفحة', en: 'Page'),
  of(ar: 'من', en: 'of'),
  selectAll(ar: 'تحديد الكل', en: 'Select all'),
  selected(ar: 'محدد', en: 'selected'),
  sortBy(ar: 'ترتيب حسب', en: 'Sort by'),
  paginationLabel(ar: 'صفحة @page من @lastPage', en: 'Page @page of @lastPage'),
  sortAscending(ar: 'ترتيب تصاعدي', en: 'Sort ascending'),
  sortDescending(ar: 'ترتيب تنازلي', en: 'Sort descending'),
  loading(ar: 'جارٍ التحميل', en: 'Loading'),
  emptyTitle(ar: 'لا توجد بيانات', en: 'No data'),
  emptyDescription(ar: 'لا توجد سجلات لعرضها', en: 'There are no records to display'),
  retry(ar: 'إعادة المحاولة', en: 'Retry');

  const CatalogUiKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'catalogui.$name';
}
