# Brands remediation — المرحلة 3

## الحالة الحالية — 2026-11-21

- الفرع: `feat/cat07-ui-remediation`
- HEAD: `75fa2739f8773a31c481a5f3f38ba349072defab`
- النطاق: إغلاق انحرافات المرحلة 3 فقط؛ المرحلة 4 لم تبدأ.
- لا يُعد هذا التقرير إثباتاً لتنسيق Dart أو نجاح التحليل أو الاختبارات.

## سجل البنود

| البند | الحالة | الملفات/النطاق | Commit | الملاحظة |
|---|---|---|---|---|
| Brand.hasProducts مع إبقاء canDelete | مُنفَّذ | domain/entity/brand.dart | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | hasProducts يتطلب productCount معروفاً وأكبر من صفر؛ canDelete true فقط عند الصفر. |
| BrandUsageUnknownFailure ومفتاح ar/en | مُنفَّذ | domain/failures/brand_failures.dart؛ presentation/localization/brands_keys.dart | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | نص الرسالة: تعذر التحقق من ارتباط المنتجات بهذه العلامة. |
| مفاتيح BrandsKeys المطلوبة | مُنفَّذ | presentation/localization/brands_keys.dart | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | أضيف saved؛ statusUpdated/deleted/duplicateError/brandInUse كانت موجودة. |
| إحصائيات الماركات في DataSource | مُنفَّذ | DataSource interface/impl، Repository، UseCase | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | طلبان متوازيان select=id وlimit=1؛ يُستخدم totalCount من paginated response. فشل أي طلب يفشل العملية. التنفيذ مؤقت إلى RPC واحد. |
| BrandsListState وBrandsListEffect وBrandsListCubit | مُنفَّذ | presentation/cubit/brands_list | `75fa2739f8773a31c481a5f3f38ba349072defab` | State موحد وEffects typed؛ يلزم استكمال توصيل المستهلكين ومراجعة التوافق. |
| BrandFormCubit وBrandFormEffect | مُنفَّذ | presentation/cubit/brand_form | `75fa2739f8773a31c481a5f3f38ba349072defab` | الحالة idle/saving ونتائج الحفظ عبر Effects؛ يلزم تحديث الحوار وDI والمستهلكين. |
| الشاشة وDI والمستهلكون | قيد التنفيذ | brands_screen.dart، brand_editor_dialog.dart، brands_di.dart | — | لم تُحدّث بعد. |
| الاختبارات | قيد التنفيذ | test/features/catalog/brands | — | لم تُحدّث بعد؛ لن تُشغّل. |
| تدقيق grep نهائي في lib وtest | قيد التنفيذ | lib وtest | — | بعد تحديث كل المستهلكين. |

## ما لم يُشغَّل

- لم تُشغّل dart format أو flutter analyze أو flutter test أو أي أمر Dart/Flutter.
- لم تُشغّل الاختبارات الموجودة أو الجديدة؛ أي اختبار يُكتب سيُعلَّم «لم يُشغَّل».
- لم يُنفّذ CI ضمن هذا التسليم.

## بنود مؤجلة

| البند | الحالة | السبب |
|---|---|---|
| S-1: PostgREST wildcard escaping | مؤجل | يتطلب تحققاً من سلوك PostgREST الفعلي قبل اعتماد معالجة نهائية. |
| P2-12: تنظيف Storage بعد فشل/إلغاء حفظ الماركة | مؤجل | يتطلب تدفقاً تعويضياً متفقاً عليه لحذف الملف اليتيم. |
| RPC إحصائيات الماركات | مؤجل | التنفيذ الحالي طلبان خفيفان مؤقتاً إلى أن يتوفر RPC واحد. |
| FormSection | مؤجل | يبقى خارج هذا النطاق حتى تتكرر الحاجة ويُعتمد تجريد مشترك. |

## قرارات ثابتة

- Effects مطلوبة عبر BaseCubit؛ لا يُبرر غيابها.
- لا Freezed ولا Bloc ولا حزم جديدة.
- سياسة slug بلا transliteration؛ تُنفّذ في المرحلة 4.
- لا تعديل على ConfirmDialog أو EffectMixin أو BaseCubit.
- لا تبدأ المرحلة 4 ضمن هذا العمل.
