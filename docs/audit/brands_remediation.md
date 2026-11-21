# Brands remediation — المرحلة 3

## الحالة الحالية — 2026-11-21

- الفرع: `feat/cat07-ui-remediation`
- HEAD الفعلي للكود قبل commit التقرير: `b552ed03c4509773af1711237da7f9af2f845297`
- نطاق هذا التسليم: إغلاق انحرافات المرحلة 3 فقط.
- المرحلة 4: لم تبدأ.

## سجل موحّد للبنود

| البند | الحالة | الملفات والنطاق | Commit / commits | التفاصيل والقيود |
|---|---|---|---|---|
| Brand.hasProducts وcanDelete | مُنفَّذ | `lib/app/features/catalog/brands/domain/entity/brand.dart` | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | hasProducts = productCount معروف وأكبر من صفر؛ canDelete بقي true فقط عندما productCount == 0. |
| BrandUsageUnknownFailure ومفاتيح BrandsKeys المطلوبة | مُنفَّذ | `domain/failures/brand_failures.dart`؛ `presentation/localization/brands_keys.dart` | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | أضيف saved وbrandUsageUnknown بالعربية والإنجليزية؛ statusUpdated وdeleted وduplicateError وbrandInUse كانت موجودة. |
| نقل إحصائيات Brands إلى DataSource | مُنفَّذ | DataSource interface/impl؛ Repository؛ UseCase | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a`؛ `891bb114bafee73b3a1d4a75c7812950f4bff14a` | getBrandStats ينفذ طلبين متوازيين select=id وlimit=1: الإجمالي والفعّال. يستخدم totalCount من getPaginated، ويعيد فشلاً إذا فشل أي طلب. inactive = total - active. موثق كحل مؤقت إلى RPC واحد. |
| BrandsListState/Cubit/Effects | مُنفَّذ | `presentation/cubit/brands_list/` | `75fa2739f8773a31c481a5f3f38ba349072defab`؛ `fec17b311f76ea85292672ff55dd923108ee3b6b`؛ `8ddc5dd390d1d2f0c6da808e5da6e88da05abc1b`؛ `9dd2139da45aae599d124fbff2e756e87c0f2b0b`؛ `b552ed03c4509773af1711237da7f9af2f845297` | State موحد Equatable؛ query غير nullable من AppConfig؛ حالات initial/loading/ready/refreshing/failed؛ clearFailure؛ debounce 300ms؛ requestVersion؛ Effects للإنشاء/التعديل/تغيير الحالة/الحذف؛ activate/deactivate/delete/onBrandSaved. حُذفت حالات القائمة القديمة وgetter query وsetActive. |
| BrandFormCubit/Effects | مُنفَّذ | `presentation/cubit/brand_form/` | `75fa2739f8773a31c481a5f3f38ba349072defab`؛ `fec17b311f76ea85292672ff55dd923108ee3b6b`؛ `8ddc5dd390d1d2f0c6da808e5da6e88da05abc1b` | BrandFormStatus داخل ملف Cubit؛ BrandFormEffect مستقل؛ منع الحفظ المزدوج بصمت؛ duplicateError داخل Cubit؛ نجاح/فشل عبر Effects؛ حُذف brand_form_state.dart وreset. |
| الشاشة وDI والمحرر | مُنفَّذ | `brands_screen.dart`؛ `brand_editor_dialog.dart`؛ `brands_di.dart` | `fec17b311f76ea85292672ff55dd923108ee3b6b`؛ `8ddc5dd390d1d2f0c6da808e5da6e88da05abc1b`؛ `9dd2139da45aae599d124fbff2e756e87c0f2b0b`؛ `b552ed03c4509773af1711237da7f9af2f845297` | استهلاك state.query وhasData/isRefreshing؛ listener واحد لـ BrandsMutatedEffect لتحديث الإحصاءات؛ onBrandSaved بعد إغلاق المحرر؛ DI يمرر FlashMessages إلى Cubits. المحرر يستمع إلى BrandFormEffect ويحسب busy من الحفظ ورفع الشعار. |
| اختبارات Domain وFakes | مُنفَّذ | `brand_test.dart`؛ `fake_brands_repository.dart`؛ `fake_brands_api_client.dart` | `11532aeb403ed23ef6b105bfb2f1e8084b95ec18`؛ `3aacd4f80f40bcb5b729aeab397f8f4e395da848` | تغطية hasProducts/canDelete للقيم 0 و>0 وnull؛ تحديث FakeBrandsRepository لـ getBrandStats ونتيجة تغيير الحالة. **لم تُشغَّل.** |
| اختبارات BrandsListCubit وBrandFormCubit | مُنفَّذ | `brands_cubit_test.dart` | `f381270160da1405cdefb4d0782cf50619c434c7`؛ `594086c7ffe93e2014f34f8776374d29178bfb11` | انتقال loading→ready؛ refresh يحتفظ بالصفوف؛ الفشل مع/بدون بيانات؛ آخر طلب يفوز؛ fakeAsync debounce 300ms؛ منع حذف >0/null دون شبكة؛ Effects وFlashMessages؛ page fallback؛ close؛ نجاح/فشل/duplicate/save مزدوج. **لم تُشغَّل.** |
| اختبارات الإحصائيات وRepository والشاشة | مُنفَّذ | `brand_stats_cubit_test.dart`؛ `brands_repository_test.dart`؛ `brands_screen_responsive_test.dart` | `2fc6dc7bfae70e8e831235eb4697a0ae08c8f28f` | إحصائيات repository، فشل أحد الطلبين، حساب inactive، تحديث حقن FlashMessages في اختبار الشاشة. **لم تُشغَّل.** |
| اختبار Logo Upload | مُنفَّذ | `brand_logo_upload_cubit_test.dart` | `fba66f65dac42a491c15e27a12abc98503355f30` | أضيف اختبار busy أثناء فتح المنتقي والإلغاء والعودة إلى idle. **لم يُشغَّل.** |
| تدقيق الرموز القديمة في ملفات Brands المتأثرة ضمن lib وtest | مؤكد من الكود | جميع ملفات Dart تحت `lib/app/features/catalog/brands` و`test/features/catalog/brands` | `b552ed03c4509773af1711237da7f9af2f845297` | لم تظهر BrandsListReady/Loading/Failed/RefreshFailed أو BrandFormSaved/BrandFormState أو setActive أو getStats أو brand_form_state.dart؛ لا استعمال لـ cubit.query. state.query هو المصدر. |
| ما بقي مؤقتاً في الشاشة | مؤكد من الكود | `brands_screen.dart` | `9dd2139da45aae599d124fbff2e756e87c0f2b0b`؛ `b552ed03c4509773af1711237da7f9af2f845297` | أبقينا ConfirmDialog وBrandsTableSection وBrandsFilterBar والفرز/التصفية/الترقيم الحاليين؛ التغيير محدود إلى مصدر الحالة وربط Effects وتحديث الإحصاءات من موضع واحد. |
| ما بقي مؤقتاً في المحرر | مؤكد من الكود | `brand_editor_dialog.dart` | `8ddc5dd390d1d2f0c6da808e5da6e88da05abc1b`؛ `9dd2139da45aae599d124fbff2e756e87c0f2b0b` | أبقينا AppFormDialog والأقسام الحالية وحقل رابط الشعار اليدوي إلى جانب الرفع. slug auto-fill الحالي لاتيني فقط ولا يضيف transliteration؛ لم يُعَد بناء المحرر في هذه المرحلة. |
| تعارض طبقات Domain/Presentation | غير مؤكد | `domain/failures/brand_failures.dart` | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` | BrandUsageUnknownFailure يشير إلى BrandsKeys الموجودة في presentation لتلبية طلب المفتاح المحدد؛ هذا يخلق اعتماداً من Domain على Presentation. لم يُغيّر لأن المطلوب سمّى BrandsKeys صراحةً. |
| تحقق سلوك count في Supabase الفعلي | غير مؤكد | `BrandsRemoteDataSourceImpl.getBrandStats` | `891bb114bafee73b3a1d4a75c7812950f4bff14a` | الكود يستخدم getPaginated الحالي كما طُلب؛ لم يُشغّل اختبار اتصال فعلي للتحقق من Content-Range في البيئة. |

