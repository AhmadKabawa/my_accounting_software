# خطة واجهة أنواع المنتجات — CAT-07

الحالة: خطة التنفيذ، وليست إثباتاً لاكتمال الشاشة.

## المرحلة أ — قائمة النوع والمحرر

- المسار: /catalog/product-types
- الإطار: CrudListScreen + CrudListConfig فقط.
- الصلاحية: manageAccess = Permissions.masterData.manage؛ القراءة مفتوحة ولا حارس صلاحية على المسار.
- الأعمدة: الاسم، الرمز بخط ثابت ومحاذاة LTR، عدد المنتجات، الحالة، الوصف، آخر تحديث.
- البحث الخادمي: name وcode مع escaping وdebounce 300ms وآخر طلب يفوز.
- الفرز الخادمي الثابت: sort_order.asc,name.asc,id.asc.
- فلتر واحد: is_active (الكل/نشط/موقوف).
- الإحصاءات المطلوبة: الكل/نشط/موقوف/بلا منتجات. يجب أن تكون مستقلة عن الصفحة الحالية؛ لا تُحسب من عناصر الصفحة. يلزم اختبار دقة عداد بلا منتجات قبل اعتماده.
- capabilities: bulkSelection=false وduplicate=false.
- النقر على الصف يفتح صفحة التفاصيل.
- الحذف مخفي عند أي count موجب أو مجهول. 23503 يعرض خيار الإيقاف.
- code يصبح read-only عند وجود منتج أو ارتباط واحد على الأقل أو count مجهول.
- المحرر: name وcode وdescription وsort_order وis_active. يرسل is_active عند الإنشاء، وفي PATCH فقط إذا تغيّر.
- dirty: مقارنة القيم بعد trim نفسه المستخدم في payload.

## إسقاط PostgREST للمرحلة أ

الإسقاط المفضل الحالي في ProductTypeEndpoints:
- product_types مع products(count)
- product_type_size_groups(count)
- product_type_attributes(count)
- product_type_option_sets(count)
- product_type_care_instructions(count)

إذا رفض PostgREST الإسقاط بـ HTTP 400، fallback بلا علاقات. عندها counts مجهولة، وبالتالي لا حذف ولا تعديل code حتى تتوفر بيانات موثوقة.

## المرحلة ب — صفحة التفاصيل

المسار المقصود: /catalog/product-types/:id. صفحة كاملة بأقسام متتابعة، بلا Tabs، وبلا لوحة تفاصيل ثانوية.

الأقسام الثلاثة فقط:
1. مجموعات المقاسات.
2. الخصائص.
3. مجموعات الخيارات.

تعليمات العناية مؤجلة (D-02) ولا يظهر لها قسم أو بطاقة أو عنصر وهمي.

### مصادر القراءة المملوكة للوحدة

كل مصدر يملكه product_types داخل data/ ولا يستورد من cat08 أو cat09:

| الغرض | الإسقاط المقترح | الفلاتر والترتيب |
|---|---|---|
| مجموعات المقاسات | id,name,code,is_active,size_systems(name) | is_active=eq.true، order=name.asc,id.asc، ثم استبعاد المرتبط |
| الخصائص | id,name,code,is_active,data_type | is_active=eq.true، order=name.asc,id.asc، ثم استبعاد المرتبط |
| مجموعات الخيارات | id,name,code,is_active | is_active=eq.true، order=name.asc,id.asc، ثم استبعاد المرتبط |
| الأجناس | id,name,code,is_active | is_active=eq.true، order=name.asc,id.asc |

هذه استعلامات مخططة وليست منفذة حالياً. لا تعرض منتقياً فارغاً إذا كان الجدول المصدر فارغاً؛ اعرض حالة فارغة واضحة.

### عقود الربط

- المقاسات: POST صفاً جديداً، PATCH لتغيير is_default/sort_order، DELETE باستخدام id.
- رفض افتراضي مكرر لنفس product_type_id والجنس، مع اعتبار gender_id الفارغ مجموعة واحدة؛ لا تخفيض تلقائياً للمجموعة السابقة.
- الخصائص: POST وPATCH/DELETE باستخدام product_type_id وattribute_id.
- مجموعات الخيارات: POST وPATCH/DELETE باستخدام product_type_id وoption_set_id.
- الإزالة تحذف صف الربط فقط؛ لا تغيّر المنتجات الموجودة، ويجب إظهار ذلك في التأكيد.
- حالات كل قسم: loading، empty، first-load error، update error، processing ومنع النقر المزدوج.
- لا إحصاءات ولا لوحة تفاصيل ثانوية.

### تحذير الإلزامية

قبل جعل خاصية أو مجموعة خيارات إلزامية لنوع له منتجات منشورة، نفّذ طلب count واحداً:
products?product_type_id=eq.<id>&status=eq.published
مع Prefer: count=exact وRange: 0-0. التحذير غير مانع. لا تحسب النواقص لكل منتج. نص product_publish_guard لم يُفحص.

## الاختبارات المطلوبة

- Model: JSON، counts الفارغة والمجهولة، التحويل.
- Repository/Data: fake لـ IApiClient، الإسقاط والاستعلامات والـ body والتحويل والأخطاء وfallback 400.
- Cubit: loading/success/empty/error/debounce/latest request wins/processing/delete guards/reload after mutation.
- Widget: 360/600/900/1200 × RTL/LTR × light/dark باستخدام pumpScreenMatrix وtester.takeException().
- إنشاء مرة واحدة، عدد استدعاءات الحفظ، reload بعد mutation، read-only بلا أزرار كتابة، dirty بعد trim.
- المرحلة ب: اختبار الجنس الفارغ والافتراضي المكرر والـ PATCH/DELETE للمفاتيح المركبة وإزالة الربط دون مس المنتجات.

## حدود الدمج

cat08 ثم cat09 ثم cat10. لا استيراد من الوحدات الشقيقة. بعد دمج cat08/cat09 تُستكمل اختبارات الربط الحي في cat10. AC5 يبقى غير مؤكد حتى اختبار CAT-02.
