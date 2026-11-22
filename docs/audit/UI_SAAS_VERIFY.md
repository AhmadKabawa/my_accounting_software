# تحقق المرحلة 0: واجهات SaaS (feat/ui-saas-dashboard)

التاريخ: 2026-11-22. الفرع: `feat/ui-saas-dashboard` من `vscode` (HEAD عند البدء `35e2ac2`).
المنهج: قراءة الكود الفعلي. **لم يُشغَّل أي اختبار** في هذه البيئة (Flutter/Dart غير مثبتين ولا شبكة لتثبيتهما)؛ فالتأكيدات أدناه من قراءة الكود، والاختبار الجديد مكتوب ولم يُشغَّل.

> ملاحظة: `docs/design/UI_TASK_BRIEF.md` غير موجود في المستودع. اعتُمد البرومبت وحده مرجعاً.

## أ. استجابة الجدول وعدم اتساق المصدر: **مؤكد**
- `AppDataTable.build` يستدعي `ScreenEngine.screenTypeForWidth(constraints.maxWidth)` (`data_table.dart`).
- `AppShell` يختار الشريط الجانبي عبر `Rh.builder` (يعتمد `ScreenEngine.screenType(context)`، أي عرض النافذة).
- نتيجة: عند 1200 فما فوق يشغل الشريط الجانبي 240–272 فيرى الجدول عرضاً أقل من 1200 فيعدّه تابلت، و`_table(full:false)` يُخفي كل `secondary`. في Brands لا يبقى إلا عمود الاسم (الوصف والعدد والحالة كلها secondary).
- لمسار الموبايل: النوع من عرض الحاوية أيضاً، فنافذة 700 فيها شريط جانبي قد تُعرض بطاقات رغم أن الشيل تابلت.
- الاختبار: `test/core/presentation/widgets/app_data_table_responsive_test.dart` (360/600/900/1200/1366، مع الشريط وبدونه). لم يُشغَّل.

## ب. ListPageTemplate: **مؤكد**
- `filterBar` مطلوب (`required this.filterBar`).
- لا خانات `stats` ولا `activeFilters` ولا `viewModeSwitcher`.
- Brands تمرر الإحصائيات في `actions`، وتلف `dataTable` بعمود يحمل بانر الفشل.
- عقد الأخطاء موزع: القالب لا يرسم بانراً، و`AppDataTable` يرسمه، والشاشة ترسم بانر `refreshFailure` بنفسها.

## ج. FilterBar: **مؤكد**
- لا زر فرز، ولا عدد نتائج، ولا خانة trailing.
- تكرار «تطبيق»: في الديسكتوب مع `filterPanelBuilder` يُرسم `builder(context, apply)` ثم `AppButton(apply)` إضافي؛ وإن كانت اللوحة تحوي زرها فالتكرار حاصل. في الموبايل يُرسم زر «تطبيق» دائماً بعد اللوحة.
- زر الفرز في الموبايل موجود داخل `AppDataTable._cards` لا في شريط الأدوات.

## د. BrandStatsBar: **مؤكد**
- `Theme.of(context).colorScheme.primary` و`Colors.transparent` مباشرة داخل Feature، وحدّ يدوي بـ `DecoratedBox` حول `AppCard`. يخالف قاعدة التوكنات.

## هـ. AppSidebar والشيل: **مؤكد**
- الفروع (`children`) تظهر فقط عندما `selected && !collapsed`: لا فتح/إغلاق مستقل، ولا سهم، ولا خط ربط.
- الطي: `supportsCollapsibleSidebar` يأتي من `PlatformCapabilities` (`Platform.isWindows` فقط؛ الويب false) ويُفعَّل فقط مع `settingsManager`. على الويب (منصة v1) لا طي.
- التابلت: `AppNavigationRail` بلا توسيع ولا فروع.
- الموبايل: `AppNavigationBar` و«المزيد» = `showModalBottomSheet` بـ `ListTile` مسطحة (حد 5 وجهات، تظهر 4 + المزيد).
- الحفظ: `AppSettingsManager` يحفظ `sidebarCollapsed` فقط؛ لا حفظ لأقسام مفتوحة ولا لوضع العرض.
- `AppSidebarStyle` يقرأ `Theme.of(context).colorScheme` مباشرة ويستخدم `primaryContainer` للمحدد (لا توكن selected).

## و. MessageViewWidgets: **مؤكد**
- SnackBar: `_MessageStyle.icon` يُحسب ولا يُعرض في SnackBar (يُستعمل في Dialog فقط). لا زر إغلاق ولا إجراء. الخطأ بلون `colors.error` (لا يستعمل لون النجاح).
- الألوان ممتلئة (`background` دلالي كامل) لا هادئة.
- `loading` = Dialog حاجب `barrierDismissible:false`.
- `InlineBanner`: سليم (أيقونة، onDismiss، liveRegion). `AppBadge`: حجمان فقط، نص صريح، بلا حالة «محدد». `AppRowActions`: أزرار أيقونة مع tooltip، `AppMenu` للمزيد. `AppCard`: سطح بحدّ، يقبل `onTap`، بلا حالة محدد. لا تعديل عليها قبل قراءة أنماطها (تمت).

## ز. الفرز في Brands: **مؤكد**
- `BrandListQuery` فيه `sortAscending` فقط (لا مفتاح حقل).
- `BrandsRemoteDataSourceImpl.getBrands`: `'order': 'name.asc|desc'` ثابت.
- `BrandsTableSection` يمرر `sortKey: 'name'` وعمود `name` وحده sortable، و`onSort` يستخدم `ascending` فقط (يتجاهل `sort.key`).

## دعم الباك إند للفرز والفلترة (brands)
مصدر: `docs/backend/DATA_MODEL.md` (جدول brands) و`BrandsEndpoint`.

| الحقل | فرز من الخادم؟ | ملاحظة |
|---|---|---|
| name | نعم | مستعمل اليوم |
| slug | نعم (عمود حقيقي) | غير معروض كعمود |
| is_active (الحالة) | نعم (عمود حقيقي) | يصلح لفرز عمود الحالة |
| created_at / updated_at | نعم (`+std`) | غير معروضة |
| description | تقنياً نعم | غير مفيد، لا يُفعَّل |
| عدد المنتجات | **لا** | يأتي من تضمين `products(count)`؛ PostgREST لا يرتب بحسب تجميع مضمَّن بلا RPC/عرض (View). يحتاج تغيير الباك إند فيُسجَّل ولا يُدّعى |

الفلاتر المدعومة: البحث (name/slug) والحالة فقط. لا فلتر فئة ولا نطاق عدد منتجات (لا عمود ولا نموذج).

## توصيات تنفيذية للمراحل التالية
1. توحيد المصدر: تمرير نوع الشاشة من `ScreenEngine.screenType(context)` وإخفاء الأعمدة تدريجياً بحسب عرض الحاوية (المرحلة 2).
2. الفرز: إضافة `sortField` إلى `BrandListQuery` مع قائمة بيضاء (`name`, `is_active`) تُترجم إلى `order` في الـ datasource دون تغيير مخطط أو عقد.
3. عدد المنتجات يبقى غير قابل للفرز (قيد باك إند مفتوح).
