# قواعد Core والمعمارية المشتركة

هذا الملف هو **المرجع الوحيد** للسياسة المعمارية المتعلقة بـ Core وحدود الطبقات. بقية الملفات (`AGENTS.md` و`CLAUDE.md` و`SKILL.md`) تحيل إليه ولا تكرر تفاصيله. خريطة الأدوات في `CORE_MAP.md`، وأمثلة الاستخدام في `CORE_USAGE.md`.

## 1. تعريف Core

Core هو موضع البنية التحتية والقدرات العرضية المشتركة المستقلة عن Features. ليس مكاناً لكل كود لا نعرف أين نضعه، وليس مستودعاً لمنطق الأعمال الخاص بميزة.

مناسب: Network client، Storage abstraction، Error mapping، Responsive tokens، Theme، Localization، Widgets الـ design system المشتركة، DI bootstrap.
غير مناسب: حساب إجمالي فاتورة، قواعد خصم، منطق شاشة تقرير، DTO خاص بميزة.

## 2. متى نضيف إلى Core ومتى نبقي الكود في Feature

**لا تضف أداة إلى Core لمجرد أنها قد تكون قابلة لإعادة الاستخدام مستقبلاً.**

تُضاف الأداة إلى Core فقط إذا تحققت **كل** الشروط:
1. مستقلة عن Features (لا تستورد شيئاً منها ولا تعتمد على مفاهيم أعمالها).
2. تمثل بنية تحتية أو قدرة مشتركة cross-cutting.
3. يوجد مستهلك فعلي ثانٍ، أو مبرر تقني واضح يثبت أنها بطبيعتها قدرة مشتركة.
4. لها مسؤولية محددة وواجهة واضحة ويمكن اختبارها.

إذا كانت خاصة بميزة واحدة ولا يوجد مبرر معماري لنقلها، تبقى داخل Feature. تُنقل لاحقاً إلى Core عند ظهور مستهلك ثانٍ فعلي.

## 3. إلزامية إعادة الاستخدام

قبل إنشاء ملف أو Class أو Extension أو Widget أو Service:
1. ابحث في `CORE_MAP.md` ثم في `lib/app/core` نفسها (الخريطة قد تتأخر عن الكود).
2. افحص التوقيع والسلوك والحدود والاعتماديات والاختبارات والاستخدامات الحالية.
3. أعد استخدام الأداة كما هي إن كانت مناسبة.
4. وسّعها فقط إذا حافظ التوسيع على مسؤوليتها ولم يكسر مستخدميها.
5. أنشئ أداة جديدة فقط بعد إثبات عدم وجود بديل مناسب، ثم طبّق البند 2.

ممنوع إنشاء بديل موازٍ لأداة موجودة لمجرد عدم اكتشافها.

## 4. قواعد الاعتماد بين الطبقات

- Core لا يستورد Features.
- Domain لا يعتمد على Flutter أو Dio أو تفاصيل Storage أو Data أو Presentation.
- Data لا يستورد Presentation.
- لا يوجد منطق أعمال داخل Widgets أو Core UI.
- Feature لا تنشئ Dio أو Storage أو Error system أو Service Locator موازياً.
- لا تضف package أو abstraction دون حاجة موثقة.

### حالة الفرض الآلي
هذه القواعد **غير مفروضة آلياً حالياً**: لا يوجد CI في المستودع (لا `.github/workflows`)، و`analysis_options.yaml` يعتمد `flutter_lints` فقط، ولا يوجد `import_lint` أو اختبار معماري. تُراجع يدوياً عند المراجعة. تحسين مستقبلي مقترح: فحص imports عبر أداة مناسبة (مثل `import_lint` أو اختبار يمسح imports) بعد إضافة CI، وبقرار منفصل عن هذا الملف. لا يُدّعى أن القواعد مفروضة آلياً قبل ذلك.

## 5. Responsive وTheme وWidgets

