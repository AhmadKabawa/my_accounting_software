# CAT-07 Fix 1 — تقرير إصلاح أعطال شاشة التصنيفات

الفرع: `feat/cat07-categories-ui`  
النطاق: إصلاحات B1–B5 فقط، مع إصلاح Core محدود وموافق للخلفية في `AppMenu` بعد إثبات تجاوز أفقي في قائمة إجراءات الصف.  
البيئة: لا توجد Flutter SDK محلية؛ لم يُشغّل analyze/test محلياً.

## ملخص الحالة

| البند | السبب الجذري المثبت | الإصلاح | الاختبار |
|---|---|---|---|
| B1 | `dataSection` أعاد `Column` يحتوي `Expanded(child: section)` داخل جسم `ListPageTemplate` غير محدود الارتفاع | إزالة Expanded الرأسي؛ `Column(mainAxisSize: min, crossAxisAlignment: stretch)` ووضع `CategoriesFlatResultsNote` قبل النتائج | صفحة كاملة: active ثم inactive ثم all، ثم كتابة البحث؛ الصفوف تتغير ولا يظهر استثناء |
| B2 | أدوات الشجرة النصية كانت في `extraToolbarActions` داخل `FilterBar.searchSuffix`، ومسح الفلاتر مكرر؛ كما كانت تسميات عناصر AppMenu غير مرنة في popup ضيق | نقل أدوات الشجرة إلى صف مستقل كأيقونات ذات tooltips، حذف `extraFilterControls`، حد أدنى لحقل البحث 180px؛ جعل تسمية AppMenu مرنة بسطر واحد وellipsis | قياس حقل البحث عند 360px، الطي/التوسيع دون مسح البحث، واختبار قائمة إجراءات الجدول عند 1200px |
| B3 | `showCategoryEditor` كان يملك الحقول والـ Cubit خارج Widget ويتخلص منهما في `finally` عند عودة Future، قبل ضمان انتهاء انتقال route | `CategoryEditorDialog` StatefulWidget يملك `CrudEditorFields` في initState/dispose؛ `BlocProvider(create:)` يملك Cubit؛ `parentOptions` مخزنة `late final`، والاختيار يقارن بالـ id | إضافة جذر، وإضافة فرع لعقدة مطوية، وإضافة فرع لعقدة ورقة؛ حفظ مرة واحدة وإعادة تحميل الشجرة ثم pumpAndSettle بلا استثناء |
| B4 | الإزاحة غير محدودة، ومسار الجدول غير ممرر، وخلية ضيقة قد تضيق مساحة الاسم والشارة | الإزاحة `min(depth,4) × AppSpacing.lg` عبر `EdgeInsetsDirectional`؛ المسار الكامل عند depth>4 أو flat؛ تمرير السلوك للجدول والبطاقة والشبكة؛ نقل شارة الأبناء إلى السطر الثانوي عندما تكون خلية الجدول ضيقة | عمق 10 عند 360px في RTL/LTR مع ظهور المسار وعدم overflow؛ فحص 360 و1200 على الصفحة الكاملة |
| B5 | إجراء حذف خاص مكرر في `extraRowActions` بدلاً من مسار CRUD القياسي | حذف الحذف اليدوي، تفعيل `labels.delete` القياسي، وإبقاء `CrudFlowsConfig.canDelete` حاجباً للحذف عند وجود أبناء/منتجات؛ التحقق من مسح selection قبل emit الإسقاط | تحديد جماعي ثم تغيير الفلتر بلا تحديد معلق؛ قائمة إجراءات الصف المكتبية لا تتجاوز عرض popup |

## الملفات المتغيرة

- `lib/app/features/catalog/categories/presentation/categories_list_config.dart`
- `lib/app/features/catalog/categories/presentation/dialogs/category_editor_launcher.dart`
- `lib/app/features/catalog/categories/presentation/dialogs/category_editor_fields.dart`
- `lib/app/features/catalog/categories/presentation/cubit/category_form/category_form_cubit.dart`
- `lib/app/features/catalog/categories/presentation/widgets/categories_tree_toolbar.dart`
- `lib/app/features/catalog/categories/presentation/widgets/category_identity.dart`
- `lib/app/core/presentation/widgets/app_menu/app_menu.dart`
- `test/features/catalog/categories/presentation/categories_screen_test.dart`
- `test/features/catalog/categories/support/fake_categories_repository.dart`
- `docs/architecture/CORE_MAP.md`
- `docs/architecture/CORE_USAGE.md`
- `docs/ui/categories_plan.md`

## افتراضات ثبت خطؤها أو تفاصيل تحققت

