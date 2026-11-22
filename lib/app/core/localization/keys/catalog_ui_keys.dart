import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Shared labels for reusable catalog/list UI primitives.
enum CatalogUiKeys implements AppKey {
  search(ar: 'بحث', en: 'Search'),
  clearSearch(ar: 'مسح البحث', en: 'Clear search'),
  chooseOption(ar: 'اختر قيمة', en: 'Choose an option'),
  allOptions(ar: 'الكل', en: 'All'),
  clearSelection(ar: 'مسح الاختيار', en: 'Clear selection'),
  noOptions(ar: 'لا توجد خيارات مطابقة', en: 'No matching options'),
  filters(ar: 'الفلاتر', en: 'Filters'),
  activeFilters(ar: 'الفلاتر النشطة', en: 'Active filters'),
  activeFilterLabel(ar: '{label}: {value}', en: '{label}: {value}'),
  removeFilter(ar: 'إزالة الفلتر', en: 'Remove filter'),
  clearAll(ar: 'مسح الكل', en: 'Clear all'),
  apply(ar: 'تطبيق', en: 'Apply'),
  previousPage(ar: 'السابق', en: 'Previous'),
  nextPage(ar: 'التالي', en: 'Next'),
  loadMore(ar: 'تحميل المزيد', en: 'Load more'),
  rowsPerPage(ar: 'عدد الصفوف', en: 'Rows per page'),
  sortBy(ar: 'ترتيب حسب', en: 'Sort by'),
  sortDirection(ar: 'الاتجاه', en: 'Direction'),
  done(ar: 'تم', en: 'Done'),
  paginationLabel(
    ar: 'صفحة {page} من {lastPage}',
    en: 'Page {page} of {lastPage}',
  ),
  emptyTitle(ar: 'لا توجد بيانات', en: 'No data'),
  emptyDescription(
    ar: 'لا توجد سجلات لعرضها',
    en: 'There are no records to display',
  ),
  showingOf(ar: 'عرض {shown} من {total}', en: 'Showing {shown} of {total}'),
  pageNumber(ar: 'صفحة {page}', en: 'Page {page}'),
  viewMode(ar: 'طريقة العرض', en: 'View mode'),
  viewTable(ar: 'جدول', en: 'Table'),
  viewCards(ar: 'بطاقات', en: 'Cards'),
  viewGrid(ar: 'شبكة', en: 'Grid'),
  sortAscendingLabel(ar: 'تصاعدي', en: 'Ascending'),
  sortDescendingLabel(ar: 'تنازلي', en: 'Descending'),
  resultsCount(ar: '{count} نتيجة', en: '{count} results'),
  selectRow(ar: 'تحديد الصف', en: 'Select row'),
  moreActions(ar: 'المزيد', en: 'More actions'),
  refresh(ar: 'تحديث البيانات', en: 'Refresh data'),
  retry(ar: 'إعادة المحاولة', en: 'Retry');

  const CatalogUiKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'catalogui.$name';
}
