# تقرير feat/cat10-product-types

التاريخ: 2026-11-25  
الفرع الأساس: feat/cat07-categories-ui @ b4b9d19a4500b52fa6abc5c3d8cc2bcaebab5f5a  
HEAD عند إعداد التقرير: 87388fc44c06b23a4eceae7ff6afcf92b6c5bb6a  
الحالة: **تنفيذ جزئي — لا يصلح للدمج بعد**. لم يُفتح PR ولم يحدث دمج.

## 1. النمط المستخرج من Categories وما التزم به التنفيذ

| المجال | النمط الفعلي في Categories | ما التزم به هذا الفرع |
|---|---|---|
| الصفحة | صفحة رقيقة تفوض إلى CrudListScreen | لم تُبنَ الصفحة بعد |
| الإعداد | CrudListConfig هو موضع تركيب القائمة | لم يُبنَ config بعد |
| البيانات | IApiClient مشترك وEndpoint خاص بالميزة | نُفّذ في product_types |
| Pagination | PagedListCubit + PagedQuery + PagedResult | نُفّذ query وCubit أوليان |
| البحث/الفرز | خادمي، escaping، order ثابت مع id | بحث name/code وorder sort_order,name,id في DataSource |
| counts | count مضمّن، وfallback عند 400؛ المجهول لا يساوي صفر | نُفّذ counts للمنتجات والارتباطات الخمسة مع fallback |
| الحذف | قبل الحذف فحص الاستخدام، و23503 حارس نهائي | فحص Domain أولي وMapping لـ23503 |
| الصلاحيات | manageAccess = Permissions.masterData.manage، والقراءة مفتوحة | لم يُربط بعد بواجهة |
| النصوص | enum AppKey داخل الميزة وتسجيله في key_registry | أضيف ProductTypesKeys وProductTypeFailureKeys وسُجّلا |
| المحرر | CrudEditorDialog/showAppFormDialog وحارس dirty | غير منفذ |
| الاختبارات | Model/Repository/Cubit/Widget ومصفوفة الشاشة | اختبارات Model وEntity فقط |

### ما تغيّر في Categories بعد كتابة مواصفة الكيان وما كان ينقص المواصفة

| تصحيح C12 | الواقع بعد تنفيذ Categories | أثره على Product Types |
|---|---|---|
| قالب القائمة | CrudListScreen/CrudListConfig، لا ListPageTemplate يدوي | لم تُبنَ القائمة بعد |
| الإحصاءات | ListStatsBar/StatItem داخل statsBuilder | مطلوبة: الكل/نشط/موقوف/بلا منتجات؛ غير منفذة |
| التفاصيل | AppDetailsPanel متاح في Core | مواصفة Product Types تختار صفحة كاملة، لا لوحة |
| is_active | يُرسل عند الإنشاء، وفي PATCH فقط عند التغيير | draft/DataSource يدعمان null لتجنب PATCH غير الضروري |
| النسخ | capability افتراضي بالمحرك | duplicate=false حسب القرار |
| bulk | capability افتراضي بالمحرك | bulkSelection=false حسب القرار |
| dirty | مطلوب في كل محرر عبر showAppFormDialog | غير منفذ |
| صلاحية الأزرار | manageAccess داخل CrudListConfig | لم يُربط بعد |
| Tabs | غير موجودة في Core | أُزيلت من التصميم؛ صفحة بأقسام متتابعة |
| العناية | لا تظهر شاشة أو بطاقة غير منفذة | مؤجلة وفق D-02 |

## 2. الملفات المعدلة خارج مجلد الوحدة

| الملف | التغيير | الأسطر المضافة | الوسم |
|---|---|---:|---|
| lib/app/localization/key_registry.dart | imports + enum values للترجمة | 8 | [cat10:begin] ... [cat10:end] |
| lib/app/features/catalog/di/catalog_di.dart | import + initProductTypesDI | 6 | [cat10:begin] ... [cat10:end] |
| docs/design/specs/CAT-07_product_types.md | إضافة تصحيح قرارات ومراحل التنفيذ | 22 | لا ينطبق |
| docs/ui/product_types_plan.md | خطة التنفيذ واستعلامات القراءة المخططة | 84 | لا ينطبق |
| docs/reports/feat-cat10-product-types.md | هذا التقرير | يثبت في commit التقرير | لا ينطبق |

لم تُعدّل ملفات Categories أو Brands أو Colors. لم تُعدّل docs/backend/BACKEND_REQUESTS.md أو Core.

## 3. مفاتيح الترجمة

| Enum | عدد القيم | البادئة | الموقع |
|---|---:|---|---|
| ProductTypesKeys | 68 | catalog.productTypes | product_types/presentation/localization/product_types_keys.dart |
| ProductTypeFailureKeys | 4 | catalog.productTypes.failures | product_types/domain/failures/product_type_failure_keys.dart |

أُضيف التسجيل في key_registry ضمن كتلة cat10. لم يُشغّل key_registry_test.

