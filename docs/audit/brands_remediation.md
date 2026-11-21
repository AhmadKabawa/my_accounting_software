# Brands remediation — المرحلة 3

## الحالة الحالية — 2026-11-21

- الفرع: `feat/cat07-ui-remediation`
- HEAD عند تحديث التقرير: `11532aeb403ed23ef6b105bfb2f1e8084b95ec18`
- النطاق: إغلاق انحرافات المرحلة 3 فقط؛ المرحلة 4 لم تبدأ.

## سجل البنود

| البند | الحالة | الملفات/النطاق | Commit | الملاحظة |
|---|---|---|---|---|
| Brand.hasProducts مع إبقاء canDelete | مُنفَّذ | domain/entity/brand.dart | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | hasProducts يتطلب productCount معروفاً وأكبر من صفر؛ canDelete true فقط عند الصفر. |
| BrandUsageUnknownFailure ومفتاح ar/en | مُنفَّذ | domain/failures/brand_failures.dart؛ presentation/localization/brands_keys.dart | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | أضيفت الرسالة المطلوبة باللغتين. |
| مفاتيح BrandsKeys المطلوبة | مُنفَّذ | presentation/localization/brands_keys.dart | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | saved أضيف؛ statusUpdated/deleted/duplicateError/brandInUse كانت موجودة. |
| إحصائيات الماركات في DataSource | مُنفَّذ | DataSource interface/impl، Repository، UseCase | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | طلبان متوازيان select=id وlimit=1؛ totalCount من paginated response؛ فشل أحدهما يفشل الكل؛ مؤقت إلى RPC واحد. |
| BrandsListState/Cubit/Effects | مُنفَّذ | presentation/cubit/brands_list | `75fa2739f8773a31c481a5f3f38ba349072defab` | State موحد وEffect typed؛ الشاشة رُبطت به في commit الشاشة. |
| BrandFormCubit/Effects | مُنفَّذ | presentation/cubit/brand_form | `75fa2739f8773a31c481a5f3f38ba349072defab` | idle/saving، منع الحفظ المزدوج، رسائل النجاح والفشل عبر Effects. |
| الشاشة وDI والمحرر | مُنفَّذ | brands_screen.dart، brand_editor_dialog.dart، brands_di.dart | `fec17b311f76ea85292672ff55dd923108ee3b6b` و`8ddc5dd390d1d2f0c6da808e5da6e88da05abc1b` | listener واحد لتحديث الإحصاءات؛ المحرر يستمع إلى BrandFormEffect. |
| اختبارات Domain وFakes | مُنفَّذ | test/features/catalog/brands/domain/entity/brand_test.dart؛ support/fake_brands_repository.dart؛ support/fake_brands_api_client.dart | `11532aeb403ed23ef6b105bfb2f1e8084b95ec18` | اختبار hasProducts/canDelete للقيم 0 و>0 وnull؛ تحديث fakes لدعم getBrandStats. **لم تُشغَّل.** |
| اختبارات BrandsListCubit وBrandFormCubit | مُنفَّذ | test/features/catalog/brands/presentation/cubit/brands_cubit_test.dart | `f381270160da1405cdefb4d0782cf50619c434c7` | اختبارات الانتقالات والـ refresh والفشل والطلبات المتزامنة وdebounce والحذف والـ Effects والحفظ المزدوج. **لم تُشغَّل.** |
| اختبارات BrandStatsCubit وRepository والشاشة | قيد التنفيذ | test/features/catalog/brands | — | ما زالت تحتاج التحديث والكتابة؛ لا تشغيل. |
| تدقيق grep النهائي | قيد التنفيذ | lib وtest | — | بعد تحديث الاختبارات والمستهلكين. |

## ما لم يُشغَّل

- لم تُشغّل dart format أو flutter analyze أو flutter test أو أي أمر Dart/Flutter.
- لم تُشغّل الاختبارات الموجودة أو الجديدة؛ كل اختبار سيُعلَّم «لم يُشغَّل».
- لم يُنفّذ CI.

## بنود مؤجلة

| البند | الحالة | السبب |
|---|---|---|
| S-1: PostgREST wildcard escaping | مؤجل | يتطلب تحققاً من سلوك PostgREST الفعلي. |
| P2-12: تنظيف Storage بعد فشل/إلغاء حفظ الماركة | مؤجل | يحتاج تدفقاً تعويضياً متفقاً عليه لحذف الملف اليتيم. |
| RPC إحصائيات الماركات | مؤجل | التنفيذ الحالي طلبان خفيفان مؤقتاً إلى أن يتوفر RPC واحد. |
| FormSection | مؤجل | يبقى خارج النطاق حتى تتكرر الحاجة ويُعتمد تجريد مشترك. |

## قرارات ثابتة

- Effects مطلوبة عبر BaseCubit؛ لا يُبرر غيابها.
- لا Freezed ولا Bloc ولا حزم جديدة.
- سياسة slug بلا transliteration؛ تُنفّذ في المرحلة 4.
- لا تعديل على ConfirmDialog أو EffectMixin أو BaseCubit.
- لا تبدأ المرحلة 4.
