# Progress — feat/catalog-seasons-collections

## الحالة الحالية

- الفرع: `feat/catalog-seasons-collections`.
- الهدف: `integration/catalog-scope-1-combined`.
- آخر تحديث: 2026-11-28.
- التنفيذ البرمجي للميزتين وصل إلى مرحلة تكامل أولي، لكنه **غير معتمد للدمج**؛ لم تُشغّل أدوات Dart/Flutter ولم تُراجع نتائج CI بعد التغييرات.

## Core Date Picker

- دُمج فرع `feat/core-date-picker` داخل فرع التنفيذ بعملية **merge commit ذات parentين**، وليس cherry-pick.
- يتضمن الدمج `DateOnly`, `AppDatePickerField`, تحقق نطاق التاريخ، مفاتيح الترجمة والاختبارات.
- لم يُجرَ تشغيل محلي لـ `dart format`, `flutter analyze` أو `flutter test`.

## Seasons

- أُنشئت طبقات domain/data/presentation/DI، مع كيان typed وDraft وPagedQuery.
- الحقول المطابقة لجدول قاعدة البيانات: `name`, `code`, `season_type`, `start_date`, `end_date`, `is_active`. لم يُضف حقل description لأنه غير موجود في عقد الجدول.
- استعلام PostgREST يفلتر بالنوع والحالة والبحث، والفرز الافتراضي `start_date`, ثم `name`, ثم `id`.
- أُضيف نموذج التحرير مع `AppDatePickerField`، وصفحة القائمة، route ثابت، DI، مفاتيح الترجمة وبطاقة Catalog Hub.
- الإجراءات الجماعية معطلة كما يحدد CAT-07.
- أُضيفت اختبارات للـ query/model؛ لم تُشغّل.

## Collections

- أُنشئت طبقات domain/data/presentation/DI، مع typed entity/draft/query وPostgREST repository.
- الحقول: `name`, `code`, `description`, `image`, `start_date`, `end_date`, `is_active`.
- أُضيف `AppDatePickerField` للتاريخين، و`AppImageUploadField` للرفع إلى `product-images/collections/` وفق سياسة 5 MB وJPEG/PNG/WebP.
- أُضيف route ثابت، DI، مفاتيح الترجمة وبطاقة Catalog Hub.
- أُضيفت اختبارات للـ query/model؛ لم تُشغّل.

## الربط والتوثيق

- تم ربط الميزتين في `catalog_di.dart`, `route_registry.dart`, `app_go_router.dart`, `key_registry.dart` و`CatalogHubScreen`.
- تم تحديث `CAT-07_descriptive_tables.md` لتسجيل تنفيذ Core Date Picker والميزتين وحالة التحقق.
- تم توثيق استخدام سياسة Storage المعتمدة B-32؛ لم يتم اختبار رفع حي أو صلاحيات Supabase في هذه الجلسة.
- لم تُلمس `product_types` أو `size_systems`.

## القرارات/القيود المتبقية

1. قرار D-DT-1 معتمد: الكود يمنع حفظ `start_date > end_date` في الواجهة. لا يوجد CHECK في قاعدة البيانات بحسب DATA_MODEL، لذا لا يحمي الكتابات الخارجية.
2. لا يوجد Flutter/Dart SDK في بيئة التنفيذ؛ لذلك لا يمكن تأكيد التنسيق أو التحليل أو الاختبارات.
3. اختبارات Repository وواجهات CRUD/رفع الصور لم تكتمل بعد.
4. يجب تشغيل Dart 3.38.1 formatter، ثم `flutter analyze` و`flutter test`، وإصلاح كل النتائج قبل طلب المراجعة.
5. يجب اختبار Storage فعلياً بحساب يملك `masterdata.manage` دون `catalog.manage` وبحساب لا يملك `masterdata.manage`.
6. يجب مراجعة diff كاملاً ومزامنة الفرع مع الهدف قبل فتح PR.

## حالة PR

- لا يوجد PR مفتوح.
- لا يوجد دمج في `integration/catalog-scope-1-combined`.
- لا تعتبر الميزتان جاهزتين للدمج حتى اجتياز الفحوصات والمراجعة أعلاه.