1. `CategoryNode` يطبق `Equatable`، و`props` تشمل category وdepth وancestors وchildCount وactiveChildCount وexpanded وflat؛ لذلك افتراض غياب equality غير صحيح. رغم ذلك، اختيار الأب صار يعتمد صراحةً على `id`، و`SearchableDropdown` يقارن `value == option`.
2. `CategoryTree.defaultExpandedIds` يفتح الجذور ذات الأبناء فقط، وليس كل مستويات الشجرة؛ لذلك اختبار العقدة الورقية يوسّع الشجرة صراحةً قبل اختيار الصف الثالث.
3. `AppDataView` يعرض cards افتراضياً على الهاتف، ويستخدم تمثيلات الجدول بحسب عرض الحاوية؛ لا يصح افتراض أن اختبار 1200px يختبر مسار بطاقات الهاتف.
4. جسم `ListPageTemplate` غير محدود الارتفاع؛ `AppDataView` لا يستخدم المرونة الرأسية إلا عندما تكون قيود الارتفاع محدودة. لم نضف Expanded/Flexible رأسياً داخل CAT-07.
5. `FilterBar.searchSuffix` ملاصق لحقل البحث، لذا أدوات نصية إضافية تقلص عرض الإدخال مباشرةً. حُدد حد أدنى 180px واختُبر عند 360px.
6. `CrudEditorDialog` لديه بناء تفاعلي داخلي، لكن `CategoryEditorDialog` يحتاج أيضاً BlocBuilder خارجياً حتى يعيد حساب خصائص المحرر مثل extraDirty مع كل حالة Cubit.
7. الاختبار الأول لمسار الفرعي افترض أن الصف الثالث مرئي على الهاتف؛ ثبت أنه خارج إطار 360px، وأصبح الاختبار يستدعي `ensureVisible` قبل الضغط.
8. القائمة المكتبية كانت تكشف تجاوزاً أفقياً في AppMenu عند فتح إجراءات صف leaf التي تتضمن الحذف؛ لم يكن ذلك من CategoryIdentity، وعولج في Core بجعل نص عنصر popup مرناً.

## سجل CI

| Run | النتيجة | ما كشفه / الإجراء |
|---|---|---|
| `45720396668` | فشل Analyze | استيراد AppIcons لم يكن صريحاً بعد إزالة import سابق؛ أُصلح باستيراد AppIcon مباشرةً |
| `45720532414`, `45720642050` | فشل Auto-format push | رفض GitHub دفع formatter لأن الفرع تقدم بالتزامن؛ لم يكن فشل Dart format |
| `45721056491` | فشل Auto-format | كان اختبار leaf مؤقتاً خارج main suite؛ نُقل إلى موضعه الصحيح |
| `45721096004`, `45721287074` | فشل Tests | harness بلا Localizations، تجاوز حد حجم ملف المحرر، واختبار leaf لم يوسّع الشجرة؛ استُخدم buildTestApp وفُصلت حقول المحرر وأضيف expandAll |
| `45721903973`, `45722172987` | فشل Analyze | ملف الحقول المنفصل احتاج import لـ CategoryFormState وkey للـ Widget؛ أُضيفا |
| `45722364416` | فشل Tests | matcher افترض ظهور المسار مرة واحدة، وظهر overflow أفقي في خلية ضيقة؛ صُحح matcher وتكيفت CategoryIdentity مع عرض الخلية |
| `45723055081` | فشل Tests | فتح قائمة إجراءات الجدول كشف overflow في popup؛ أُصلح AppMenu واختُبر عند 1200px |
| `45723600510`, `45724151388` | فشل Tests | صف leaf كان خارج إطار الهاتف؛ أضيف ensureVisible قبل الضغط |
| `45724649855` | نجاح كامل | Auto-format وAnalyze وTests وCatalog UI Widget Tests خضراء بعد إصلاحات CAT-07 |
| `45725451431` | **نجاح كامل** | Auto-format وAnalyze وTests وCatalog UI Widget Tests خضراء بعد إصلاح AppMenu وتحديث CORE_MAP/CORE_USAGE؛ التحليل والاختبارات تمت على النسخة المنسقة |

## حدود التحقق

- لم يُشغّل Flutter analyze/test محلياً، التزاماً بعدم وجود Flutter SDK محلية.
- آخر تشغيل كود مكتمل `45725451431` اجتاز جميع البوابات.
- لم يُختبر REST على Supabase حي، ولم تُجر تجربة manage/read-only حية.
- اختبارات Widget تغطي 360 و1200 وRTL/LTR، لكنها لا تستبدل مراجعة Chrome اليدوية.
