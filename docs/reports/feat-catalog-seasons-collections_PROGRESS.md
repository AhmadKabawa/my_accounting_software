# Progress — feat/catalog-seasons-collections

## الحالة
- بدأ العمل على الفرع `feat/catalog-seasons-collections` من `integration/catalog-scope-1-combined`.
- تمت قراءة الوثائق المطلوبة بالترتيب حتى مواصفة CAT-07 المشتركة ومرجع DATA_MODEL.
- عقد الجدولين مؤكد في DATA_MODEL: `seasons` و`collections`، والقراءة مفتوحة والكتابة تتطلب `masterdata.manage`.
- `seasons`: `name(100)`, `code(50)`, `season_type`, `start_date`, `end_date`, `is_active`; UNIQUE(code)، بلا sort_order.
- `collections`: حقولها كما في CAT-07 §6؛ الربط `product_collections` يمنع الحذف المرجعي عملياً.
- Storage: bucket `product-images` حد 5MB وأنواع JPEG/PNG/WebP. توجد سياسة masterdata_images_insert لمجلد collections، لكن هذا لا يثبت أن الرفع الحي يعمل؛ يجب التحقق من بقية السياسات/التطبيق.
- فرع `feat/core-date-picker` موجود على GitHub؛ لم يُحدّد مسار AppDatePickerField بعد، لذا لم يحدث merge بعد.
- لم تُنفذ تعديلات الميزتين بعد.

## CI
- لا يوجد CI خاص بهذا الفرع حتى الآن.

## المتبقي
1. استكمال تدقيق ملفات backend ذات الصلة وسياسات Storage.
2. فحص بنية materials وfabric_types الفعلية ونسخ النمط لكل ميزة.
3. تنفيذ seasons ثم collections مع الاختبارات.
4. دمج Core Date Picker والتحقق من واجهته وإضافة حقول التاريخ إن أمكن.
5. تسجيل المسارات وDI ومفاتيح الترجمة وبطاقات المركز في commit أخير مستقل بعد مزامنة الفرع الأساسي.
6. تحديث حالة CAT-07 وفتح PR نحو integration/catalog-scope-1-combined.

## القيود
- لا Flutter SDK؛ التحقق عبر GitHub CI فقط.
- لا اختبار حي لـ Supabase أو Storage.
