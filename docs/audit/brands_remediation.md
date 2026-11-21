# تدقيق معالجة ميزة Brands

- الفرع: `feat/cat07-ui-remediation`
- HEAD عند بدء التدقيق: `55e290f3b8a9a08318d4593a6a50d1f840b2e0a0`
- تاريخ التدقيق: 2026-11-20
- مرجع اصطلاح التدقيق: لم يُعثر على `docs/audit/audit-status.md` أو مجلد `docs/audit/` في HEAD؛ أُنشئ هذا الملف في الموضع المطلوب.
- مصدر التحقق: قراءة الملفات الفعلية في HEAD. أرقام الأسطر تشير إلى HEAD الابتدائي ما لم يُذكر تحديث لاحق.

## سجل النتائج

| المعرّف | الوصف | الحالة | الدليل (ملف:سطر) | الـ commit | ملاحظات |
|---|---|---|---|---|---|
| P1-1 | ازدواج حالة Saving بين `_saving` في Dialog و`BrandFormSaving` في Cubit، والـ Dialog يعتمد على Either ولا يستمع للحالة | مؤكد من الكود | `brand_editor_dialog.dart:28,57-78`; `brand_form_cubit.dart:23-30,59-76` | — | يُعالج لاحقاً ضمن دمج Shell/Cubit |
| P1-2 | لا يوجد Dialog Shell عام؛ المحرر يبني Dialog يدوياً ويضاعف cardWidth ويستخدم cardHeight | مؤكد من الكود | `brand_editor_dialog.dart:86-94` | — | — |
| P1-3 | BrandStatsCubit يستدعي GetBrandsUseCase مرتين لجلب الإجمالي والفعّال | مؤكد من الكود | `brand_stats_cubit.dart:42-63` | — | طلبان منفصلان، لا GetBrandStatsUseCase |
| P1-4 | حذف الماركة يعتمد على `productCount != 0`؛ القيمة null تجعل الشرط true | مؤكد من الكود | `brands_list_cubit.dart:132-134` | — | null يمنع الحذف احترازياً؛ يلزم قرار مجال صريح حول unknown count |
| P1-5 | تصنيف HTTP 409 عام في مساري الكتابة والحذف | مؤكد من الكود | `brands_repository_impl.dart:103-120` | — | التصنيف يعتمد على statusCode 409 لا رمز/تفصيل الخطأ |
| P1-6 | فتح محرر الماركة عبر showDialog دون منع barrier أو PopScope؛ Escape يمكنه إغلاقه | مؤكد من الكود | `brands_screen.dart:43-50`; `brand_editor_dialog.dart:84-151` | — | — |
| P1-7 | BrandLogoUploadCubit يُنشأ داخل BrandLogoSection، فلا يملك Dialog حالة الرفع | مؤكد من الكود | `brand_logo_section.dart:27-30` | — | — |
| P2-8 | رفع الشعار يبقى State-only ولا يحتاج Effect | مؤكد من الكود | `brand_logo_upload_cubit.dart:9-41` | — | قرار بلا تغيير |
| P2-9 | أثناء refresh تبقى Ready لحظياً، لكن فشل الطلب يصدر Failed ويزيل الصفوف القديمة | مؤكد من الكود | `brands_list_cubit.dart:73-89` | — | الاحتفاظ الحالي لا يغطي مسار الفشل |
| P2-10 | FilterBar يفرّغ النص عند إزالة شارة البحث ومسح الكل؛ لا عيب مثبت فيه، والتزامن المتبقي مرتبط بـ N-4 | مؤكد من الكود | `filter_bar.dart:94-126`; `brands_filter_bar.dart:26-54` | — | لا تغيير مطلوب في FilterBar قبل اختبار N-4 |
| P2-11 | لا توجد سياسة واضحة لتحديث slug أو إعادة توليده؛ التوليد الحالي تلقائي فقط عندما يكون الحقل فارغاً | مؤكد من الكود | `brand_editor_dialog.dart:50-54,116-120` | — | قرار مجال مؤجل |
| P2-12 | احتمال ملفات Storage يتيمة بعد رفع مكتمل ثم إلغاء/فشل حفظ الماركة | مؤكد من الكود | `brands_remote_data_source_impl.dart:74-88`; `brand_editor_dialog.dart:64-82` | — | دين فني موثّق، لا تنفيذ في هذه المراحل |
| S-1 | `_escapeFilterValue` يهرّب backslash والاقتباس فقط؛ wildcard الرموز % و_ و* لا تُعالج هنا | مؤكد من الكود | `brands_remote_data_source_impl.dart:112-113` | — | أولوية منخفضة؛ مؤجل حتى اختبار قاعدة البيانات الفعلية |
| N-1 | `_slugify` يحذف كل ما ليس a-z0-9، فينتج slug فارغاً للاسم العربي | مؤكد من الكود | `brand_editor_dialog.dart:50-54` | — | — |
| N-2 | BrandsTableSection وBrandsFilterBar يستلمان BrandsListCubit مباشرة رغم وصف الأول بأنه Pure presentation | مؤكد من الكود | `brands_table_section.dart:18-46`; `brands_filter_bar.dart:13-19` | — | ربط العرض بالـ Cubit يناقض التعليق |
| N-3 | BrandsScreen تنسق refresh الإحصاءات في عدة مسارات وتستعمل MessageViewWidgets مباشرة؛ نمط Auth يستخدم BaseCubit/FlashMessages/Effects | مؤكد من الكود | `brands_screen.dart:39-120` | — | يلزم توحيد orchestration لاحقاً؛ لا تعديل في المرحلتين 0 و1 |
| N-4 | ListPageTemplate يدرج actions بشرط if داخل Column قبل FilterBar؛ FormPageTemplate وDashboardTemplate لديهما شروط خطأ في موضع مشابه قبل ابن ذي State/Expanded | غير مؤكد | `app_page_templates.dart:140-146,209-216,300-309` | — | استنتاج بنيوي؛ يلزم Widget Test لإثبات فقدان State. لم يُشغَّل |
| N-5 | محرر الماركة لا يحرس التغييرات غير المحفوظة، بخلاف FormPageTemplate الذي يملك dirty وUnsavedChangesGuard | مؤكد من الكود | `brand_editor_dialog.dart:18-151`; `app_page_templates.dart:23-108` | — | — |
| N-6a | BrandEditorDialogState عامة بدلاً من خاصة | مؤكد من الكود | `brand_editor_dialog.dart:22-25` | — | — |
| N-6b | بعض Widgets لا تستقبل super.key | مؤكد من الكود | `brands_table_section.dart:21-24`; `brand_editor_dialog.dart:18-23` | — | يُراجع عند نقل الملفات فقط إذا لم يتطلب تغيير منطق |
| N-6c | امتداد ملف الرفع مأخوذ من split('.') الأخير، ما يعطي اسم الملف كاملاً كامتداد عند غياب النقطة | مؤكد من الكود | `brands_remote_data_source_impl.dart:74-78` | — | — |
| U-1 | توزيع الإجراءات الحالي: Edit أساسي، والحذف يظهر فقط عند productCount == 0، وتفعيل/تعطيل في Overflow | مؤكد من الكود | `brands_table_section.dart:112-139` | — | الحذف مشروط بقيمة 0 تحديداً؛ null لا يظهر |
| U-2 | حقل رابط الشعار اليدوي ما زال جزءاً من BrandLogoSection إلى جانب الرفع/الإزالة | مؤكد من الكود | `brand_logo_section.dart:20-25,65-100` | — | — |
| U-3 | فشل Refresh يحول الحالة إلى Failed بدلاً من إبقاء الصفوف مع InlineBanner وإعادة المحاولة | مؤكد من الكود | `brands_list_cubit.dart:73-89`; `brands_table_section.dart:80-88` | — | مؤشر التحميل لا يُمثّل كحالة مستقلة عند وجود Ready |
| ST-1 | نقل Brands إلى catalog/brands/{data,domain,presentation,di} مع إبقاء Hub وDI/Routes الخاصة به على مستوى catalog | مُنفَّذ | `lib/app/features/catalog/brands/`; `catalog/di/catalog_di.dart`; `catalog/presentation/routing/catalog_routes.dart` | `72961a6c55501e5d131c3a5bb99e8ec2501fdbac` | نقل الملفات والاختبارات وتحديث imports وDI ومسارات Brands. |
| ST-2 | ملفات كل Cubit تجمع State وCubit في ملف واحد ولا تتبع مجلد cubit/<name> | مؤكد من الكود | `presentation/cubit/brand_form_cubit.dart`; `brand_stats_cubit.dart`; `brands_list_cubit.dart` | — | يُسجل كاتفاق بنيوي للميزات القادمة؛ لا يُعاد تقسيم Cubits ضمن النقل الصرف |
| ST-3 | لا يوجد GetBrandStatsUseCase مستقل | مؤكد من الكود | `domain/usecase/` (لا يوجد ملف get_brand_stats_use_case.dart) | — | مرتبط بـ P1-3 |
| DEC-1 | لا Freezed ولا Bloc؛ Cubit فقط | مؤكد من الكود | `pubspec.yaml`; `presentation/cubit/*.dart` | — | قرار بلا كود |
| DEC-2 | Effects عبر BaseCubit الموجود | مؤكد من الكود | `lib/app/core/foundation/base/base_cubit.dart` | — | قرار بلا كود |
| DEC-3 | تأجيل FormSection وFormFieldGroup حتى تتكرر الحاجة في ميزتين | مؤكد من الكود | لا تغيير مطلوب | — | قرار بلا كود |
| DEC-4 | ConfirmDialog لا يُعدّل الآن | مؤكد من الكود | `app_confirm_dialog/confirm_dialog.dart` | — | قرار بلا كود |