- استخدم `context.ui` و`Rh` وTokens الموجودة قبل حسابات MediaQuery أو ثوابت responsive خاصة.
- `context.ui.grid.widget` لقرار التخطيط حسب نوع الجهاز، و`context.ui.grid.adaptive` حسب المساحة الفعلية للعنصر.
- لا تخلط بين scaling وadaptive selection؛ اختر `ResponsiveMode` المناسب.
- حدود الشاشات مصدرها `ScreenEngine`؛ لا تنسخ أرقامها في الكود أو التوثيق.
- استخدم `AppText` و`AppButton` و`AppIcon` و`AppImage` و`AppAppBar` وعناصر التنقل الحالية قبل بناء بديل.
- استخدم `AppTheme` و`AppColors` و`AppTextStyles` و`ThemeCubit` قبل تعريف ثيم أو ألوان متوازية. الثيم لا يعتمد على محرك Responsive.
- حافظ على RTL والترجمة عبر الأدوات الموجودة.
- لا تغيّر API عامة أو defaults للـ design system دون فحص كل الاستخدامات والاختبارات.

## 6. Network وStorage وErrors

- استخدم `IApiClient` و`DioService` والـ Interceptors الموجودة؛ لا Dio لكل Feature.
- أضف المسارات إلى `AppEndpoints` ولا تكرر المسارات النصية.
- مسار الأخطاء الموحد: Data يرمي `AppException` ← `ExceptionMapper` يحولها إلى `Failure` ← `FailureTranslator` أو `AppKey` يترجمها للعرض. لا تترجم داخل Repository.
- **إعادة المحاولة:** `RetryInterceptor` يعيد GET/HEAD/OPTIONS فقط. لا تعيد عمليات الكتابة المالية تلقائياً؛ لا تضع `Options(extra: {'idempotent': true})` على عملية مالية إلا إذا كان الخادم يضمن idempotency حقيقياً. التفاصيل في `CORE_MAP.md`.
- اختر Storage حسب الطبيعة: secure للحساس، preferences للإعدادات، Hive/cache لما يناسبه. لا Tokens في SharedPreferences.
- لا تحفظ أسرار الخادم أو `service_role` داخل التطبيق أو المستودع.
- لا يوجد تنفيذ Realtime فعّال؛ `RealtimeClient` عقد مجرد فقط.

## 7. DI ودورة الحياة

- Core DI (`initCoreDI()`) مسؤول عن تسجيل خدمات Core فقط.
- Feature DI مسؤول عن اعتماديات Feature، داخل `features/<feature>/di/`.
- `lib/app/app_di.dart` هو منسق التهيئة: يستدعي Core ثم Features بالترتيب المطلوب. لا نقطة تسجيل ثانية.
- افحص التسجيل الحالي قبل الإضافة وتجنب التسجيل المكرر.
- اختر factory/singleton/lazy singleton حسب عمر الكائن ومشاركة الحالة وموارد `close/dispose`.
- لا تسجل Cubit حالته مستقلة لكل صفحة كـ Singleton، ولا Cubit تراه عدة واجهات كنسخة جديدة في كل مرة دون فهم الأثر.

## 8. الاختبارات والتوثيق

عند إضافة أو تعديل أداة Core:
- أضف أو حدّث الاختبار المناسب.
- حدّث `CORE_MAP.md` عند تغيير المسؤولية أو إضافة ملف/قدرة، بما فيه قسم تغطية الاختبارات.
- حدّث `CORE_USAGE.md` عند إضافة نمط استخدام أو تغيير توقيع.
- حدّث `AGENTS.md`/`CLAUDE.md`/`SKILL.md` فقط عند تغيّر قواعد العمل نفسها.
- راجع الاستخدامات وImports وExports وpart/part of.
- لا تصنف API بأنها جاهزة إن كانت عقداً أو stub، وسجل القيود والفجوات صراحة.
- لا تدّعِ تشغيل `flutter analyze/test` إن لم يُشغَّلا فعلياً.
- لا تثبّت في التوثيق قيماً تتقادم (عدد ملفات، Breakpoints، SHA، قيم إعدادات)؛ أشر إلى الملف المسؤول.

## 9. مجموعات part/part of

توجد مجموعات مترابطة في Responsive:
- `engine/app_enums.dart` وملفات `engine/app_enums/*.dart`.
- `extension/ui_extension.dart` وملفات `extension/ui_extension/*.dart`.
- `helper/responsive_helper.dart` وملفاته التابعة.

وفي Access: `access_cubit.dart` مع `access_state.dart`.

لا تفصل أو تنقل ملفاً مفرداً من هذه المجموعات، وافحص جميع أعضاء المجموعة قبل تعديلها.
