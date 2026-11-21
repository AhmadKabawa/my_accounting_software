# تدقيق معالجة ميزة Brands

- الفرع: `feat/cat07-ui-remediation`
- HEAD عند بدء التدقيق: `55e290f3b8a9a08318d4593a6a50d1f840b2e0a0`
- تاريخ التدقيق: 2026-11-20
- مرجع اصطلاح التدقيق: لم يُعثر على `docs/audit/audit-status.md` أو مجلد `docs/audit/` في HEAD؛ أُنشئ هذا الملف في الموضع المطلوب.
- مصدر التحقق: قراءة الملفات الفعلية في HEAD. أرقام الأسطر تشير إلى HEAD الابتدائي ما لم يُذكر تحديث لاحق.

## سجل النتائج

| المعرّف | الوصف | الحالة | الدليل (ملف:سطر) | الـ commit | ملاحظات |
|---|---|---|---|---|---|
| P1-1 | ازدواج حالة Saving بين Dialog وCubit | مُعالَج في المرحلة 2 | `brands/presentation/widgets/brand_editor_dialog.dart`; `brand_form_cubit.dart` | phase 2 | أزيلت حالة `_saving` المحلية؛ busy مشتق من BrandFormCubit ويُمرر إلى AppFormDialog |
| P1-2 | لا يوجد Dialog Shell عام للمحرر | مُعالَج في المرحلة 2 | `brand_editor_dialog.dart`; `app_form_dialog.dart` | phase 2 | المحرر يستخدم showAppFormDialog/AppFormDialog المشترك |
| P1-3 | منطق الإحصاءات داخل BrandStatsCubit | مُعالَج في المرحلة 2 | `domain/usecase/get_brand_stats_use_case.dart`; `presentation/cubit/brand_stats_cubit.dart`; `di/brands_di.dart` | phase 2 | أضيف GetBrandStatsUseCase لاحتواء استعلامي الإجمالي والفعّال؛ Cubit يدير دورة الحالة فقط |
| P1-4 | حذف الماركة يعتمد على `productCount != 0`؛ القيمة null تجعل الشرط true | مؤكد من الكود | `brands/presentation/cubit/brands_list_cubit.dart:132-134` | — | null يمنع الحذف احترازياً؛ يلزم قرار مجال صريح حول unknown count |
| P1-5 | تصنيف HTTP 409 عام في مساري الكتابة والحذف | مُعالَج في المرحلة 2 | `core/network/dio/api_client.dart`; `core/error/exceptions/api_exception.dart`; `brands/data/repositories/brands_repository_impl.dart` | phase 2 | يحتفظ ApiClient بـ SQLSTATE؛ 23505 للـ unique و23503 للـ foreign key. تعارض 409 بلا SQLSTATE يبقى لا يُصنّف 409 بلا SQLSTATE على أنه duplicate |
| P1-6 | فتح محرر الماركة دون حواجز إغلاق | مُعالَج في المرحلة 2 | `brands/presentation/pages/brands_screen.dart`; `brand_editor_dialog.dart`; `app_form_dialog.dart` | phase 2 | يستخدم المحرر الغلاف المشترك الذي يمنع الإغلاق أثناء busy ويطلب تأكيد التغييرات غير المحفوظة |
| P1-7 | ملكية BrandLogoUploadCubit داخل قسم الشعار | مُعالَج في المرحلة 2 | `brands_screen.dart`; `brand_logo_section.dart`; `brand_editor_dialog.dart` | phase 2 | أصبح Cubit ضمن نطاق المحرر، ويُحتسب رفع الشعار ضمن busy guard |
| P2-8 | رفع الشعار يبقى State-only ولا يحتاج Effect | مؤكد من الكود | `brands/presentation/cubit/brand_logo_upload_cubit.dart:9-41` | — | قرار بلا تغيير |
| P2-9 | فشل Refresh يزيل الصفوف القديمة | مُعالَج في المرحلة 2 | `brands_list_cubit.dart`; `brands_screen.dart` | phase 2 | أضيف BrandsListRefreshFailed للاحتفاظ بآخر صفحة مع InlineBanner وخيار إعادة المحاولة |
| P2-10 | FilterBar يفرّغ النص عند إزالة شارة البحث ومسح الكل؛ لا عيب مثبت فيه، والتزامن المتبقي مرتبط بـ N-4 | مؤكد من الكود | `filter_bar.dart:94-126`; `brands/presentation/widgets/brands_filter_bar.dart:26-54` | — | لا تغيير مطلوب في FilterBar قبل اختبار N-4 |
| P2-11 | لا توجد سياسة واضحة لتحديث slug أو إعادة توليده؛ التوليد الحالي تلقائي فقط عندما يكون الحقل فارغاً | مؤكد من الكود | `brands/presentation/widgets/brand_editor_dialog.dart:50-54,116-120` | — | قرار مجال مؤجل |
| P2-12 | احتمال ملفات Storage يتيمة بعد رفع مكتمل ثم إلغاء/فشل حفظ الماركة | مؤكد من الكود | `brands/data/datasources/brands_remote_data_source_impl.dart:74-88`; `brands/presentation/widgets/brand_editor_dialog.dart:64-82` | — | دين فني موثّق، لا تنفيذ في هذه المراحل |
| S-1 | `_escapeFilterValue` يهرّب backslash والاقتباس فقط؛ wildcard الرموز % و_ و* لا تُعالج هنا | مؤكد من الكود | `brands/data/datasources/brands_remote_data_source_impl.dart:112-113` | — | أولوية منخفضة؛ مؤجل حتى اختبار قاعدة البيانات الفعلية |
| N-1 | `_slugify` يحذف كل ما ليس a-z0-9، فينتج slug فارغاً للاسم العربي | مؤكد من الكود | `brands/presentation/widgets/brand_editor_dialog.dart:50-54` | — | — |
| N-2 | أقسام العرض تعتمد مباشرة على BrandsListCubit | مُعالَج في المرحلة 2 | `brands_table_section.dart`; `brands_filter_bar.dart`; `brands_screen.dart` | phase 2 | أزيل اعتماد Cubit من الأقسام، وأصبحت actions عبر callbacks تنسقها الشاشة |
| N-3 | BrandsScreen تنسق refresh الإحصاءات في عدة مسارات وتستعمل MessageViewWidgets مباشرة؛ نمط Auth يستخدم BaseCubit/FlashMessages/Effects | مؤكد من الكود | `brands/presentation/pages/brands_screen.dart:39-120` | — | يلزم توحيد orchestration لاحقاً؛ لا تعديل في المرحلتين 0 و1 |
| N-4 | إدراج أبناء شرطية قبل FilterBar/Expanded قد يغيّر مواضع العناصر؛ ثُبّتت المواضع بإبن placeholder دائم | غير مؤكد | `app_page_templates.dart:140-146,209-216,300-309`; `list_page_template_test.dart`; `page_template_child_identity_test.dart` | `e84312b57699df525c8f54d5cc91da991f23c74a` | أُضيفت اختبارات ListPageTemplate وFormPageTemplate وDashboardTemplate؛ لم تُشغَّل على HEAD السابق لإثبات إعادة الإنتاج. لم يُشغَّل |
| N-5 | محرر الماركة لا يحرس التغييرات غير المحفوظة | مُعالَج في المرحلة 2 | `brand_editor_dialog.dart`; `app_form_dialog.dart` | phase 2 | dirty مشتق من controllers؛ الإلغاء وEscape يمران بتأكيد التغييرات غير المحفوظة |
| N-6a | BrandEditorDialogState عامة | مُعالَج في المرحلة 2 | `brand_editor_dialog.dart` | phase 2 | الحالة أصبحت `_BrandEditorDialogState` خاصة |
| N-6b | بعض Widgets لا تستقبل super.key | مؤكد من الكود | `brands/presentation/sections/brands_table_section.dart:21-24`; `brands/presentation/widgets/brand_editor_dialog.dart:18-23` | — | يُراجع عند نقل الملفات فقط إذا لم يتطلب تغيير منطق |
| N-6c | امتداد ملف الشعار عند غياب النقطة غير صحيح | مُعالَج في المرحلة 2 | `brands_remote_data_source_impl.dart` | phase 2 | يُحدد الامتداد وفق MIME type فقط |
| U-1 | توزيع الإجراءات الحالي: Edit أساسي، والحذف يظهر فقط عند productCount == 0، وتفعيل/تعطيل في Overflow | مؤكد من الكود | `brands/presentation/sections/brands_table_section.dart:112-139` | — | الحذف مشروط بقيمة 0 تحديداً؛ null لا يظهر |
| U-2 | حقل رابط الشعار اليدوي ما زال جزءاً من BrandLogoSection إلى جانب الرفع/الإزالة | مؤكد من الكود | `brands/presentation/sections/brand_logo_section.dart:20-25,65-100` | — | — |
| U-3 | فشل Refresh يحول الحالة إلى Failed بدلاً من إبقاء الصفوف | مُعالَج في المرحلة 2 | `brands_list_cubit.dart`; `brands_screen.dart` | phase 2 | الصفوف السابقة تبقى ظاهرة مع InlineBanner وإعادة المحاولة |
| ST-1 | نقل Brands إلى catalog/brands/{data,domain,presentation,di} مع إبقاء Hub وDI/Routes الخاصة به على مستوى catalog | مُنفَّذ | `lib/app/features/catalog/brands/`; `catalog/di/catalog_di.dart`; `catalog/presentation/routing/catalog_routes.dart` | `72961a6c55501e5d131c3a5bb99e8ec2501fdbac` | نقل الملفات والاختبارات وتحديث imports وDI ومسارات Brands. |
| ST-2 | ملفات كل Cubit تجمع State وCubit في ملف واحد ولا تتبع مجلد cubit/<name> | مؤكد من الكود | `presentation/cubit/brands/presentation/cubit/brand_form_cubit.dart`; `brands/presentation/cubit/brand_stats_cubit.dart`; `brands/presentation/cubit/brands_list_cubit.dart` | — | يُسجل كاتفاق بنيوي للميزات القادمة؛ لا يُعاد تقسيم Cubits ضمن النقل الصرف |
| ST-3 | GetBrandStatsUseCase مستقل | مُنفَّذ | `domain/usecase/get_brand_stats_use_case.dart` | phase 2 | Cubit أصبح مستهلكاً للـ UseCase المسجل في DI |
| DEC-1 | لا Freezed ولا Bloc؛ Cubit فقط | مؤكد من الكود | `pubspec.yaml`; `presentation/cubit/*.dart` | — | قرار بلا كود |
| DEC-2 | Effects عبر BaseCubit الموجود | مؤكد من الكود | `lib/app/core/foundation/base/base_cubit.dart` | — | قرار بلا كود |
| DEC-3 | تأجيل FormSection وFormFieldGroup حتى تتكرر الحاجة في ميزتين | مؤكد من الكود | لا تغيير مطلوب | — | قرار بلا كود |
| DEC-4 | ConfirmDialog لا يُعدّل الآن | مؤكد من الكود | `app_confirm_dialog/confirm_dialog.dart` | — | قرار بلا كود |
| FIX-1 | تحديث مرجع BrandsKeys في سجل المفاتيح ومسارات الدعم النسبية لاختبارات Brands بعد النقل | مُنفَّذ | `lib/app/localization/key_registry.dart:23`; اختبارات `brands_repository_test.dart`, `brand_logo_upload_cubit_test.dart`, `brand_stats_cubit_test.dart` | `767aff2af8baf7d2b124077a3f2cbb4f9153832b` | كشف CI مراجع قديمة؛ حُدثت للمسارات الجديدة. |
| FIX-2 | تحديث مستهلكي BrandsKeys/BrandsRoutes/BrandsScreen خارج الميزة، وتصحيح imports helpers للاختبار المنقول، وتركيز اختصارات AppFormDialog وإصلاح اختبارات spinner/state | مُنفَّذ | `catalog_hub_screen.dart`; `route_guards.dart`; `route_registry.dart`; `destinations.dart`; `brands_screen_responsive_test.dart`; `app_form_dialog.dart`; `brands_cubit_test.dart` | `499bafd9165eff1538bddc114ebed2fb831e5b9a` | استجابة مباشرة لأخطاء CI بعد النقل والمرحلة 1. |
| FIX-3 | نقل Focus إلى داخل CallbackShortcuts وإصلاح مصفوفة اختبارات Brands | مُنفَّذ | `app_form_dialog.dart`; `brands_screen_responsive_test.dart` | phase 1 | تأكد CI من نجاح التحليل والاختبارات، بما فيها اختبارات Catalog UI. |

