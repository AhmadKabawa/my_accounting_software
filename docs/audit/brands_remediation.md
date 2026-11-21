# تدقيق معالجة ميزة Brands

- الفرع: `feat/cat07-ui-remediation`
- HEAD عند بدء التدقيق: `55e290f3b8a9a08318d4593a6a50d1f840b2e0a0`
- تاريخ التدقيق: 2026-11-20
- مرجع اصطلاح التدقيق: لم يُعثر على `docs/audit/audit-status.md` أو مجلد `docs/audit/` في HEAD؛ أُنشئ هذا الملف في الموضع المطلوب.
- مصدر التحقق: قراءة الملفات الفعلية في HEAD. أرقام الأسطر تشير إلى HEAD الابتدائي ما لم يُذكر تحديث لاحق.

## سجل النتائج

| المعرّف | الوصف | الحالة | الدليل (ملف:سطر) | الـ commit | ملاحظات |
|---|---|---|---|---|---|
| P1-1 | ازدواج حالة Saving بين Dialog وCubit | مُعالَج في المرحلة 2 | `brands/presentation/widgets/brand_editor_dialog.dart`; `brand_form_cubit.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | أزيلت حالة `_saving` المحلية؛ busy مشتق من BrandFormCubit ويُمرر إلى AppFormDialog |
| P1-2 | لا يوجد Dialog Shell عام للمحرر | مُعالَج في المرحلة 2 | `brand_editor_dialog.dart`; `app_form_dialog.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | المحرر يستخدم showAppFormDialog/AppFormDialog المشترك |
| P1-3 | منطق الإحصاءات داخل BrandStatsCubit | مُعالَج في المرحلة 2 | `domain/usecase/get_brand_stats_use_case.dart`; `presentation/cubit/brand_stats_cubit.dart`; `di/brands_di.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | أضيف GetBrandStatsUseCase لاحتواء استعلامي الإجمالي والفعّال؛ Cubit يدير دورة الحالة فقط |
| P1-4 | حذف الماركة يعتمد على `productCount != 0`؛ القيمة null تجعل الشرط true | مؤكد من الكود | `brands/presentation/cubit/brands_list_cubit.dart:132-134` | — | null يمنع الحذف احترازياً؛ يلزم قرار مجال صريح حول unknown count |
| P1-5 | تصنيف HTTP 409 عام في مساري الكتابة والحذف | مُعالَج في المرحلة 2 | `core/network/dio/api_client.dart`; `core/error/exceptions/api_exception.dart`; `brands/data/repositories/brands_repository_impl.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | يحتفظ ApiClient بـ SQLSTATE؛ 23505 للـ unique و23503 للـ foreign key. تعارض 409 بلا SQLSTATE يبقى fallback duplicate في مسار الكتابة فقط |
| P1-6 | فتح محرر الماركة دون حواجز إغلاق | مُعالَج في المرحلة 2 | `brands/presentation/pages/brands_screen.dart`; `brand_editor_dialog.dart`; `app_form_dialog.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | يستخدم المحرر الغلاف المشترك الذي يمنع الإغلاق أثناء busy ويطلب تأكيد التغييرات غير المحفوظة |
| P1-7 | ملكية BrandLogoUploadCubit داخل قسم الشعار | مُعالَج في المرحلة 2 | `brands_screen.dart`; `brand_logo_section.dart`; `brand_editor_dialog.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | أصبح Cubit ضمن نطاق المحرر، ويُحتسب رفع الشعار ضمن busy guard |
| P2-8 | رفع الشعار يبقى State-only ولا يحتاج Effect | مؤكد من الكود | `brands/presentation/cubit/brand_logo_upload_cubit.dart:9-41` | — | قرار بلا تغيير |
| P2-9 | فشل Refresh يزيل الصفوف القديمة | مُعالَج في المرحلة 2 | `brands_list_cubit.dart`; `brands_screen.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | أضيف BrandsListRefreshFailed للاحتفاظ بآخر صفحة مع InlineBanner وخيار إعادة المحاولة |
| P2-10 | FilterBar يفرّغ النص عند إزالة شارة البحث ومسح الكل؛ لا عيب مثبت فيه، والتزامن المتبقي مرتبط بـ N-4 | مؤكد من الكود | `filter_bar.dart:94-126`; `brands/presentation/widgets/brands_filter_bar.dart:26-54` | — | لا تغيير مطلوب في FilterBar قبل اختبار N-4 |
| P2-11 | لا توجد سياسة واضحة لتحديث slug أو إعادة توليده؛ التوليد الحالي تلقائي فقط عندما يكون الحقل فارغاً | مُعالَج في المرحلة 4 | `domain/utility/brand_slug_from.dart`; `presentation/dialogs/brand_editor_dialog.dart`; `presentation/sections/brand_identity_section.dart` | سجل المرحلة 4-1 أدناه | دالة نقية بلا Flutter؛ التوليد في الإنشاء فقط حتى أول تعديل يدوي؛ التعديل يبدأ محمياً؛ إعادة التوليد صريحة؛ لا transliteration. |
| P2-12 | احتمال ملفات Storage يتيمة بعد رفع مكتمل ثم إلغاء/فشل حفظ الماركة | مؤكد من الكود | `brands/data/datasources/brands_remote_data_source_impl.dart:74-88`; `brands/presentation/widgets/brand_editor_dialog.dart:64-82` | — | دين فني موثّق، لا تنفيذ في هذه المراحل |
| S-1 | `_escapeFilterValue` يهرّب backslash والاقتباس فقط؛ wildcard الرموز % و_ و* لا تُعالج هنا | مؤكد من الكود | `brands/data/datasources/brands_remote_data_source_impl.dart:112-113` | — | أولوية منخفضة؛ مؤجل حتى اختبار قاعدة البيانات الفعلية |
| N-1 | `_slugify` يحذف كل ما ليس a-z0-9، فينتج slug فارغاً للاسم العربي | مُعالَج في المرحلة 4 | `domain/utility/brand_slug_from.dart`; `brand_field_validators.dart`; `brands_keys.dart` | سجل المرحلة 4-1 أدناه | helper مستقل في Domain؛ الاسم العربي يبقى slug فارغاً مع مساعدة ar/en، والـ validator يرفضه برسالة مطلوبة. |
| N-2 | أقسام العرض تعتمد مباشرة على BrandsListCubit | مُعالَج في المرحلة 2 | `brands_table_section.dart`; `brands_filter_bar.dart`; `brands_screen.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | أزيل اعتماد Cubit من الأقسام، وأصبحت actions عبر callbacks تنسقها الشاشة |
| N-3 | تعدد مواضع تنسيق refresh الإحصاءات ورسائل الشاشة | مُعالَج جزئياً | `lib/app/features/catalog/brands/presentation/pages/brands_screen.dart:37-42`; `brand_stats_cubit.dart:24-30` | `db05c058089c6de80506b7547add43315a06b66a`; `693bd1a237bb6f2d20c18d088c7fc892227d3cc2`; `12829ce3e1e03c32bb3d02e28f7d0b9fa21b1491` | نُقل listener خارج BlocBuilder وأصبح trigger تحديث الإحصاءات عبر listener واحد؛ أزيل Flash من فشل الإحصاءات. لم يُنشأ orchestration abstraction جديد. |
| N-4 | إدراج أبناء شرطية قبل FilterBar/Expanded قد يغيّر مواضع العناصر؛ ثُبّتت المواضع بإبن placeholder دائم | غير مؤكد | `app_page_templates.dart:140-146,209-216,300-309`; `list_page_template_test.dart`; `page_template_child_identity_test.dart` | `e84312b57699df525c8f54d5cc91da991f23c74a` | أُضيفت اختبارات ListPageTemplate وFormPageTemplate وDashboardTemplate؛ لم تُشغَّل على HEAD السابق لإثبات إعادة الإنتاج. لم يُشغَّل |
| N-5 | محرر الماركة لا يحرس التغييرات غير المحفوظة | مُعالَج في المرحلة 2 | `brand_editor_dialog.dart`; `app_form_dialog.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | dirty مشتق من controllers؛ الإلغاء وEscape يمران بتأكيد التغييرات غير المحفوظة |
| N-6a | BrandEditorDialogState عامة | مُعالَج في المرحلة 2 | `brand_editor_dialog.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | الحالة أصبحت `_BrandEditorDialogState` خاصة |
| N-6b | بعض Widgets لا تستقبل super.key | مؤكد من الكود | `brands/presentation/sections/brands_table_section.dart:21-24`; `brands/presentation/widgets/brand_editor_dialog.dart:18-23` | — | يُراجع عند نقل الملفات فقط إذا لم يتطلب تغيير منطق |
| N-6c | امتداد ملف الشعار عند غياب النقطة غير صحيح | مُعالَج في المرحلة 2 | `brands_remote_data_source_impl.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | يُستنتج الامتداد من MIME type عند غياب امتداد صالح من اسم الملف |
| U-1 | توزيع الإجراءات الحالي: Edit أساسي، والحذف يظهر فقط عند productCount == 0، وتفعيل/تعطيل في Overflow | مُعالَج في المرحلة 4 | `presentation/sections/brands_table_section.dart`; `domain/entity/brand.dart`; `presentation/pages/brands_screen.dart` | سجل المرحلة 4-3 أدناه | الأساسي Edit + تفعيل/تعطيل؛ Overflow للحذف فقط عند `brand.canDelete`. `AppDataTable` يستعمل rowActionsBuilder نفسه للبطاقات؛ التفعيل مباشر، والتعطيل يمر بالتأكيد. |
| U-2 | حقل رابط الشعار اليدوي ما زال جزءاً من BrandLogoSection إلى جانب الرفع/الإزالة | مُعالَج في المرحلة 4 | `presentation/sections/brand_logo_section.dart`; `presentation/localization/brands_keys.dart`; `brand_field_validators.dart` | سجل المرحلة 4-2 أدناه | أزيل حقل الرابط والتحقق ومفاتيح logo وlogoHint والاختبارات التابعة؛ بقيت المعاينة والرفع والاستبدال والإزالة مع بانر الفشل وتعطيل الأزرار أثناء الرفع. |
| U-3 | فشل Refresh يحول الحالة إلى Failed بدلاً من إبقاء الصفوف | مُعالَج | `brands_list_state.dart`; `brands_screen.dart`; `core/presentation/widgets/app_data_table/data_table.dart` | سجل المرحلة 4-4 أدناه | عند وجود بيانات تبقى الصفوف ظاهرة، ويعرض Core LinearProgressIndicator عند refreshing؛ فشل refresh يعرض InlineBanner وإعادة المحاولة. |
| ST-1 | نقل Brands إلى catalog/brands/{data,domain,presentation,di} مع إبقاء Hub وDI/Routes الخاصة به على مستوى catalog | مُنفَّذ | `lib/app/features/catalog/brands/`; `catalog/di/catalog_di.dart`; `catalog/presentation/routing/catalog_routes.dart` | `72961a6c55501e5d131c3a5bb99e8ec2501fdbac` | نقل الملفات والاختبارات وتحديث imports وDI ومسارات Brands. |
| ST-2 | ملفات كل Cubit تجمع State وCubit في ملف واحد ولا تتبع مجلد cubit/<name> | مؤكد من الكود | `presentation/cubit/brands/presentation/cubit/brand_form_cubit.dart`; `brands/presentation/cubit/brand_stats_cubit.dart`; `brands/presentation/cubit/brands_list_cubit.dart` | — | يُسجل كاتفاق بنيوي للميزات القادمة؛ لا يُعاد تقسيم Cubits ضمن النقل الصرف |
| ST-3 | GetBrandStatsUseCase مستقل | مُنفَّذ | `domain/usecase/get_brand_stats_use_case.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 2) | Cubit أصبح مستهلكاً للـ UseCase المسجل في DI |
| DEC-1 | لا Freezed ولا Bloc؛ Cubit فقط | مؤكد من الكود | `pubspec.yaml`; `presentation/cubit/*.dart` | — | قرار بلا كود |
| DEC-2 | Effects عبر BaseCubit الموجود | مؤكد من الكود | `lib/app/core/foundation/base/base_cubit.dart` | — | قرار بلا كود |
| DEC-3 | تأجيل FormSection وFormFieldGroup حتى تتكرر الحاجة في ميزتين | مؤكد من الكود | لا تغيير مطلوب | — | قرار بلا كود |
| DEC-4 | ConfirmDialog لا يُعدّل الآن | مؤكد من الكود | `app_confirm_dialog/confirm_dialog.dart` | — | قرار بلا كود |
| FIX-1 | تحديث مرجع BrandsKeys في سجل المفاتيح ومسارات الدعم النسبية لاختبارات Brands بعد النقل | مُنفَّذ | `lib/app/localization/key_registry.dart:23`; اختبارات `brands_repository_test.dart`, `brand_logo_upload_cubit_test.dart`, `brand_stats_cubit_test.dart` | `767aff2af8baf7d2b124077a3f2cbb4f9153832b` | كشف CI مراجع قديمة؛ حُدثت للمسارات الجديدة. |
| FIX-2 | تحديث مستهلكي BrandsKeys/BrandsRoutes/BrandsScreen خارج الميزة، وتصحيح imports helpers للاختبار المنقول، وتركيز اختصارات AppFormDialog وإصلاح اختبارات spinner/state | مُنفَّذ | `catalog_hub_screen.dart`; `route_guards.dart`; `route_registry.dart`; `destinations.dart`; `brands_screen_responsive_test.dart`; `app_form_dialog.dart`; `brands_cubit_test.dart` | `499bafd9165eff1538bddc114ebed2fb831e5b9a` | استجابة مباشرة لأخطاء CI بعد النقل والمرحلة 1. |
| FIX-3 | نقل Focus إلى داخل CallbackShortcuts وإصلاح مصفوفة اختبارات Brands | مُنفَّذ | `app_form_dialog.dart`; `brands_screen_responsive_test.dart` | غير مدون SHA في النسخة التاريخية (مرحلة 1) | تأكد CI من نجاح التحليل والاختبارات، بما فيها اختبارات Catalog UI. |

