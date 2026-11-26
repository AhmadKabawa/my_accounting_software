# تقرير feat/cat10-product-types

التاريخ: 2026-11-25  
الفرع: `feat/cat10-product-types`  
الأساس: `feat/cat07-categories-ui` عند `b4b9d19a4500b52fa6abc5c3d8cc2bcaebab5f5a`  
HEAD المراجع: `db970a05d7206c2875b7d035615dfa6777dbd5c4`  
مقارنة الفرع: ahead 122 / behind 0.  
الحالة: **تنفيذ واسع لكنه غير متحقق آلياً وغير جاهز للدمج**. لا PR ولا merge.

## 1. النمط المستخرج من Categories وما التزم به

| المجال | نمط Categories | تطبيق Product Types |
|---|---|---|
| القائمة | `CrudListScreen + CrudListConfig` | ملتزم؛ صفحة رقيقة وconfig مستقل |
| حدود config | ≤250 سطراً | `product_types_list_config.dart` نحو 115 سطراً |
| البيانات | `IApiClient` + endpoint خاص | ملتزم |
| القائمة | `PagedListCubit` | ملتزم |
| الحالة | sealed + Equatable | حالات القائمة والتفاصيل والإحصاءات sealed/Equatable؛ حالة المحرر enum |
| البحث | خادمي + escaping + debounce 300ms | خادمي في DataSource؛ escaping مصحح؛ debounce من PagedListCubit |
| الفرز | خادمي مع id tie-breaker | `sort_order.asc,name.asc,id.asc` |
| embedded counts | fallback عند 400 والمجهول لا يساوي صفراً | مطبق للمنتجات وخمس علاقات |
| المحرر | CrudEditorDialog/showAppFormDialog | مطبق؛ dirty من CrudEditorFields مع تطبيع trim |
| الصلاحية | manageAccess، والقراءة مفتوحة | مطبق في config؛ التفاصيل تخفي أدوات الكتابة لغير المصرح |
| النصوص | AppKey enums داخل الميزة | ProductTypesKeys وProductTypeFailureKeys مسجلان |
| Core | لا تعديل | لم يعدل |
| تفاصيل النوع | صفحة مستقلة | صفحة كاملة بثلاثة أقسام، بلا Tabs ولا قسم عناية |

### C12 — ما تغيّر في Categories بعد كتابة المواصفة وما كان ينقصها

| التصحيح | أثره على التنفيذ |
|---|---|
| استخدام محرك CRUD بدلاً من بناء ListPageTemplate يدوياً | تم |
| الإحصاءات في statsBuilder مستقلة عن صفحة النتائج | تم؛ تُحمّل كل صفحات الأنواع، و«بلا منتجات» يصبح مجهولاً إذا تعذر count |
| لا لوحة تفاصيل ثانوية | تم؛ صفحة تفاصيل مستقلة |
| bulkSelection | false |
| duplicate | false |
| is_active عند الإنشاء | true افتراضياً ويرسل صراحة |
| is_active في PATCH | لا يرسل إن لم يتغير |
| dirty بعد trim | CrudEditorFields + extraDirty للحالة |
| صلاحية الكتابة | Permissions.masterData.manage |
| مفاتيح الخطأ | ProductTypeFailureKeys عبر ExceptionMapper/Failure.messageKey |

## 2. الملفات المعدلة خارج مجلد الوحدة

كل إضافة كود مشتركة داخل كتلة `[cat10:begin]` / `[cat10:end]` في الملفات التي تسمح بكتل الفروع.