## الحالة الحالية — 2026-11-21

- الفرع: `feat/cat07-ui-remediation`. HEAD قبل تحديث هذا التقرير: `7dbc6a57e90a6043ed78f43dd9fb53c8cf3a2bb3`.
- المرحلة 0: مُنفَّذة؛ نُقلت Brands والاختبارات إلى `catalog/brands` مع بقاء Hub وDI/Routes العامة على مستوى catalog.
- المرحلة 1: مُنفَّذة؛ أضيف AppFormDialog، وثُبتت مواضع الأبناء في القوالب، وأُصلحت اختبارات Escape وAccessCubit.
- المرحلة 2 (Brands فقط): مُنفَّذة في هذا الفرع:
  - دمج محرر الماركة مع AppFormDialog وإزالة ازدواج Saving؛ dirty/busy guard يغطي الحفظ ورفع الشعار.
  - رفع ملكية BrandLogoUploadCubit إلى مستوى المحرر.
  - إضافة GetBrandStatsUseCase وفصل حساب الإحصاءات عن Cubit.
  - إضافة BrandsListRefreshFailed للاحتفاظ بآخر صفحة عند فشل التحديث، مع InlineBanner وإعادة المحاولة.
  - جعل BrandsTableSection وBrandsFilterBar callback-driven.
  - تمرير SQLSTATE من PostgREST عبر ApiException؛ تصنيف 23505 كـ unique و23503 كـ foreign-key.
  - معالجة امتداد الشعار عند غياب الامتداد بالرجوع إلى MIME type.