## 4. المسارات والصلاحيات

- المسار المقصود للمرحلة أ: /catalog/product-types.
- المسار المقصود للمرحلة ب: /catalog/product-types/:id.
- لم تُضف RouteItem أو GoRoute أو route_registry registration بعد؛ لا يوجد مسار محجوز فعلياً في الفرع.
- لم يُتحقق من دعم RouteItem/route_registry/HomeScreen لمسار ذي معامل :id؛ لا يُسجّل المسار قبل فحص ذلك واختباراته.
- صلاحية الكتابة المقصودة: Permissions.masterData.manage عبر CrudListConfig.manageAccess.
- القراءة مفتوحة؛ لم يُضف حارس صلاحية على المسار.
- جداول الربط في DATA_MODEL تستخدم read:true وwrite: masterdata.manage.

## 5. مصادر القراءة الخاصة بالوحدة

لا توجد مصادر قراءة للمنتقيات منفذة بعد. المخطط المسجل في docs/ui/product_types_plan.md:

| الجدول | الإسقاط المقترح |
|---|---|
| size_groups | id,name,code,is_active,size_systems(name) |
| attributes | id,name,code,is_active,data_type |
| option_sets | id,name,code,is_active |
| genders | id,name,code,is_active |

كلها يجب أن تكون داخل product_types/data، مع is_active=eq.true واستبعاد المرتبط مسبقاً. لم تُنشأ هذه المصادر، ولم تُستورد وحدة شقيقة.

استعلام التحذير المخطط: products?product_type_id=eq.<id>&status=eq.published مع Prefer: count=exact وRange: 0-0. غير منفذ.

## 6. تغطية الحقول ومعايير القبول

### تغطية الحقول

| الحقل | النوع/الإلزام | النموذج | القائمة | البحث/الفرز | الاستخدام/الحذف | الحالة |
|---|---|---|---|---|---|---|
| id | bigint PK | لا | مفتاح صف | — | — | Model |
| name | varchar(150) NOT NULL | مخطط | أساسي | بحث | — | Entity/Model فقط |
| code | varchar(50) NOT NULL UNIQUE | مخطط | أساسي، LTR/monospace مخطط | بحث | قفل بعد الاستخدام/المجهول | Entity guard فقط؛ UI غير منفذ |
| description | text nullable | مخطط | ثانوي | — | — | Entity/Model فقط |
| sort_order | integer default 0 | مخطط | غير ظاهر بعد | ترتيب خادمي | — | Entity/Model/DataSource |
| is_active | boolean default true | مخطط | أساسي | فلتر حالة | لا يزيل المنتجات القائمة | Draft/DataSource/Cubit |
| updated_at | +std | لا | ثانوي مخطط | — | — | Entity/Model |
| products(count) | علاقة | لا | عدد المنتجات | — | يمنع الحذف/يقفل code | إسقاط/تحويل |
| product_type_size_groups(count) | علاقة | لا | تفاصيل لاحقاً | — | يمنع الحذف/يقفل code | إسقاط/تحويل |
| product_type_attributes(count) | علاقة | لا | تفاصيل لاحقاً | — | يمنع الحذف/يقفل code | إسقاط/تحويل |
| product_type_option_sets(count) | علاقة | لا | تفاصيل لاحقاً | — | يمنع الحذف/يقفل code | إسقاط/تحويل |
| product_type_care_instructions(count) | علاقة | لا | لا تعرض واجهة عناية | — | يمنع الحذف/يقفل code | إسقاط/تحويل فقط |

### معايير القبول

| المعيار | الحالة |
|---|---|
| CAT07-PT-AC1 | غير مؤكد — لا شاشة ولا منتقي CAT-02 |
| CAT07-PT-AC2 | منفذ جزئياً — Mapping 23505/409 موجود؛ لا اختبار Repository أو UI |
| CAT07-PT-AC3 | منفذ جزئياً — Domain guard و23503 mapping؛ لا إخفاء زر/حوار إيقاف/اختبار |
| CAT07-PT-AC4 | غير منفذ — لا ربط مجموعات المقاسات |
| CAT07-PT-AC5 | غير مؤكد — اختبار CAT-02 بعد دمج فروع المقاسات |
| CAT07-PT-AC6 | غير منفذ — لا شاشة قائمة/تفاصيل ولا اختبار read-only |

## 7. CI والتحقق

| الدفعة | commits | رقم run | النتيجة |
|---|---|---|---|
| Domain/Data أولي | e684e42 إلى 5f8b65b (عدة دفعات صغيرة) | غير متاح | لم يُتحقق منها |
| Localization/DI | e39b805 وf065fe8 | غير متاح | لم يُتحقق منها |
| تصحيح payload والاختبارات | ca7cf34 و9a2e70b و5f8b65b | غير متاح | لم يُتحقق منها |
| التوثيق | b9dc21a و87388fc والتقرير | غير متاح | لم يُتحقق منها |