| الملف | الأسطر المضافة | الوسم/الموضع |
|---|---:|---|
| `lib/app/localization/key_registry.dart` | 9 | كتلة cat10؛ import بعد profile_keys والقيم بعد OnboardingKeys |
| `lib/app/routing/route_registry.dart` | 2 | كتلة cat10؛ import/all بعد CategoriesRoutes |
| `lib/app/routing/app_go_router.dart` | 21 | كتلة cat10؛ import بعد categories_list_page وGoRoutes بعد Colors |
| `lib/app/shell/destinations.dart` | 6 | كتلة cat10؛ بعد Categories |
| `lib/app/features/catalog/presentation/pages/catalog_hub_screen.dart` | 8 | كتلة cat10؛ import/card بعد Categories |
| `lib/app/features/catalog/di/catalog_di.dart` | 6 | كتلة cat10؛ بعد Categories |
| `test/shell/app_shell_test.dart` | 8 | اختبار وجهة بعد Categories |
| `docs/design/specs/CAT-07_product_types.md` | 22 إضافة، 1 حذف | تصحيح المواصفة |
| `docs/ui/product_types_plan.md` | 84 | خطة الوحدة |
| `docs/reports/feat-cat10-product-types.md` | هذا التقرير | تقرير الفرع |

لم تعدل ملفات Categories أو Brands أو Colors أو أي وحدة شقيقة. لم تعدل Core أو BACKEND_REQUESTS.md.

## 3. مفاتيح الترجمة

| Enum | عدد القيم | البادئة الفعلية | المكان |
|---|---:|---|---|
| ProductTypesKeys | 74 | `producttypes` | `product_types/presentation/localization/product_types_keys.dart` |
| ProductTypeFailureKeys | 4 | `producttypefailures` | `product_types/domain/failures/product_type_failure_keys.dart` |

استُخدمت بادئات من مقطعين متوافقة مع صيغة key_registry_test في هذا الفرع، وتجنبت `@name`. وصف بطاقة المركز ومفاتيح التفاصيل في ProductTypesKeys لا CatalogHubKeys. لم يشغّل key_registry_test.

## 4. المسارات والصلاحيات

- قائمة الأنواع: `/catalog/product-types`، مسجلة في RouteRegistry وGoRouter وdestinations وCatalogHub.
- التفاصيل: `/catalog/product-types/:id` مسجلة مباشرة في GoRouter.
- `ProductTypesRoutes.all` يحتوي المسار الثابت فقط. لم أضع المسار ذي المعامل في RouteRegistry لأن HomeScreen/registeredRoutes يستخدمان قائمة الوجهات الثابتة؛ صفحة التفاصيل لا تمثل وجهة شريط جانبي.
- صلاحية الكتابة: `Permissions.masterData.manage` عبر CrudListConfig.
- القراءة مفتوحة ولا يوجد حارس صلاحية على المسار.
- التفاصيل تفحص AccessCubit وتخفي منتقيات الإضافة وأزرار الإزالة، وتعطل AppSwitch وحقول الترتيب للمستخدم read-only.

## 5. مصادر القراءة الخاصة بالوحدة

جميع المصادر داخل `product_types/data` ولا تستورد أي وحدة من cat08/cat09.

| المصدر | الإسقاط | الفلاتر/الترتيب |
|---|---|---|
| مجموعات المقاسات | `id,name,code,is_active,size_systems(name)` | `is_active=eq.true`, `order=name.asc,id.asc` |
| الخصائص | `id,name,code,is_active,data_type` | `is_active=eq.true`, `order=name.asc,id.asc` |
| مجموعات الخيارات | `id,name,code,is_active` | `is_active=eq.true`, `order=name.asc,id.asc` |
| الأجناس | `id,name,code,is_active` | `is_active=eq.true`, `order=name.asc,id.asc` |
| مجموعات المقاسات المرتبطة | `id,size_group_id,gender_id,is_default,sort_order,size_groups(id,name,code,size_systems(name)),genders(id,name)` | `product_type_id=eq.<id>`, `order=sort_order.asc,id.asc` |
| الخصائص المرتبطة | `attribute_id,is_required,sort_order,attributes(id,name,code,data_type)` | `product_type_id=eq.<id>`, `order=sort_order.asc,attribute_id.asc` |
| مجموعات الخيارات المرتبطة | `option_set_id,is_required,sort_order,option_sets(id,name,code)` | `product_type_id=eq.<id>`, `order=sort_order.asc,option_set_id.asc` |
| تحذير المنشور | `products?select=id&product_type_id=eq.<id>&status=eq.published` | طلب count واحد لكل جلسة تفاصيل عند أول تغيير إلى required |

