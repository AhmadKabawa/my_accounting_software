# CAT-07 Fix 1 — تقرير إصلاح أعطال شاشة التصنيفات

الفرع: `feat/cat07-categories-ui`  
النطاق: إصلاحات B1–B5 فقط؛ لا ميزات جديدة.  
البيئة: لا توجد Flutter SDK محلية؛ لم يُشغّل analyze/test محلياً.

## ملخص الحالة

| البند | السبب الجذري المثبت من الكود | الإصلاح | الاختبار |
|---|---|---|---|
| B1 | `dataSection` أعاد `Column` يحتوي `Expanded(child: section)` داخل جسم الصفحة غير محدود الارتفاع | إزالة Expanded الرأسي واستخدام Column بـ mainAxisSize.min وstretch | `categories_screen_test.dart`: تبديل active/inactive/all والبحث داخل الشاشة كاملة |
| B2 | أزرار شجرة نصية كانت في `extraToolbarActions` ضمن `searchSuffix`؛ كما كان زر مسح الفلاتر مكرراً | نقل أدوات الشجرة إلى صف مستقل، وتحويلها إلى AppIconButton، وحذف extraFilterControls | قياس حقل البحث عند 360px، وفحص عدم الاستثناء، واختبار بقاء البحث مع الطي/التوسيع |
| B3 | مالك CrudEditorFields وCategoryFormCubit كان خارج Widget، والتخلص منهما في finally مرتبطاً بعودة Future الحوار لا باكتمال دورة حياة route | CategoryEditorDialog StatefulWidget يملك الحقول في initState/dispose؛ BlocProvider(create:) يملك Cubit؛ parentOptions مخزنة late final | اختبار إنشاء فرعي، حفظ مرة واحدة، وإعادة تحميل الشجرة |
| B4 | الإزاحة كانت تتضاعف مع depth بلا حد، والمسار لم يكن ممرراً لخلية الجدول، وكان النص يعرض ancestors دون اسم العقدة | حد الإزاحة بأربعة مستويات عبر AppSpacing، Directional، وتمرير showPathForDeep للجدول والبطاقة والشبكة، وإظهار المسار الكامل بعد العمق 4 أو في flat | اختبار عمق 10 بعرض 360 في RTL/LTR والتحقق من ظهور المسار وعدم وجود استثناء |
| B5 | إجراء حذف خاص مكرر في extraRowActions، بينما labels.delete معطل | حذف الإجراء الخاص وتفعيل الحذف القياسي فقط مع canDelete؛ _reproject يمسح selection قبل emit الإسقاط الجديد | اختبار مسح التحديد عند تبديل الفلتر، واختبار تدفق الحذف القياسي عبر Core |

## الملفات المتغيرة

- `lib/app/features/catalog/categories/presentation/categories_list_config.dart`
- `lib/app/features/catalog/categories/presentation/dialogs/category_editor_launcher.dart`
- `lib/app/features/catalog/categories/presentation/cubit/category_form/category_form_cubit.dart`
- `lib/app/features/catalog/categories/presentation/widgets/categories_tree_toolbar.dart`
- `lib/app/features/catalog/categories/presentation/widgets/category_identity.dart`
- `test/features/catalog/categories/presentation/categories_screen_test.dart`
- `test/features/catalog/categories/support/fake_categories_repository.dart`
- `docs/ui/categories_plan.md`

## افتراضات ثبت خطؤها أو قيودها

1. الافتراض أن أدوات الشجرة لا تؤثر في مساحة البحث كان خاطئاً: FilterBar يضع searchSuffix بجوار حقل البحث مباشرة.
2. الافتراض أن Future الخاص بـ showAppFormDialog يحدد لحظة آمنة للتخلص من الحقول والـ Cubit كان خاطئاً؛ دورة حياة عناصر الحوار يجب أن تتبع route/widget.
3. لم يكن showPathForDeep مفعلاً في خلية الجدول، رغم وجوده في البطاقة.
4. CategoryNode يطبق Equatable؛ مقارنة الأب يجب أن تعتمد على id لا على هوية instance.
5. لم أعثر على Golden/Screenshot test سابق للتصنيفات؛ لذلك لا أدعي أن اختباراً بصرياً سابقاً فشل. فشل CI السابق كان sidebar route coverage بعد تسجيل Categories، وأُصلح في `f9aeb6e` (run `45712204962`).

## سجل CI

| Run | Commit | النتيجة | التفاصيل |
|---|---|---|---|
| 45720396668 | 76d88a8 | فشل Analyze | استيراد app_button أزيل رغم أن AppIcons متاح عبره؛ أُعيد الاستيراد في إصلاح لاحق |
| 45720532414 | b996f75 | فشل Auto-format push | CI formatter أنشأ commit محلياً لكن push رُفض بسبب تحديث متزامن للفرع؛ لم يكن فشل تنسيق Dart |
| 45720642050 | b532246 | فشل Auto-format push | تعارض دفع آخر بسبب تزامن تشغيل formatter مع تحديث الفرع |
| 45720679353 | 4f102ec | قيد التحقق عند إعداد هذا التقرير | يُحدّث هذا السجل بعد انتهاء جميع بوابات CI على آخر commit |

لا يُعلن اكتمال CAT-07 قبل نجاح Auto-format وAnalyze وTests وCatalog UI Widget Tests على آخر commit. إذا فشلت أي بوابة، يُصلح السبب في commit جديد ويُسجل run جديد هنا.