بعد كل push استُعلمت حالات commit وworkflow runs. أعادت الأدوات statuses=[] وworkflow_runs=[]؛ لذلك لم أتمكن من قراءة CI أو إثبات نجاحه. لم يتوفر gh في بيئة العمل عبر الأدوات المستخدمة.

لم تُشغّل أوامر Flutter/Dart مطلقاً: flutter analyze وflutter test وdart format وflutter build. لا توجد بيئة Flutter/Dart هنا. الاختبارات المكتوبة ولم تُشغّل:
- test/features/catalog/product_types/data/models/product_type_model_test.dart
- test/features/catalog/product_types/domain/product_type_test.dart

لم تُشغّل اختبارات Repository fake IApiClient أو Cubit أو Widget أو pumpScreenMatrix أو architecture أو localization.

## 8. القرارات المفتوحة وما اختير

- تقسيم أ وب في فرع واحد: اختير لتجنب تجزئة وحدة تعتمد على نفسها.
- صفحة التفاصيل: أقسام متتابعة بلا Tabs؛ Tabs غير موجودة في Core.
- تعليمات العناية: مؤجلة بالكامل، بلا واجهة وهمية.
- الافتراضي المكرر: رفض الربط الثاني لنفس النوع والجنس، مع gender_id=null كقيمة واحدة؛ لا تخفيض تلقائي.
- bulkSelection=false وduplicate=false.
- code يُقفل عند وجود أي استخدام أو count مجهول.
- D-PT-3: تحذير غير مانع بعدد المنتجات المنشورة فقط؛ لا حساب نواقص لكل منتج.
- لم يُفحص نص product_publish_guard، لذلك لا أستنتج منه سلوكاً إضافياً.
- المسار ذو :id لم يُسجّل قبل فحص RouteItem واختبارات التوجيه.

## 9. طلبات باك إند مقترحة

لا تغييرات باك إند نُفذت، ولا migrations/RPC/Views/dependencies أُضيفت. لا تعدّل BACKEND_REQUESTS.md.

1. التحقق على PostgREST الفعلي من علاقات embedded counts الخمس في product_types، ومن احترام RLS. fallback 400 موجود، لكنه يجعل العدادات مجهولة ويمنع الحذف وتعديل code.
2. التحقق من أن FK لكل جداول الربط تمنع حذف product_types بـ 23503، وأن العلاقة لا تستخدم cascade من جهة النوع.
3. توفير فهارس على أعمدة FK product_type_id في جداول الربط إن لم تكن موجودة، بعد فحص pg_catalog.
4. مراجعة نص product_publish_guard وتوثيق شرط ERP28 عند تغيير is_required؛ لم يُفحص النص.
5. لا طلب تغيير schema قبل إثبات نقص فعلي. إذا تعذر الحصول على إحصاء «بلا منتجات» بدقة من PostgREST مع RLS، يُقترح endpoint/استعلام خلفي موثوق منفصل، لكن لم يُنفذ.

## 10. الدمج المقترح والتضارب المتوقع

**لا تدمج هذا الفرع الآن**: المرحلة أ غير مكتملة والمرحلة ب غير منفذة.

عند الاكتمال:
1. دمج cat08 أولاً.
2. دمج cat09 ثانياً.
3. دمج cat10 أخيراً.
4. مراجعة كتل [cat10:begin]/[cat10:end] في key_registry وcatalog_di، ثم إضافة المراسي المحددة في بقية الملفات المشتركة فقط.
5. عدم استيراد أي ملف من وحدات cat08/cat09؛ تبقى مصادر القراءة مملوكة لـ product_types.

التضارب المتوقع: key_registry imports والقيم، catalog_di imports/init، route_registry imports/all، app_go_router import/GoRoute، destinations child، catalog_hub import/card، واختبار app_shell. يجب إبقاء إضافات الفروع الثلاثة جميعها عند حل التعارض النصي. لم تُضف كتل cat10 بعد إلى الملفات المشتركة الخاصة بالتوجيه والمركز والشريط الجانبي.


## قيد تدقيق إضافي — اكتمال المرحلة 0

لم أستطع إثبات أن قراءة المرحلة 0 الإلزامية اكتملت بالكامل قبل أول كتابة: تمت قراءة أجزاء كبيرة من قواعد المعمارية ومواصفات CAT-07 وDATA_MODEL وعينات Categories/Brands وواجهات Core، لكن لم تُراجع كل ملفات lib/app/features/catalog/ كاملة، ولا جميع ملفات test/architecture/، ولا كل الوثائق المطلوبة سطراً بسطر. لذلك هذا انحراف إجرائي صريح، ولا يجوز اعتبار التنفيذ مطابقاً حرفياً للتعليمات أو البناء على افتراض أن كل نقاط Core والاختبارات قد دُققت. يلزم استكمال هذه القراءة ومراجعة التغييرات قبل أي مرحلة تنفيذ إضافية أو دمج.