## الحالة الحالية — 2026-11-21 (تحديث ما قبل المرحلة 4)

- الفرع المستهدف: `feat/cat07-ui-remediation` فقط؛ لم يُنشأ فرع جديد.
- HEAD الذي فُحصت عليه حالة GitHub قبل تحديث هذا التقرير: `ccfa47d9e8dc8748a7f3856f034e99017d274d56`. نتيجة Analyze المرسلة لا تتضمن SHA صريحاً.
- آخر HEAD للكود قبل تحديث التقرير الحالي: `dd26617b431dc9ea07425f0b79d61bbbe2934d03`.
- مقارنة الفرع مع HEAD السابق `338340b1744b1e450522e0008293bcb7a34990e1`: الفرع كان ahead بـ 15 commits وbehind بـ 0 قبل commit تحديث التقرير الحالي.
- هذا التقرير يستعيد سجل التدقيق التاريخي من commit `4b1540df2a6aa264372a354fe4e41b6f8a14b822` ويحافظ على جميع المعرفات P1-1 إلى ST-3 وDEC-1..4 وFIX-1..3. ثم يضيف نتائج المرحلة 3 وتحديثات المعالجة الحالية.
- ملاحظة توثيقية: السجل التاريخي كان يذكر بعض تغييرات المرحلة 1/2 باسم المرحلة فقط دون SHA؛ لم أختلق SHA لها، ووسمتها بأنها غير مدونة في النسخة التاريخية. أما commits المرحلة 3 والإصلاحات الحالية فأدرجت SHA الفعلية حيث توفرت.

