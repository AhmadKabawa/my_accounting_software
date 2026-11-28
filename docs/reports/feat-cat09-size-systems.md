# feat/cat09-size-systems — تقرير التنفيذ (الشاشات والتسجيل)

> الحالة: كُتب الكود **دون تشغيل** `flutter analyze` أو `flutter test` أو `build`
> (لا بيئة Flutter عند المنفِّذ). كل ما يلي «لم يُتحقق منه» حتى يمرّ CI.

## 1. ما أُضيف
- ثلاث قوائم `CrudListScreen` (أنظمة ← مجموعات ← مقاسات) مع breadcrumb وCubit قائمة لكل مستوى
  يستقبل معرّف الأب (`registerFactoryParam`).
- محرر لكل مستوى عبر `CrudEditorDialog` مع dirty دقيق (يشمل الجنس والتفعيل).
- حوار «توليد بنطاق» (من/إلى/الخطوة/بادئة) بمعاينة حيّة وحفظ بطلب POST واحد بمصفوفة.
- إحصاءات (الكل/نشط/موقوف) للمستوى الأول فقط.
- مصدر قراءة الأجناس (`GenderOptionsCubit`) فوق مصدر `genders` الخاص بالميزة.

## 2. المسارات (وفق مواصفة §23.1 في الفرع التجميعي)
| المسار | الاسم |
|---|---|
| `/catalog/size-systems` | `catalog.sizeSystems` (في registry وprotectedRoutes) |
| `/catalog/size-systems/:systemId` | `catalog.sizeSystemGroups` (GoRouter فقط) |
| `/catalog/size-systems/:systemId/groups/:groupId` | `catalog.sizeGroupSizes` (GoRouter فقط) |

المسارات ذات المعامل غير مسجّلة في `allRoutes` (كما في `ProductTypesRoutes.detailsPath`).
أسماء الأب (النظام/المجموعة) تُمرَّر عبر `state.extra` (`SizeRouteContext`) للعرض فقط؛
عند الفتح المباشر أو التحديث تُحذف الأسماء وتعمل الشاشة من المعرّف.

## 3. ربط الأجناس
جدول `genders` موجود الآن، وشاشته مبنية في `features/catalog/genders`. الربط تم على مستوى
**البيانات** (نفس الجدول `genders`، الأعمدة `id,name,is_active`) عبر مصدر قراءة تملكه الميزة،
ولم أستورد شيئاً من مجلد `genders` تطبيقاً لـ ADR-0004 وحتى لا تتشابك فروع الوحدات.
فلتر «الجنس» في المجموعات وحقل الجنس في محررها يقرآن منه. الجدول الفارغ أو فشل القراءة
لا يظهر كخطأ (الجنس اختياري).

## 4. ملفات معدَّلة خارج `size_systems/`
كل إضافة داخل كتلة `// [cat09:begin]` … `// [cat09:end]`، بلا إعادة ترتيب.

| الملف | الأسطر المضافة |
|---|---|
| `lib/app/localization/key_registry.dart` | 6 |
| `lib/app/routing/route_registry.dart` | 6 |
| `lib/app/routing/route_guards.dart` | 6 |
| `lib/app/routing/app_go_router.dart` | 54 |
| `lib/app/shell/destinations.dart` | 10 |
| `lib/app/features/catalog/presentation/pages/catalog_hub_screen.dart` | 12 |
| `lib/app/features/catalog/di/catalog_di.dart` | 6 |
| `test/core/presentation/widgets/app_sidebar/app_sidebar_children_test.dart` | 6 |

أُضيفت الوجهة بعد `Attributes` وقبل `Colors` في الشريط الجانبي، وحُدّث اختبار الشريط الجانبي
بالترتيب نفسه.

## 5. مفاتيح الترجمة
- `SizeSystemsKeys` (بادئة `sizesystems`) في `presentation/localization/` — وصف بطاقة المركز فيه.
- `SizeSystemFailureKeys` (موجود، بادئة `sizesystemfailure`) — لم يُعدَّل.
- القيمة `nameField` بدل `name` لتفادي تعارضها مع `Enum.name`.
- لا نصوص بمتغيرات سوى `{name}` (رسائل الحذف/الإيقاف).

## 6. انحرافات عن النمط وأسبابها
1. **الفرز بحقل واحد** (مع `id` ثانوي) بدل مكدّس الفرز في Colors/Genders؛ `maxSorts: 1`.
2. **«إيقاف بدلاً من الحذف»**: يظهر كرسالة داخل حوار تأكيد الحذف (وهذا ما يقدمه `CrudConfirmations`)،
   ولا حوار مستقل لأن ذلك يتطلب تعديل Core. أي عدّاد استخدام مجهول يُعامل «مستخدماً» ويُخفي الحذف.
