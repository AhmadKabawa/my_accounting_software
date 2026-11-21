# Brands remediation — المرحلة 3

## الحالة الحالية — 2026-11-21

- الفرع: `feat/cat07-ui-remediation`
- HEAD: `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a`
- النطاق: إغلاق انحرافات المرحلة 3 فقط. المرحلة 4 لم تبدأ.
- لا يُعد هذا التقرير إثباتاً لتنسيق Dart أو نجاح التحليل أو الاختبارات.

## سجل البنود

| البند | الحالة | الملفات/النطاق | Commit | الملاحظة |
|---|---|---|---|---|
| Domain: `Brand.hasProducts` مع إبقاء `canDelete` | مُنفَّذ | `domain/entity/brand.dart` | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | hasProducts يتطلب قيمة معروفة أكبر من صفر؛ canDelete يظل true فقط عند الصفر. |
| فشل معرفة ارتباط المنتجات | مُنفَّذ | `domain/failures/brand_failures.dart`, `presentation/localization/brands_keys.dart` | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | أضيف BrandUsageUnknownFailure ومفتاح ar/en. |
| مفاتيح BrandsKeys المطلوبة | قيد التنفيذ | `presentation/localization/brands_keys.dart` | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | أضيف saved؛ statusUpdated/deleted/duplicateError/brandInUse موجودة مسبقاً. |
| إحصائيات الماركات في DataSource | مُنفَّذ | DataSource interface/impl، Repository، UseCase | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | طلبان متوازيان select=id وlimit=1 مع totalCount من paginated response؛ فشل أي طلب يعيد ApiFailure. مؤقت إلى RPC واحد. |
| BrandsListState/Cubit/Effects | قيد التنفيذ | presentation/cubit/brands_list | — | لم يُحدّث بعد في هذا التسليم الجاري. |
| BrandFormCubit/Effects/Editor | قيد التنفيذ | presentation/cubit/brand_form، editor | — | لم يُحدّث بعد في هذا التسليم الجاري. |
| الشاشة وDI والمستهلكون | قيد التنفيذ | brands_screen.dart، brands_di.dart | — | لم يُحدّث بعد في هذا التسليم الجاري. |
| تحديث الاختبارات وكتابتها | قيد التنفيذ | test/features/catalog/brands | — | كتابة فقط؛ لا تشغيل. |
| التدقيق النهائي للرموز القديمة | غير مؤكد | lib وtest | — | يُحسم بعد تحديث المستهلكين والاختبارات. |

## ما لم يُشغَّل

- لم تُشغّل `dart format` أو `flutter analyze` أو `flutter test` أو أي أمر Dart/Flutter.
- لم تُشغّل أي اختبارات جديدة أو موجودة. كل اختبار يُضاف أو يُعدّل في هذه المرحلة سيُعلَّم «لم يُشغَّل».
- لم يُنفّذ CI ضمن هذا التسليم.

## بنود مؤجلة

| البند | الحالة | السبب |
|---|---|---|
| S-1: PostgREST wildcard escaping | مؤجل | يتطلب تحققاً من سلوك PostgREST الفعلي قبل اعتماد معالجة نهائية. |
| P2-12: تنظيف Storage بعد فشل/إلغاء حفظ الماركة | مؤجل | يتطلب تدفقاً تعويضياً متفقاً عليه لحذف الملف اليتيم. |
| RPC إحصائيات الماركات | مؤجل | يستخدم التنفيذ الحالي طلبين خفيفين مؤقتاً إلى أن يتوفر RPC واحد. |
| FormSection | مؤجل | يبقى خارج هذا النطاق حتى تتكرر الحاجة ويُعتمد تجريد مشترك. |

## قرارات ثابتة

- Effects مطلوبة عبر `BaseCubit`؛ لا يُبرر غيابها.
- لا Freezed ولا Bloc ولا حزم جديدة.
- سياسة slug بلا transliteration؛ تُنفّذ في المرحلة 4.
- لا تعديل على ConfirmDialog أو EffectMixin أو BaseCubit.
- لا تبدأ المرحلة 4 ضمن هذا العمل.
