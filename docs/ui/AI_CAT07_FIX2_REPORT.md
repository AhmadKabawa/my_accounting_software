# AI_CAT07_FIX2_REPORT — استكمال CAT-07

- المستودع: `AhmadKabawa/my_accounting_software`
- الفرع: `feat/cat07-categories-ui`
- النطاق: إكمال شاشة التصنيفات على نمط الماركات؛ لا ميزات خارج D1–D11.
- لا توجد بيئة Flutter محلية؛ لم يُدّع تشغيل analyze/test محلياً.

## 1. الملفات ومجموعات التنفيذ

### Domain / Data
- `domain/category_image_policy.dart`، `UploadCategoryImageUseCase`، `CategoryDraft`، `CategoryTree`، `CategoryListQuery`.
- `CategoriesRepository` و`CategoriesRemoteDataSource` و`CategoriesRemoteDataSourceImpl` و`CategoriesEndpoint`، مع رفع Storage عبر Core.
- إسقاط `product_categories(count)` مع fallback آمن بلا count عند HTTP 400، و`updated_at` ضمن `+std`.

### Presentation / Core
- `CategoryImageSection` و`CategoryEditorDialog`/`CategoryEditorFields`، `CategoryStatsBar`، `CategoriesFilterBar`، `CategoryDetailsPanel`، `CategoryIdentity`، `CategoryCard`، `CategoriesListCubit` و`categoriesListConfig`.
- إعادة استخدام `AppImageUploadField` و`StorageImageUploader` و`AppDetailsPanel` و`AppDataView.onRowTap` الموجودة مسبقاً في Core.
- `key_registry.dart` يسجل `CategoriesKeys.values` بالفعل؛ لا تسجيل مكرر.

### Tests
- `category_tree_test.dart`، `categories_list_cubit_test.dart`، `category_form_cubit_test.dart`، `categories_remote_data_source_test.dart`، `categories_screen_test.dart`، واختبارات Core لـ AppDataView/Details panel حسب الملفات الموجودة.

## 2. القرارات D1–D11
| القرار | النتيجة |
|---|---|
| D1 | واجهة رفع 5 MB JPEG/PNG/WebP مع اختيار وسحب وإفلات؛ bucket `product-images` ومسار `categories/`. سياسة INSERT المناسبة غير موجودة حالياً؛ طلب B-25 مفتوح، والواجهة تعرض رسالة واضحة عند 403. |
| D2 | مفتاح نشط في المحرر؛ `is_active` يرسل عند الإنشاء، وفي PATCH فقط عند تغيّره. |
| D3 | إحصاءات محلية من الشجرة دون شبكة أو Cubit جديد؛ unknown يعرض `—`. |
| D4 | فلاتر الحالة/المستوى/الاستخدام محلية في Query/Tree. |
| D5 | خيارات الفرز تظهر فقط في النتائج المسطحة؛ ترتيب الشجرة ثابت. |
| D6 | عمود المنتجات وعمود آخر تحديث لأن `updated_at` موجود ضمن `+std`; البطاقات تعرض الاسم والمسار والحالة والمنتجات والأبناء. |
| D7 | النسخ تحت الأب نفسه مع لاحقة اسم وslug. |
| D8 | إيقاف الأب لا يغيّر حالة الأبناء؛ badge مشتق «تحت أب موقوف»؛ التأكيد يذكر عدد الأبناء النشطين. |
| D9 | لوحة Core موجودة مسبقاً؛ جانبية على الديسكتوب وBottom Sheet على الهاتف؛ `selectedId` منفصل عن bulk selection. |
| D10 | Tooltips/Semantics وFocus/Tab/Arrow/Enter من Core وEscape للوحة/الحوار؛ التحقق البصري اليدوي ما زال مطلوباً. |
| D11 | مفاتيح عربية/إنجليزية في `CategoriesKeys` ومسجلة في `key_registry`. |

## 3. ما لم يُنفذ أو يحتاج طرفاً خارجياً
- **سياسة Storage الحية:** لم تُعدّل قاعدة Supabase من هذا الفرع؛ B-25 يطلب INSERT محدوداً لمجلد `categories/` بصلاحية `masterdata.manage`. لا يمكن إثبات نجاح الرفع الحي قبل تطبيقه.
- **اختبار PostgREST الحي:** علاقة FK مؤكدة في DATA_MODEL، لكن الاستجابة الفعلية لـ `product_categories(count)` تحتاج تجربة على المشروع الحي. fallback موجود ولا يحوّل null إلى صفر.
- **Chrome المرئي:** يحتاج فحص المالك على 360/1200 بكسل، RTL/LTR، بما يشمل لوحة التفاصيل والتبويب والـ overflow.

## 4. توضيح تناقض productCount
`DATA_MODEL.md` يؤكد FK `product_categories.category_id → categories.id`، ولذلك العلاقة التي تسمح بـ `product_categories(count)` مؤكدة على مستوى schema. ما لم يُتحقق منه هو PostgREST embed في الخدمة الحية. الوثيقتان الآن تميزان الأمرين، ويظل fallback بلا count ضرورياً.

## 5. CI
- `45727093642`: فشل Analyze على revision أقدم بسبب أخطاء Wiring/Context/State في التغييرات المبكرة؛ عولجت لاحقاً.
- `45727521400` و`45727538909` و`45727702712`: فشل Auto-format لأن job شغّل `dart format` قبل `flutter pub get`، فلم يستطع Dart حل `package:flutter_lints/flutter.yaml`. لم تُخفف بوابة أو تحليل؛ أضيفت خطوة dependency resolution إلى job التنسيق في commit `7da0aca`.
- التشغيل النهائي على آخر commit: **يُستكمل بعد اكتمال CI الأخضر**؛ لا يُعلن الإغلاق قبل تسجيل run ينجح فيه Auto-format وAnalyze وTests وCatalog UI Widget Tests جميعاً.

## 6. ما يحتاج فحصاً يدوياً من المالك
1. Chrome: 360 و1200، RTL وLTR؛ فحص الصفوف والبطاقات والبحث والفلاتر والفرز واللوحة الجانبية وBottom Sheet وEscape والتبويب.
2. Supabase: رفع صورة بحساب `masterdata.manage` دون `catalog.manage` بعد تطبيق B-25.
3. Supabase: GET `product_categories(count)` والتحقق من العدد؛ إذا فشل الإسقاط تأكد من `—` وحراسة الحذف.