المنتقيات تستبعد المعرفات المرتبطة بالفعل. لا تظهر منتقيات فارغة عندما لا توجد خيارات نشطة؛ تعرض حالة واضحة.

## 6. تغطية الحقول ومعايير القبول

### تغطية الحقول

| الحقل | القائمة | المحرر | التفاصيل/الحماية | الحالة |
|---|---|---|---|---|
| id | مفتاح صف | — | مسار التفاصيل | منفذ |
| name | عمود أساسي | مطلوب ≤150 | عنوان التفاصيل | منفذ |
| code | monospace/LTR | مطلوب ≤50 | يقفل عند أي استخدام/عد مجهول | منفذ |
| description | عمود ثانوي | اختياري، trim/null | — | منفذ |
| sort_order | ترتيب خادمي | عدد صحيح افتراضي 0 | حقول ترتيب قابلة للتحديث للأقسام | منفذ |
| is_active | Badge وفلتر | true افتراضياً | إيقاف لا يفك ارتباط المنتجات الحالية | منفذ |
| updated_at | عمود آخر تحديث | — | — | منفذ |
| products(count) | عدد المنتجات | — | يمنع الحذف ويقفل code؛ مجهول يعرض — | منفذ |
| size_groups(count) + بقية علاقات النوع | — | — | تمنع الحذف وتقفل code | منفذ |
| روابط المقاسات | عدد القسم | — | إضافة/تعديل افتراضي وترتيب/إزالة | منفذ |
| روابط الخصائص | عدد القسم | — | إضافة/تعديل required وترتيب/إزالة | منفذ |
| روابط الخيارات | عدد القسم | — | إضافة/تعديل required وترتيب/إزالة | منفذ |
| تعليمات العناية | لا تعرض | لا تعرض | مؤجلة D-02 | ملتزم بالتأجيل |

### معايير القبول

| المعيار | الحالة |
|---|---|
| CAT07-PT-AC1 | غير مؤكد — لم تُدمج أو تُختبر قائمة اختيار نوع المنتج في CAT-02 |
| CAT07-PT-AC2 | منفذ + اختبار مكتوب — 23505/409 يتحولان إلى ProductTypeDuplicateFailure؛ لم يشغّل الاختبار |
| CAT07-PT-AC3 | منفذ جزئياً — إخفاء الحذف عند الاستخدام/المجهول، وإيقاف الحالة؛ 23503 يتحول إلى ProductTypeInUseFailure، لكن حوار الإيقاف كبديل مباشر لم يكتمل |
| CAT07-PT-AC4 | منفذ + اختبار Cubit مكتوب — رفض الافتراضي المكرر بما فيه gender_id=null؛ لم يشغّل الاختبار |
| CAT07-PT-AC5 | غير مؤكد — اختبار الوراثة في CAT-02 بعد دمج مصادر المقاسات |
| CAT07-PT-AC6 | منفذ + Widget tests مكتوبة — اختبار قائمة وتفاصيل read-only؛ لم تشغّل |

## 7. CI والتحقق

- ملف CI في المستودع يفعّل workflow على push؛ كل commits هذه الدفعة دُفعت إلى الفرع المطلوب فقط.
- استعلام Combined Status للـ HEAD أعاد `statuses=[]`.
- أداة Workflow Runs المتاحة أعادت `workflow_runs=[]` لأنها لا تعرض تشغيلات push في الاستجابة المتاحة؛ لا يوجد رقم run أو نتيجة يمكن إثباتها. لذلك كل دفعات CI **لم يُتحقق منها**، ولا أدّعي نجاحها.
- لا يتوفر `gh` CLI أو Flutter/Dart في بيئة التنفيذ. `flutter analyze`, `flutter test`, `dart format`, `flutter build` لم تُشغّل.
- الاختبارات المكتوبة ولم تُشغّل:
  - `test/features/catalog/product_types/data/models/product_type_model_test.dart`
  - `test/features/catalog/product_types/data/product_types_remote_data_source_test.dart`
  - `test/features/catalog/product_types/domain/product_type_test.dart`
  - `test/features/catalog/product_types/presentation/cubit/product_types_list_cubit_test.dart`
  - `test/features/catalog/product_types/presentation/cubit/product_type_details_cubit_test.dart`
  - `test/features/catalog/product_types/presentation/pages/product_types_screen_test.dart`
  - `test/features/catalog/product_types/presentation/pages/product_type_details_screen_test.dart`