### حالة المراحل

- المرحلة 0: مكتملة؛ نقل Brands إلى `lib/app/features/catalog/brands` وتحديث DI/Routes والاختبارات. Commit النقل الموثق: `72961a6c55501e5d131c3a5bb99e8ec2501fdbac`.
- المرحلة 1: مكتملة وفق السجل السابق؛ AppFormDialog، تثبيت مواضع أبناء القوالب، وإصلاحات الاختبارات. SHA بعض commits المرحلة 1 غير مدون في النسخة التاريخية.
- المرحلة 2 (Brands): مكتملة وفق السجل السابق:
  - AppFormDialog مستخدم في المحرر، ولا توجد حالة `_saving` محلية مكررة؛ busy مشتق من BrandFormCubit ورفع الشعار.
  - BrandLogoUploadCubit مملوك على مستوى المحرر.
  - GetBrandStatsUseCase يفصل استعلامات الإحصاءات عن Cubit.
  - BrandsListRefreshFailed يحتفظ بالصفوف السابقة مع InlineBanner وإعادة المحاولة.
  - BrandsTableSection وBrandsFilterBar callback-driven (N-2).
  - SQLSTATE وامتداد ملف الشعار عولجا كما هو موثق في سجل المرحلة 3.
- المرحلة 3: مكتملة حسب ملفات الفرع وسجلها السابق. تفاصيل commitsها أدناه.
- المرحلة 4: بدأت؛ أُنجز نقل المحرر وتأسيس سياسة slug في commit المرحلة 4-1 أدناه. بقية بنود الواجهة قيد التنفيذ.