- الاختبارات المضافة/المحدثة تغطي فشل refresh، فصل الإحصاءات، SQLSTATE، وامتداد ملف الشعار. لم تتوفر أدوات Dart/Flutter محلياً؛ الاعتماد على CI.
- CI للـ HEAD أعلاه: Workflow run `44855423884` نجح: Check formatting وAnalyze وRun tests وRun catalog UI widget tests جميعها نجحت.
- لم تُعمّم المرحلة 2 على ميزات أخرى، ولم تُضف dependencies جديدة.

### المتبقي خارج نطاق المرحلة 2

- P1-4: قيمة productCount المجهولة تمنع الحذف احترازياً؛ ما زال يلزم قرار مجال صريح لمعنى unknown count.
- P2-11 وN-1: سياسة slug للأسماء العربية وإعادة توليده ما زالت تحتاج قراراً؛ المحرر يتيح إدخال slug يدوياً.
- P2-12: احتمال ملفات Storage يتيمة بعد رفع ناجح ثم إلغاء/فشل حفظ الماركة؛ يحتاج مسار تنظيف/تعويض مستقل.
- S-1: معالجة wildcard في البحث مؤجلة حتى اختبار سلوك PostgREST الفعلي.
- N-3: توحيد orchestration ورسائل الشاشة عبر BaseCubit/Effects قيد المرحلة 3.
- U-2: حقل رابط الشعار اليدوي ما زال متاحاً إلى جانب الرفع والإزالة.
- P2-8 وDEC-1..DEC-4: قرارات تصميم/نطاق لا تتطلب تغييراً في هذه المرحلة.


