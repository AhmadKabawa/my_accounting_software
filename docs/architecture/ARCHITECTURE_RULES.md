# قواعد Core والمعمارية المشتركة

## 1. تعريف Core

Core هو موضع البنية التحتية والقدرات العرضية المشتركة المستقلة عن Features. ليس مكاناً عاماً لكل كود لا نعرف أين نضعه، وليس مستودعاً لمنطق الأعمال الخاص بميزة.

أمثلة مناسبة: Network client، Storage abstraction، Error mapping، Responsive tokens، Theme، Localization، Widgets design-system المشتركة، DI bootstrap.

أمثلة غير مناسبة: حساب إجمالي فاتورة، قواعد خصم منتج، منطق شاشة تقرير بعينها، أو DTO خاص بميزة واحدة.

## 2. قرار مكان الكود الجديد

ضع الكود داخل Feature عندما:
- يخدم Feature واحدة أو يعبر عن مفهوم أعمال خاص بها.
- يعتمد على Models/Repositories/UseCases الخاصة بها.
- لا يوجد سبب واضح لجعله عقداً عاماً.

ضعه في Core عندما:
- يمثل قدرة بنية تحتية أو UI design-system مشتركة.
- لا يعتمد على أي Feature.
- له واجهة ومسؤولية واضحة ويمكن استخدامه دون معرفة تفاصيل ميزة بعينها.
- يوجد أكثر من مستهلك فعلي، أو هو بطبيعته cross-cutting (مثل logging/network/theme) مع مبرر واضح حتى لو بدأ بمستهلك واحد.

لا تنقل الكود إلى Core لمجرد توقع استخدامه مستقبلاً.

## 3. إلزامية إعادة الاستخدام

قبل إنشاء ملف أو Class أو Extension أو Widget أو Service:
1. ابحث عن الوظيفة في CORE_MAP.
2. ابحث في ملفات Core نفسها؛ التوثيق قد يتأخر عن الكود.
3. افحص توقيع الأداة، سلوكها، حدودها، واعتمادياتها.
4. افحص اختبارات الأداة واستخداماتها الحالية.
5. أعد استخدامها كما هي إذا كانت مناسبة.
6. وسّعها فقط إذا كان التوسيع يحافظ على مسؤوليتها ولا يكسر مستخدميها.
7. أنشئ أداة جديدة فقط بعد إثبات عدم وجود بديل مناسب.

ممنوع إنشاء بديل موازٍ لمجرد عدم معرفة الوكيل بوجود الأداة.

## 4. قواعد الاعتماد والطبقات

- Core لا يستورد Features.
- Domain لا يعتمد على Flutter أو Dio أو تفاصيل Storage أو Data/Presentation.
- Data لا يستورد Presentation.
- لا تضع Business Logic داخل Widgets أو Core UI.
- Feature DI يسجل اعتماديات Feature؛ Core DI يسجل البنية التحتية العامة؛ `lib/app/app_di.dart` ينسق التهيئة.
- لا تنشئ Service Locator أو Network client أو Error system ثانياً.
- لا تضف package أو abstraction دون حاجة موثقة.

## 5. Responsive وTheme وWidgets

- استخدم `context.ui` و`Rh` وTokens الموجودة قبل MediaQuery calculations أو constants responsive خاصة.
- استخدم `context.ui.grid.widget` لقرار layout حسب الجهاز، و`context.ui.grid.adaptive` حسب المساحة الفعلية داخل العنصر.
- لا تخلط بين scaling وadaptive selection؛ اختر ResponsiveMode المناسب للحاجة.
- استخدم AppText وAppButton وAppIcon وAppImage وAppAppbar وعناصر التنقل الحالية قبل بناء بديل مشترك.
- استخدم AppTheme/AppColors/AppTextStyles/ThemeCubit قبل تعريف ثيم أو ألوان/أنماط متوازية.
- حافظ على RTL وLocalization عبر الأدوات الموجودة.
- لا تغيّر API عامة أو defaults للـ design system دون فحص كل الاستخدامات والاختبارات.

## 6. Network وStorage وErrors

- استخدم IApiClient/DioService وInterceptors الموجودة؛ لا تنشئ Dio لكل Feature.
- أضف المسارات إلى AppEndpoints، ولا تكرر المسارات النصية.
- حافظ على ApiResult وExceptionMapper وFailure كمسار موحد لمعالجة النتائج والأخطاء.
- لا تعاود إرسال عمليات كتابة مالية تلقائياً دون ضمان idempotency.
- اختر Storage حسب طبيعة البيانات: secure للبيانات الحساسة، preferences للإعدادات، Hive/cache لما يناسبه.
- لا تحفظ أسرار الخادم أو service_role داخل تطبيق Flutter.

## 7. DI ودورة الحياة

- افحص التسجيل الحالي قبل إضافة تسجيل.
- اختر factory/singleton/lazy singleton بناءً على عمر الكائن ومشاركة الحالة وموارد close/dispose.
- لا تسجل Cubit حالته يجب أن تكون مستقلة لكل صفحة كـ Singleton.
- لا تسجل Cubit يجب أن تراه عدة واجهات كنسخة مشتركة دون فهم أثر ذلك.
- حافظ على الترتيب في Composition Root، وتجنب التسجيل المكرر.

## 8. الاختبارات والتوثيق

عند إضافة أو تعديل أداة Core:
- أضف/حدّث اختبار الوحدة أو Widget/Integration test المناسب.
- حدّث CORE_MAP عند تغيير المسؤولية أو إضافة ملف/قدرة.
- حدّث CORE_USAGE عند إضافة نمط استخدام أو تغيير API.
- حدّث AGENTS/CLAUDE/Skill فقط إذا تغيرت قواعد العمل، لا عند كل تعديل داخلي صغير.
- راجع كل الاستخدامات وImports وExports وpart/part of.
- لا تدّعِ تشغيل Flutter analyze/test إن لم تشغّلهما فعلياً.

## 9. مجموعات part/part of

توجد مجموعات مترابطة في Responsive:
- `engine/app_enums.dart` وملفات `engine/app_enums/*.dart`.
- `extension/ui_extension.dart` وملفات `extension/ui_extension/*.dart`.
- `helper/responsive_helper.dart` وملفاته التابعة.

لا تفصل أو تنقل ملفاً مفرداً من هذه المجموعات. افحص جميع أعضاء المجموعة قبل تعديلها.

## 10. تحديث الخريطة

الخريطة لقطة قابلة للتقادم. عند كل تغيير Core:
- احذف/عدّل الوصف القديم عند إزالة أو نقل شيء.
- أضف المسار الجديد مع المسؤولية.
- حدّث أمثلة الاستخدام إن تغير التوقيع.
- لا تصنف API بأنها جاهزة إن كانت stub أو غير مكتملة.
- سجل القيود والاختبارات غير المنفذة بوضوح.
