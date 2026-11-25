# مراجعة دمج مواصفات CAT-01 وCAT-07 مقابل الفرع vscode

**تاريخ المراجعة:** 2026-11-25  
**الفرع المرجعي:** vscode — HEAD `b1d612311cdc88f04b46d6a303f6a4828d72f3b4`  
**فرع العمل:** `docs/catalog-ui-specs-reconcile`  
**النطاق:** docs فقط؛ لا تغييرات Dart أو migrations أو قاعدة البيانات.

## نتيجة الفحص
- توجد implementations وtests وDI لـ Brands وColors. لم تُستبدل الوثائق الموجودة أو تحليلات هاتين الميزتين.
- `CAT-07_colors.md` موجود بالفعل، ولم يتم overwrite بملف patch.
- لم تظهر features المنتجات/التصنيفات/أنواع المنتجات/المقاسات/الوحدات/الخصائص/الخيارات/الجداول المرجعية في شجرة catalog. أضيفت specs كتصور غير منفذ.
- مواصفة البراند الحالية باقية؛ لا تعديل عليها.

## المراجع التي تمت قراءتها
AGENTS.md، CLAUDE.md، design README، spec template، build playbook، guidelines، decisions log، architecture rules، CORE_MAP، DESIGN_SYSTEM، ADR-0003، list page template، crud engine analysis، DATA_MODEL، scenario 03_catalog_pricing، ERP_Screen_Navigation_Map، V1_SCOPE، A3 permissions.

## تحفظات
1. المسارات المقترحة لم تُسجل في route registry ولم يثبت وجودها.
2. أسماء APIs وPostgREST relations والتضمينات وCore widgets لا تُعتبر عقوداً إلا بعد فحص المصدر عند التنفيذ.
3. DATA_MODEL لقطة توثيق بتاريخها المعلن، وليست قراءة مباشرة من Supabase الحية.
4. PermissionGate تحسين UX، وRLS حماية الخادم.
5. لا migration أو RPC أو View أو UI جديدة.
6. مراجعة static عبر GitHub: لم تشغّل Dart/Flutter format/analyze/tests ولم يتم الاتصال بقاعدة Supabase live.

## الملفات المضافة
CAT-01_products_list.md، CAT-07_categories.md، CAT-07_product_types.md، CAT-07_size_systems.md، CAT-07_units.md، CAT-07_attributes_options.md، CAT-07_descriptive_tables.md، CAT-07_master_data_common.md.

لا دمج إلى vscode.

## ملحق تدقيق الاستعادة — 2026-11-25

هذه المراجعة السابقة لا تعني أن محتوى ملف patch الأصلي قد نُقل كاملاً إلى هذه النسخ. عند إعادة الفحص تبيّن أن ملفات المواصفات الموجودة في هذا الفرع مختصرة مقارنة بالمصادر الأصلية المرفقة؛ لذلك لا يجوز اعتبارها بديلاً مكتملاً عنها أو الادعاء بأن جميع التفاصيل الأصلية محفوظة داخل Git.

### جرد المصدر الأصلي

| الملف | أسطر المصدر الأصلي |
|---|---:|
| CAT-01_products_list.md | 228 |
| CAT-07_attributes_options.md | 125 |
| CAT-07_categories.md | 141 |
| CAT-07_colors.md | 121 |
| CAT-07_descriptive_tables.md | 120 |
| CAT-07_master_data_common.md | 158 |
| CAT-07_product_types.md | 130 |
| CAT-07_size_systems.md | 130 |
| CAT-07_units.md | 111 |
| SPEC_FORMAT_REVIEW.md | 46 |

### ما ثبت من الكود على vscode

- شجرة `lib/app/features/catalog` تضم ميزتي `brands` و`colors`، إضافة إلى `di` و`presentation` المشتركة؛ ولم تظهر مجلدات تنفيذ للمنتجات أو التصنيفات أو أنواع المنتجات أو أنظمة المقاسات أو الوحدات أو الخصائص والخيارات أو الجداول الوصفية.
- توجد implementations فعلية منفصلة لـ Brands وColors، ولذلك يجب إبقاء وثائقهما وتحليلاتهما السابقة وعدم استبدالها بمسودات عامة.
- يوجد بالفعل `CAT-07_colors.md` و`CAT-COLORS.md` في هذا الفرع، وهما وثيقتان مختلفتان. لا يُستبدل أي منهما تلقائياً بملف المصدر الذي يحمل الاسم نفسه؛ يلزم دمج محافظ يحفظ جميع المعلومات ويبيّن التعارضات.
- تعليمات المستودع في `AGENTS.md` و`CLAUDE.md` تؤكد أن الكود الفعلي هو المرجع، وأن هذه المهمة توثيقية فقط، ولا تجيز ادعاء تشغيل Flutter أو الاختبارات دون تنفيذها.

### حالة الاستعادة

**غير مكتملة.** النسخ المختصرة الموجودة لا تحفظ كامل تفاصيل المصدر الأصلي، ولم تُستبدل بها بعد. يجب أن تتم الخطوة التالية بنقل النصوص الأصلية كاملة إلى ملفات Git المناسبة، ثم إضافة ملاحق مطابقة للكود عند وجود تعارض، دون حذف أو إعادة صياغة صامتة. لا دمج إلى `vscode`.