### سجل المرحلة 3 — commits الموثقة

| النطاق | الحالة والملفات | Commit / commits |
|---|---|---|
| Brand.hasProducts وcanDelete؛ BrandUsageUnknownFailure ومفاتيح BrandsKeys | مُنفَّذ؛ `domain/entity/brand.dart` و`domain/failures/brand_failures.dart` و`presentation/localization/brands_keys.dart` | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a` |
| نقل إحصائيات Brands إلى DataSource/Repository/UseCase | مُنفَّذ؛ `getBrandStats` يستعمل طلبين متوازيين select=id وlimit=1، ويعتمد totalCount | `f0b29641a8f93f49ebbdcb145eb516d4a8c0b52a`; `891bb114bafee73b3a1d4a75c7812950f4bff14a` |
| BrandsListState/Cubit/Effects | مُنفَّذ؛ State موحد، query، debounce، requestVersion، effects | `75fa2739f8773a31c481a5f3f38ba349072defab`; `fec17b311f76ea85292672ff55dd923108ee3b6b`; `8ddc5dd390d1d2f0c6da808e5da6e88da05abc1b`; `9dd2139da45aae599d124fbff2e756e87c0f2b0b`; `b552ed03c4509773af1711237da7f9af2f845297` |
| BrandFormCubit/Effects | مُنفَّذ؛ منع الحفظ المزدوج ونجاح/فشل عبر Effects | `75fa2739f8773a31c481a5f3f38ba349072defab`; `fec17b311f76ea85292672ff55dd923108ee3b6b`; `8ddc5dd390d1d2f0c6da808e5da6e88da05abc1b` |
| الشاشة وDI والمحرر | مُنفَّذ؛ state.query، listener واحد لتحديث الإحصاءات، DI، busy من الحفظ ورفع الشعار | `fec17b311f76ea85292672ff55dd923108ee3b6b`; `8ddc5dd390d1d2f0c6da808e5da6e88da05abc1b`; `9dd2139da45aae599d124fbff2e756e87c0f2b0b`; `b552ed03c4509773af1711237da7f9af2f845297` |
| اختبارات Domain/Fakes وList/Form Cubits والإحصاءات وRepository والشاشة وLogo Upload | أُضيفت/حُدثت؛ لم يثبت تشغيلها في السجل السابق | `11532aeb403ed23ef6b105bfb2f1e8084b95ec18`; `3aacd4f80f40bcb5b729aeab397f8f4e395da848`; `f381270160da1405cdefb4d0782cf50619c434c7`; `594086c7ffe93e2014f34f8776374d29178bfb11`; `2fc6dc7bfae70e8e831235eb4697a0ae08c8f28f`; `fba66f65dac42a491c15e27a12abc98503355f30` |
| FIX-1: مرجع BrandsKeys ومسارات اختبارات النقل | مُنفَّذ | `767aff2af8baf7d2b124077a3f2cbb4f9153832b` |
| FIX-2: مستهلكو Routes/Keys وإصلاحات AppFormDialog واختبارات النقل | مُنفَّذ | `499bafd9165eff1538bddc114ebed2fb831e5b9a` |
| FIX-3: Focus وCallbackShortcuts ومصفوفة اختبارات Brands | مُنفَّذ؛ SHA غير مدون في السجل التاريخي | غير مدون في النسخة التاريخية |

### نتائج طلبات ما قبل المرحلة 4 (F1–F7)

| البند | النتيجة الحالية | الدليل في الكود/الاختبار | Commit / commits |
|---|---|---|---|
| F1 — فحص CI وإصلاح السبب الجذري | لا تتوفر نتيجة Workflow/CI قابلة للتوثيق: استعلامات الـ workflow runs والـ combined status على HEAD `ccfa47d9e8dc8748a7f3856f034e99017d274d56` أعادت نتائج فارغة، ولا يوجد Run ID أو خطوات يمكن إثباتها. بالمقابل، أرسل المستخدم نتيجة تشغيل محلي لـ `flutter analyze --no-fatal-infos`: **80 issue كلها info، دون أي error أو warning**. النتيجة لا تتضمن SHA صريحاً، لذلك لا يمكن ربطها آلياً بعملية commit محددة، لكنها جاءت بعد إصلاحات handlers وconst fixtures المسجلة أدناه. هذا يثبت نتيجة Analyze المرسلة فقط، ولا يثبت نجاح CI أو format أو tests. الـ run `44855423884` المذكور سابقاً يعود إلى HEAD أقدم `7dbc6a57e90a6043ed78f43dd9fb53c8cf3a2bb3` ولا يثبت HEAD الحالي. | مخرجات `flutter analyze --no-fatal-infos` التي أرسلها المستخدم؛ HEAD متابعة الفرع `ccfa47d9e8dc8748a7f3856f034e99017d274d56` | `990fb6204215725229b64f9de6b065c01b6208f7`; `eb0a2917d3dce4b5883317f3c56c692386547a8e`; `dd07457fcf7b5c00c764528735c4d7440e266ba2`; `ccfa47d9e8dc8748a7f3856f034e99017d274d56` |
| F2 — استعادة التقرير ودمج المرحلة 3 | هذا التحديث يعيد محتوى التقرير التاريخي ويحافظ على كل المعرفات، ويضيف سجل المرحلة 3 ونتائج F1–F7 والحالة الحالية. | هذا الملف؛ commits المرحلة 3 أعلاه | commit هذا التحديث |
| F3 — ارتفاع AppFormDialog | عُدّل وضع الحوار المكتبي فقط: `Column(mainAxisSize: min)` و`Flexible(fit: loose)`. وضع bottom sheet يبقى على `Expanded` كما كان. أضيف اختبار للمحتوى القصير وآخر للمحتوى الطويل والتمرير. **الاختبار لم يُشغّل بعد؛ لا أدعي أن السلوك ثبت تنفيذياً.** | `lib/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart:106,123-125`; `test/core/presentation/widgets/app_form_dialog_layout_test.dart:11-36` | `e5d96add7ae3d003871c64de2467554c5150232b`; `a1586258dc225056085e6f1b375a6846eb5e1730` |
| F4 — Listener وclearFilters وFailure mapping | نُقل BlocEffectListener خارج BlocBuilder. أضيف `clearFilters()` لإلغاء debounce وتحديث search/status/page في query واحد ثم load واحد، واستُخدم في onClearAll. أصبح `_delete` يعيد `failure.messageKey` مباشرة دون تحويل مكرر. أضيفت اختبارات clearFilters ومرات refresh للإحصاءات بعد إعادة البناء. **لم تُشغّل.** | `brands_screen.dart:37-42,83`; `brands_list_cubit.dart:103-115`; `brands_cubit_test.dart:135-161`; `brands_screen_responsive_test.dart:98-145` | `efb052abe999a9c7f68823b591a1c05b7d57fa80`; `db05c058089c6de80506b7547add43315a06b66a`; `5a9375212df26f7468fb68e9552c21baffbf8950`; `4cb193fe37199b442ac8524553f7036f43dfa01a`; `693bd1a237bb6f2d20c18d088c7fc892227d3cc2`; `dd26617b431dc9ea07425f0b79d61bbbe2934d03` |
| F5 — إزالة Flash من فشل الإحصاءات | أزيل اعتماد FlashMessages من BrandStatsCubit وDI. حالات Failed وRefreshFailed باقية، وRefreshFailed يحتفظ بآخر قيمة. أضيف اختبار للاحتفاظ بالقيمة عند فشل refresh. **لم يُشغّل.** | `brand_stats_cubit.dart:24-30`; `brands_di.dart:36`; `brand_stats_cubit_test.dart` | `12829ce3e1e03c32bb3d02e28f7d0b9fa21b1491`; `eae7bad261b94536c72c0f8491e9d2ac3443c31e`; `5fc22e137028980e6597b91567fe36f299bd0310`; `923356dc9f6689c0cb84b01807f74628af29f48a` |
| F6 — getPaginated / Supabase count | الكود يرسل `Prefer: count=exact`، يقرأ `Content-Range`، ويمرر العدد إلى PaginatedParser؛ لا يعتمد على عدد الصفوف المسترجعة عند وجود header. أضيف Fake adapter test يرجع صفاً واحداً وContent-Range بإجمالي 250 ويتحقق من totalCount=250. لم يُجرَ فحص اتصال Supabase حقيقي؛ يبقى فحصاً يدوياً. **الاختبار لم يُشغّل.** | `lib/app/core/network/dio/api_client.dart:156,183-184,328,433`; `test/core/network/api_client_test.dart:148-180` | `43af013f9419352186602fd6890d2d19fe694a2b` |
| F7 — نمط Auth ومفاتيح Failure | لا يوجد اعتماد من Auth Domain على Presentation keys في الملفات المفحوصة. AuthRepository يستعمل Failure من Core؛ AuthFlowCubit يمرر `failure.messageKey` مباشرة إلى Flash/Effect، ويستورد AuthKeys لرسائل النجاح في طبقة Presentation. لا تعديل مطلوب. | `auth_repository.dart:2`; `auth_flow_cubit.dart:14,55,75`; `auth_repository_impl.dart:5` | لا commit — فحص وتوثيق فقط |

### ما أُنجز مبكراً من عناصر واجهة المرحلة 4

- N-2: BrandsTableSection وBrandsFilterBar callback-driven؛ منجز سابقاً في المرحلة 2.
- P1-1/P1-2/P1-6/P1-7/N-5/N-6a: استخدام AppFormDialog وإزالة حالة `_saving` المحلية وحماية dirty/busy؛ منجز سابقاً في المرحلة 2.
- U-3: الاحتفاظ بصفوف القائمة وإظهار InlineBanner وإعادة المحاولة عند فشل refresh؛ منجز جزئياً كما هو موضح أعلاه.
- F3/F4/F5/F6: أُغلقت تعديلات ما قبل المرحلة 4 الموضحة في الجدول، مع بقاء تشغيل الاختبارات/التحليل.

### ما لم يُنفذ — لا يُعد بدءاً للمرحلة 4

- U-1: إعادة النظر في توزيع إجراءات Edit/Delete/Activate/Deactivate.
- U-2: إزالة/إعادة تصميم حقل رابط الشعار اليدوي مقابل الرفع والإزالة.
- P2-11 وN-1: سياسة slug للأسماء العربية وإعادة التوليد؛ لا transliteration ولا قرار جديد.
- مؤشر Refresh داخل AppDataTable.
- نقل محرر الماركة إلى مجلد `dialogs/` وتقديم `showBrandEditor`.
- P1-4: قرار مجال صريح لمعنى `productCount == null`؛ المنع الاحترازي للحذف باقٍ.
- P2-12: تنظيف ملفات Storage اليتيمة بعد رفع ناجح ثم فشل/إلغاء حفظ الماركة.
- S-1: اختبار PostgREST الحقيقي لتحديد escaping للـ wildcard.
- التحقق اليدوي من Content-Range على Supabase الحقيقي.
- معالجة اعتماد Domain الخاص بـ Brands على `BrandsKeys` في Presentation لم تُنفذ؛ هذا خارج فحص Auth F7 ويظل ديناً معمارياً موثقاً.

### التحقق والتشغيل

- أبلغ المستخدم أنه شغّل `dart format --set-exit-if-changed .` ورفع commit بنتيجته. لا أملك سجل الطرفية أو SHA ذلك commit ضمن المخرجات الحالية. وبعد هذا الفحص أُجريت تعديلات إضافية على `brands_screen.dart` و`brands_cubit_test.dart`؛ لذلك يجب إعادة تشغيل أمر التنسيق على HEAD الحالي.
- أرسل المستخدم أولاً نتيجة `flutter analyze --no-fatal-infos`: **96 issue** (10 errors و6 warnings و80 info). تضمنت أخطاء handlers `_edit` و`_delete` و`_status`، وأخطاء `const Right(_page(...))`، إضافة إلى imports غير مستخدمة في `brands_screen.dart`.
- أُصلحت الأخطاء العشرة على هذا الفرع: أُعيدت handlers الخاصة بالمحرر والحذف وتغيير الحالة، وأزيل `const` غير الصالح حول fixtures. استعادة handlers أعادت استخدام imports التي أشار إليها التحليل. commits الإصلاح: `990fb6204215725229b64f9de6b065c01b6208f7` و`eb0a2917d3dce4b5883317f3c56c692386547a8e`؛ وفصل تنسيقي لاحق: `dd07457fcf7b5c00c764528735c4d7440e266ba2`.
- أرسل المستخدم بعد ذلك نتيجة أحدث لـ `flutter analyze --no-fatal-infos`: **80 issue، جميعها info، دون errors أو warnings**. مخرجات الطرفية لا تتضمن SHA صريحاً؛ لذلك نسجلها كدليل تشغيل محلي أرسله المستخدم، لا كتحقق مستقل من commit بعينه. هذا يعالج بند إعادة Analyze من جهة الأخطاء والتحذيرات الظاهرة في النتيجة.
- لا تزال ملاحظات info الـ80 موجودة؛ لم يُطلب تنظيفها ضمن هذا الإصلاح، وهي ليست errors أو warnings في المخرجات المرسلة.
- قرر المستخدم تأجيل `flutter test` إلى مختص؛ جميع الاختبارات المضافة/المعدلة تبقى غير مشغّلة حتى تنفيذ ذلك.
- لا يوجد Workflow run ID موثق لهذا HEAD من مصدر الأدوات المتاح؛ لا يوجد ادعاء بأن Check formatting أو Analyze أو Run tests أو Run catalog UI widget tests نجحت.
- فحص Supabase الحقيقي لم يُجرَ.
- لم تُضف dependencies، ولم يُستخدم Freezed أو Bloc.
- لم تُعدّل `ConfirmDialog` أو `EffectMixin` أو `BaseCubit`.
- لا تبدأ المرحلة 4.


### سجل المرحلة 4 — تحديثات التنفيذ

| البند | الحالة | الدليل | Commit |
|---|---|---|---|
| P1-2/P1-6/P1-7/N-5/N-6a — نقل المحرر وتوفير Cubits عبر showBrandEditor | مُعالَج | `presentation/dialogs/brand_editor_dialog.dart`; helper يوفّر BrandFormCubit وBrandLogoUploadCubit | `2b5bbbb2d02ac6e98eabd3f887a9115abf083cb4` |
| P2-11/N-1 — slug | مُعالَج بالكود؛ الاختبارات أضيفت ولم تُشغّل بعد | `domain/utility/brand_slug_from.dart`; `brand_slug_from_test.dart` | سيُثبت SHA في التقرير النهائي |

| U-2 — إزالة إدخال URL اليدوي للشعار | مُعالَج بالكود والاختبار المعدل (غير مشغّل) | `brand_logo_section.dart`; إزالة مفاتيح URL والـ validator واختباره | سيُثبت SHA في التقرير النهائي |

| U-1 — ترتيب إجراءات الصفوف والبطاقات | مُعالَج | `BrandsTableSection` يضع Edit وActivate/Deactivate في الأساسي، وDelete في overflow بشرط `canDelete`; البطاقة تستخدم builder نفسه | سيُثبت SHA في التقرير النهائي |

| U-3/P2-9 — مؤشر Refresh | مُعالَج في Core مع اختبار Widget مضاف غير مشغّل | `AppDataTable.refreshing`; `BrandsTableSection.refreshing`; اختبار بقاء الصفوف مع المؤشر | سيُثبت SHA في التقرير النهائي |


### المرحلة 5 — اختبارات الواجهة المضافة

| مجموعة الاختبارات | ما أُضيف | الحالة |
|---|---|---|
| محرر الماركة | نجاح الحفظ وإغلاق true؛ فشل duplicate وبقاء الحوار؛ منع Escape/back أثناء الحفظ؛ slug (توليد/تعديل يدوي/إعادة توليد/عربي/تعديل)؛ إلغاء/نجاح/فشل رفع الشعار | أُضيفت، بانتظار CI |
| Responsive | مصفوفة شاشة Brands عند 360 و800 و1280، مع RTL/LTR وLight/Dark | أُضيفت، بانتظار CI |
| AppDataTable | مؤشر refreshing مع بقاء الصفوف | أُضيف في المرحلة 4، بانتظار CI |

لم تُضف بعد كل حالات القائمة المذكورة في بند 10، ولا فحص المحرر عند عروض 360/800/1280. لا تُعد هذه الاختبارات مكتملة لمجرد وجود الملف.

- F3 إعادة تحقق: CI run `44868336919` كشف أن `ListView(shrinkWrap: true)` ملأ ارتفاع الحوار المكتبي رغم `Flexible(loose)`؛ أُعيد توحيد محتوى التمرير إلى `SingleChildScrollView` داخل `Flexible(loose)` على Desktop مع إبقاء `Expanded` على Mobile. الإصلاح في commit التالي؛ يجب أن يعيد CI إثبات اختبار المحتوى القصير والطويل.

- F3 إعادة تحقق: CI run `44868576488` أثبت أن `Flexible(loose)` مع `SingleChildScrollView` ما زال يملأ ارتفاع الشاشة في اختبار المحتوى القصير. التعديل التالي يجعل Desktop `ListView(shrinkWrap: true)` على مستوى الجذر (header/content/footer ضمن scroll واحد) كي يكون ارتفاعه طبيعياً للمحتوى القصير ويظل محدوداً بحد Dialog للمحتوى الطويل؛ Mobile يبقى BottomSheet مع Expanded/SingleChildScrollView.
- CI run `44868576488`: Analyze فشل بتحذير import غير مستخدم في اختبار المحرر؛ أزيل الاستيراد في commit الإصلاح التالي.

- توسعة اختبارات المرحلة 5: أضيفت حالات فشل الحفظ العادي، بقاء errorKey عند تعديل الوصف ومسحه عند تعديل الاسم، dirty/clean close، تعطيل الحفظ أثناء اختيار الشعار، إزالة الشعار وحفظ null، وتجربة المحرر عند 360/800/1280. أضيفت في commit مستقل؛ تنتظر نتيجة CI.

- المرحلة 5 — أضيفت اختبارات تكامل لإجراءات الصف والبطاقة: `canDelete` مع productCount=0/موجب/null، وظهور Overflow فقط للسجل القابل للحذف، وتعطيل بتأكيد وتفعيل مباشر، وفشل الحذف بسبب InUse يبقي البانر داخل ConfirmDialog. أضيف دعم التسجيل في fake repository. بانتظار CI.

- F3 محاولة ثالثة: CI run `44868855253` أكد أن `ListView(shrinkWrap: true)` وحده ما زال يملأ الارتفاع المتاح. أضيف `Align(heightFactor: 1)` حول القائمة حتى يأخذ Dialog ارتفاع المحتوى القصير، بينما تبقى القائمة مقيدة بـ maxHeight وتتمكن من التمرير عند المحتوى الطويل. لا يُغلق F3 حتى ينجح الاختباران في CI.