## متابعة تنفيذ البرومت — 2026-11-21

الفرع `feat/cat07-ui-remediation`؛ متابعة على HEAD بعد commits التنفيذ:

- `adae7329215d2fc6bdc4395a00a3bc1df122bda6`: أضيفت `BrandsRepository.getStats()` ونُقل حساب إجمالي/فعّال/غير فعّال إلى تنفيذ Repository، وأصبح GetBrandStatsUseCase يفوض العملية.
- `65c42878f76571c6c057818e283916c12935001f`: تصحيح تجميع الإحصاءات بحيث يعتمد على نتائج Repository ذات نوع Failure.
- `4233bb7f7818bdd572ccb7598a79a5927841375b`: إزالة fallback الذي يصنّف HTTP 409 بلا SQLSTATE كduplicate؛ وتحديد امتداد ملفات الشعار بواسطة MIME type فقط. تحديث وصف التقرير.
- `c2af5030afd5fb4bd6dfd64d672fe12b2ea6d0f0`: ترحيل BrandStatsCubit وBrandLogoUploadCubit إلى BaseCubit، مع إبقاء ملفات State منفصلة.
- `cb674160862f5b0aee0b8b8ddcc5b28a5f4b3e79`: ترحيل BrandFormCubit وBrandsListCubit إلى BaseCubit، مع إبقاء ملفات State منفصلة.

### ما لم يكتمل بعد

- إعادة تصميم BrandsListState إلى نموذج Equatable موحد يحمل status/query/result/failure، وتحديث الشاشة والاختبارات بما يتوافق.
- إعادة تنظيم BrandFormState إلى status موحد وتحديث الحوار، وإكمال Effects/FlashMessages المطلوبة orchestration.
- استكمال اختبارات جديدة/محدثة لهذه التغييرات وفحص imports/DI/الاستعمالات.
- لم تُشغّل dart format أو flutter analyze أو flutter test في هذه البيئة؛ لا تُعد هذه commits إثباتاً لسلامة البناء.
- الخطوة 0/التأكد من حوار تمدد الارتفاع ومرحلة 4 لم يُنفذا في هذه المتابعة.

تم الإبقاء على ملفات State المستقلة عمداً، وعدم دمجها في ملفات Cubit.
