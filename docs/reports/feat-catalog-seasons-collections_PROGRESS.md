# Progress — feat/catalog-seasons-collections

## الحالة النهائية

- الفرع الهدف: `integration/catalog-scope-1-combined`.
- تاريخ التكامل: 2026-11-28.
- تم دمج الفروع الأربعة بالترتيب المطلوب:
  1. `feat/core-date-picker` — كان موجوداً مسبقاً في تاريخ فرع التكامل.
  2. `fix/scope-1-catalog-review` — كان مدمجاً مسبقاً عبر PR #22.
  3. `feat/cat07-care-instructions`.
  4. `feat/catalog-seasons-collections`.
- تم دمج الميزتين الأخيرتين بدمجين متسلسلين، ثم دمج PR التكامل #24 في الفرع الهدف.
- Merge commit: `171ff50aa5fe56230e3816cef2001486e912b7b1`.
- PR التكامل: https://github.com/AhmadKabawa/my_accounting_software/pull/24

## Core Date Picker

- موجود في الفرع الهدف قبل دمج الميزتين الأخيرتين.
- يتضمن `DateOnly`, `AppDatePickerField`, تحقق نطاق التاريخ، مفاتيح الترجمة والاختبارات.
- تم الحفاظ على هذه التغييرات أثناء حل تعارضات التسجيل والملفات المشتركة.

## Seasons

- طبقات domain/data/presentation/DI مع كيان typed وDraft وPagedQuery.
- الحقول المطابقة لعقد الجدول: `name`, `code`, `season_type`, `start_date`, `end_date`, `is_active`.
- PostgREST filters للنوع والحالة والبحث، والفرز الافتراضي `start_date`, ثم `name`, ثم `id`.
- نموذج التحرير يستخدم `AppDatePickerField`، مع صفحة القائمة وroute وDI ومفاتيح الترجمة وبطاقة Catalog Hub.
- الإجراءات الجماعية معطلة وفق CAT-07.

## Collections

- طبقات domain/data/presentation/DI مع typed entity/draft/query وPostgREST repository.
- الحقول: `name`, `code`, `description`, `image`, `start_date`, `end_date`, `is_active`.
- يستخدم `AppDatePickerField` للتاريخين و`AppImageUploadField` للرفع إلى `product-images/collections/`.
- سياسة الرفع الموثقة: 5 MB وJPEG/PNG/WebP.
- route وDI ومفاتيح الترجمة وبطاقة Catalog Hub مضافة.

## حل تعارضات التكامل

- جُمعت تسجيلات Catalog DI للميزات الثلاث.
- جُمعت GoRouter routes وroute registry وتصنيف المسارات المحمية.
- حُفظ تصميم Catalog Hub المجمع وأضيفت بطاقات تعليمات العناية والمواسم والمجموعات.
- جُمعت مفاتيح الترجمة في `key_registry.dart` مع الاحتفاظ بمفاتيح DatePicker.
- جُمعت تغييرات CAT-07، وتم تحديث اختبار عدد بطاقات Catalog Hub.
- عولجت مشكلة تكرار مفاتيح CareInstructions، وحماية مسارات Seasons/Collections، والقيم البديلة غير المترجمة، واستخدام spacing token.
- لم تُغيّر ملفات `product_types` أو `size_systems`.

## التحقق

- Dart formatting: **نجح** على commit `318c4309765b7281310e7c7644955606a732e958`.
- `flutter analyze`: **نجح**.
- `flutter test`: **1639 اختباراً ناجحاً و26 فاشلاً**.
- لم تظهر ملفات اختبارات Care Instructions أو Seasons أو Collections ضمن قائمة الاختبارات الفاشلة.
- الإخفاقات الـ26 المتبقية تخص ملفات/ميزات أخرى غير معدّلة في هذا الدمج: ترتيب AppSidebar، تدفق محرر Categories، مصفوفة تخطيطات Option Sets، محرر Attributes، تنسيق مفتاح Materials، حد طول ملف محرر Attributes، وأرقام ثابتة في Product Types.
- لم يُجرَ اختبار حي لـ Supabase/PostgREST أو Storage؛ يلزم اختبار صلاحيات ورفع الصور في بيئة Supabase الفعلية.

## قيود/قرارات معروفة

1. قرار D-DT-1: يمنع التطبيق حفظ `start_date > end_date`. لا يوجد CHECK في قاعدة البيانات بحسب DATA_MODEL، لذلك لا يحمي الكتابات الخارجية.
2. يلزم اختبار Storage بحساب يملك `masterdata.manage` دون `catalog.manage` وبحساب لا يملك `masterdata.manage`.
3. حالة الاختبارات العامة موثقة أعلاه؛ لا تُنسب إخفاقات الوحدات غير المعدّلة إلى ميزات هذا الدمج.