## الحالة الحالية — 2026-11-20

- خط الأساس: HEAD هو `55e290f`. لا تتوفر أدوات `dart` و`flutter` في بيئة التنفيذ؛ لذلك لم أُشغّل `dart format` أو `flutter analyze` أو `flutter test` محلياً.
- فحص CI الموجود لنفس HEAD: Workflow run `44839609573` فشل. خطوة التنسيق وجدت 13 ملفاً تحتاج format؛ خطوة analyze انتهت بالفشل؛ الاختبارات الكاملة انتهت بالفشل مع أخطاء ProviderNotFoundException في اختبارات PermissionGate/AccessCubit وأخطاء تفاعل في `app_searchable_dropdown_test.dart`. اختبار catalog UI المخصص نجح. هذه نتائج CI سابقة وليست تشغيلًا محلياً جديداً.
- المرحلة 0: مُنفَّذة في commit PHASE0؛ نُقلت ملفات Brands والاختبارات إلى `catalog/brands`، مع بقاء Hub و`catalog_di.dart` و`catalog_routes.dart` على مستوى catalog.
- المرحلة 1: بدأ التنفيذ؛ AppFormDialog أُضيف في commit مستقل، وما زال تثبيت مواضع أبناء القوالب (N-4) قيد التنفيذ.
- الاختبارات الجديدة: لا توجد اختبارات جديدة في هذا التدقيق؛ أي اختبار سيُضاف ولا يتاح تشغيله سيُوسم «لم يُشغَّل».