- أضيفت مصفوفة 360/600/900/1200 × RTL/LTR × فاتح/داكن باستخدام pumpScreenMatrix، لكنها لم تُشغّل. كما لم تُشغّل اختبارات architecture أو localization.

**قيد آلية العمل:** لا توجد نسخة git محلية/بيئة Flutter متاحة في هذه الجلسة؛ تمت كتابة الملفات كـ GitHub commits عبر واجهة المستودع. لذلك لم ينفذ `git pull --rebase` محلياً قبل كل دفعة. يجب فحص HEAD وأي commit تنسيق آلي قبل أي دفعة لاحقة.

## 8. القرارات المفتوحة وما اختير

- المرحلة أ وب في فرع واحد؛ تنفيذ أ أولاً، وبُنيت أقسام ب الآن.
- صفحة التفاصيل صفحة كاملة، أقسام متتابعة، لا Tabs.
- لا قسم عناية ولا بطاقة وهمية.
- الافتراضي المكرر يُرفض لنفس النوع والجنس، بما في ذلك null؛ لا تخفيض تلقائي.
- bulkSelection=false وduplicate=false.
- الرمز يقفل عند أي استخدام أو count مجهول.
- is_active يرسل عند الإنشاء فقط أو إذا تغيّر في PATCH.
- تحذير D-PT-3 غير مانع، والاستعلام count واحد عند أول جعل خاصية/مجموعة خيارات required.
- حالات تحميل/فشل الأقسام حالياً مجمعة في تحميل/فشل صفحة التفاصيل؛ فشل التحديث يظهر كرسالة مشتركة. لا تزال هذه أقل تفصيلاً من الحالة المطلوبة لكل قسم مستقلاً.
- لم يُفحص نص product_publish_guard، لذلك لا أستنتج منه تفاصيل ERP28.
- لم يُختبر PostgREST live، ولا سلوك العلاقات المضمنة أو RLS فعلياً.
- عدد commits مرتفع (118 أمام المرجع) بسبب استخدام واجهة GitHub لإنشاء commits صغيرة لكل ملف؛ لم أقم بعمل squash.

## 9. طلبات باك إند مقترحة

لم تنفذ migrations أو RPC أو Views أو dependencies. لا تعدل BACKEND_REQUESTS.md.

1. تحقق على PostgREST الفعلي من علاقات embedded counts الخمس في product_types مع RLS.
2. تحقق أن FK لجداول الروابط تمنع حذف product_types بـ 23503 ولا تستخدم cascade من جهة النوع.
3. تحقق من فهارس FK على product_type_id في جداول الروابط.
4. راجع نص product_publish_guard وشروط ERP28 عند تغيير is_required؛ لم يُفحص.
5. لا تطلب تعديل schema قبل إثبات نقص فعلي. إن تعذر إحصاء «بلا منتجات» بدقة عبر PostgREST/RLS، اقترح استعلاماً موثوقاً منفصلاً ولا تنفذه في هذا الفرع.

## 10. الدمج المقترح والتضارب المتوقع

**لا تدمج الفرع الآن.** لا PR ولا merge نُفذ.

بعد استكمال CI والمراجعة:
1. دمج cat08.
2. دمج cat09.
3. دمج cat10 أخيراً.
4. التحقق من كتل cat10 في key_registry وroute_registry وapp_go_router وdestinations وcatalog_hub_screen وcatalog_di واختبار الشريط الجانبي.
5. لا تستورد ملفات من cat08/cat09؛ تبقى مصادر القراءة داخل product_types.

التضارب النصي المتوقع في الملفات المشتركة هو نفسه مراسي الجدول في الطلب. عند حل التعارض احتفظ بكتل الفروع الثلاثة، ولا تعِد ترتيبها أو تنسيقها.