## ما لم يُشغَّل

- لم يُشغَّل `dart format --set-exit-if-changed .`.
- لم يُشغَّل `flutter analyze --no-fatal-infos`.
- لم يُشغَّل `flutter test` أو أي أمر Dart/Flutter آخر.
- لم تُشغَّل أي من الاختبارات في:
  - `test/features/catalog/brands/domain/entity/brand_test.dart`
  - `test/features/catalog/brands/presentation/cubit/brands_cubit_test.dart`
  - `test/features/catalog/brands/presentation/cubit/brand_stats_cubit_test.dart`
  - `test/features/catalog/brands/presentation/cubit/brand_logo_upload_cubit_test.dart`
  - `test/features/catalog/brands/data/repositories/brands_repository_test.dart`
  - `test/features/catalog/brands/presentation/pages/brands_screen_responsive_test.dart`
- لم يُنفّذ CI؛ لا يوجد ادعاء بنجاح التنسيق أو التحليل أو الاختبارات.

## بنود مؤجلة

| البند | الحالة | السبب |
|---|---|---|
| S-1: PostgREST wildcard escaping | مؤجل | يتطلب تحققاً من سلوك PostgREST الفعلي قبل تعديل استراتيجية escaping. |
| P2-12: تنظيف ملفات Storage اليتيمة | مؤجل | يحتاج تدفقاً تعويضياً متفقاً عليه عند نجاح الرفع ثم فشل/إلغاء حفظ الماركة. |
| RPC إحصائيات الماركات | مؤجل | الطلبان الخفيفان الحاليان حل مؤقت؛ يستبدلان بـ RPC واحد عند توفره. |
| FormSection | مؤجل | لا يُنشأ تجريد مشترك قبل تكرر الحاجة واعتماده. |

## القرارات الثابتة

- Effects عبر BaseCubit مطلوبة؛ لا يُبرر غيابها.
- لا Freezed ولا Bloc ولا حزم جديدة.
- سياسة slug بلا transliteration؛ تنفيذها في المرحلة 4، وليست بنداً مؤجلاً في هذه المرحلة.
- لا تعديل على ConfirmDialog أو EffectMixin أو BaseCubit.
- لا تبدأ المرحلة 4.