3. **الأسماء الفعلية للأب** لا تظهر في breadcrumb (`AppBreadcrumbItem.label` مفتاح ترجمة فقط)؛
   تظهر بدلاً منها في سطر رأس الصفحة (`headerExtras`) عند توفرها.
4. **الحالات والـ use cases** مجمّعة في ملف لكل مستوى بدل ملف لكل حالة.
5. **اختبارات Widget (360/600/900/1200 × RTL/LTR × فاتح/داكن) لم تُكتب** لأن مساعد `pumpScreenMatrix`
   لم أقرأه. كُتبت اختبارات المسارات والمفاتيح والمولّد والنماذج والاستعلامات والمستودع.
   لا اختبارات لـ Cubit ولا لمصادر البيانات (واجهة `IApiClient` و`ApiException` لم أتحقق من توقيعاتها).

## 7. قرارات مفتوحة وما اخترته
| القرار | الاختيار |
|---|---|
| التنقل بمسارات متتابعة بدل TreeView | مسارات متتابعة |
| `size_ranges` | مؤجلة (D-SZ-1 ب): لا شاشة ولا جسم |
| `from/to` نطاقاً | خارج النطاق الحالي |
| سقف التوليد | 200 صف (`SizeRangeGenerator.maxRows`) |
| رمز المقاس المولَّد | `بادئة + القيمة`، والنقطة العشرية تصير `_` (36.5 → `EU36_5`) |
| ترتيب المقاسات المولَّدة | يبدأ من (أكبر `sort_order` موجود + 1) ويتبع ترتيب التوليد |
| قراءة الرموز الموجودة للتخطي | أول 1000 مقاس للمجموعة؛ القيد UNIQUE هو الحَكَم النهائي |
| توليد رمز المجموعة من رمز النظام (S-2) | غير منفَّذ |
| شارة «موقوف بسبب النظام» (S-9) | غير منفَّذة |

## 8. حقول الباك إند المفترضة (لم يُتحقق منها)
- علاقات PostgREST: `size_systems→size_groups`، `size_groups→sizes`،
  `size_groups→product_type_size_groups`، `size_groups→product_size_groups`، `sizes→product_sizes`.
  عند فشل أي منها بـ 400 يعيد المصدر الطلب بلا الأعداد (تظهر «—» ويُمنع الحذف).
- `numeric_value` يُرسل نصاً عشرياً (`"36.5"`) لا `double`.
- POST بمصفوفة: ذرّية (قيد UNIQUE يفشل الدفعة كلها) حسب سلوك PostgREST؛ لم تُجرَّب على خادم حقيقي.
- `genders` يحوي `is_active` و`name`.

## 9. معايير القبول
| المعيار | الحالة |
|---|---|
| CAT07-SZ-AC1 (ثلاثة مستويات وتنقل) | منفذ، غير مؤكد (يحتاج فحصاً يدوياً) |
| CAT07-SZ-AC2 (فرادة الرمز) | منفذ (مفتاح التكرار)، غير مؤكد |
| CAT07-SZ-AC3 (36→46 = 11) | منفذ + اختبار |
| CAT07-SZ-AC4 (نطاق معكوس يُرفض) | منفذ + اختبار |
| CAT07-SZ-AC5 (منع حذف مقاس مستخدم) | منفذ + اختبار نموذج |
| CAT07-SZ-AC6 (إيقاف بدل حذف) | منفذ، غير مؤكد |

## 9b. فحص يدوي مقترح
1. افتح «الكتالوج ← أنظمة المقاسات»؛ أضف نظاماً (EU) ثم افتح صفه.
2. أضف مجموعة بدون جنس ثم بجنس؛ جرّب الفلتر.
3. افتح المجموعة؛ أضف مقاساً يدوياً بقيمة `36.5`؛ ثم «توليد بنطاق» 36→46 خطوة 1 بادئة EU.
4. جرّب نطاقاً معكوساً (46→36) وخطوة 0 ورمزاً مكرراً (يُتخطى).
5. جرّب الحذف على نظام فيه مجموعات (يجب أن يكون مخفياً).
6. جرّب مستخدماً بلا `masterData.manage` (قراءة فقط).

## 10. خطوات الدمج
```
git checkout integration/catalog-scope-1-combined
git checkout -b feat/cat09-size-systems-screens
git apply --index cat09-size-systems-screens.patch
```
تضارب متوقع: إضافات المراسي في `app_go_router` و`destinations` و`catalog_hub_screen` إن
دخلت وحدات جديدة بعد هذا التاريخ؛ تُحل بإبقاء الجانبين.
