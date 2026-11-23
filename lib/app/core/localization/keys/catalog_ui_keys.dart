import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Shared labels for reusable catalog/list UI primitives.
enum CatalogUiKeys implements AppKey {
  search(ar: 'بحث', en: 'Search'),
  clearSearch(ar: 'مسح البحث', en: 'Clear search'),
  chooseOption(ar: 'اختر قيمة', en: 'Choose an option'),
  allOptions(ar: 'الكل', en: 'All'),
  clearSelection(ar: 'مسح الاختيار', en: 'Clear selection'),
  selectedCount(ar: 'تم تحديد {count} سجل', en: '{count} selected'),
  bulkFailed(ar: 'فشلت العملية الجماعية لكل السجلات المحددة.', en: 'The bulk operation failed for all selected records.'),
  bulkPartiallyFailed(ar: 'نجحت العملية لبعض السجلات وفشلت لسجلات أخرى.', en: 'The bulk operation partially failed.'),
  bulkResultTitle(ar: 'نتيجة العملية الجماعية', en: 'Bulk operation result'),
  bulkResultSummary(ar: 'نجح {success} سجل وفشل {failure} سجل.', en: '{success} records succeeded and {failure} failed.'),
  bulkFailureLine(ar: '{name}: {reason}', en: '{name}: {reason}'),
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
  thenBy(ar: 'ثم حسب', en: 'Then by'),
  none(ar: 'بلا', en: 'None'),
  sortFieldAlreadySelected(ar: 'لا يمكن اختيار الحقل نفسه في معياري الفرز.', en: 'The same field cannot be selected for both sort criteria.'),
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
