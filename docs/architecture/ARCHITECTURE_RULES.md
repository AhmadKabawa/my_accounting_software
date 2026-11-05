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

### مقترح سياسة اعتماد Feature على Feature — بانتظار موافقة مالك المشروع

المقترح: لا تستورد Feature من Feature أخرى مباشرة. يكون التواصل عبر Core أو عقد Domain عام موثّق ومستقل عن تفاصيل Presentation وData. يحتاج أي استثناء إلى توثيق مبرره في ADR قبل اعتماده. **هذه قاعدة جديدة مقترحة وليست سياسة معتمدة بعد؛ لا تُنشأ لها ADR-0002 قبل موافقة مالك المشروع.**

### المخالفات المعروفة — فحص نصي بتاريخ 2026-11-04

- **مخالفة للمقترح الجديد:** يستورد `lib/app/features/splash/di/splash_di.dart` مباشرةً `package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart`، ثم ينشئ `SplashCubit` باستخدام `sl<AuthCubit>().checkAuthentication`. هذا ربط مباشر بين Featureين، كما أنه يعتمد على Cubit من طبقة Presentation في Feature أخرى.
- **Core → Features:** لم يُعثر على استيرادات من `lib/app/core/` إلى `features/` عند فحص استيرادات ملفات Core الحالية.
- **Data → Presentation:** لم يُعثر على استيرادات من مجلدات `data/` إلى `presentation/` في ملفات الميزات المفحوصة.
- **Domain → Flutter/Dio:** لم يُعثر على استيرادات Flutter أو Dio داخل مجلدات `domain/` المفحوصة.
- **ملاحظة تدقيق قديم:** الادعاء بأن `hive_manager.dart` و`cache_manager.dart` يستوردان `UserModel` من `features/auth` لا يطابق الكود الحالي؛ ملفا Core لا يستوردان `UserModel`. يظهر استعمال `UserModel` في `features/auth/di/auth_di.dart` حيث يفتح Auth صندوقه ويسجل Adapter الخاص به.
- يستورد `lib/app/app_di.dart` عدة Features لتنسيق التهيئة في Composition Root؛ هذا ملف تنسيق على مستوى التطبيق وليس استيراداً من Feature إلى Feature.


### حالة الفرض الآلي
هذه القواعد **غير مفروضة آلياً حالياً**: لا يوجد CI في المستودع (لا `.github/workflows`)، و`analysis_options.yaml` يعتمد `flutter_lints` فقط، ولا يوجد `import_lint` أو اختبار معماري. تُراجع يدوياً عند المراجعة. تحسين مستقبلي مقترح: فحص imports عبر أداة مناسبة (مثل `import_lint` أو اختبار يمسح imports) بعد إضافة CI، وبقرار منفصل عن هذا الملف. لا يُدّعى أن القواعد مفروضة آلياً قبل ذلك.

## 5. Responsive وTheme وWidgets

**المدخل الموحد للواجهات هو `context.ui`.** لا تصل Features إلى المحركات (`ScreenEngine` و`ScaleEngine`) ولا إلى التفاصيل الداخلية متى وُجدت واجهة عبر `context.ui`.

- **الألوان:** `context.ui.theme.colors` لألوان `ColorScheme` القياسية فقط (primary, surface, error ...)، و`context.ui.theme.semanticColors` للألوان الدلالية الخاصة (success, warning, info, debit, credit). `AppColors` للقيم الخام داخل ملفات الثيم فقط؛ الواجهات لا تستخدمه مباشرة. لا `Colors.x` ولا `Color(0x..)` جديدة في الواجهات، ولا نظام ألوان موازٍ. لا تُدرج الألوان الدلالية داخل `ColorScheme`.
- **النصوص:** `AppText` مع `AppTextType` (المصدر الموحد لأدوار النص)، و`context.ui.text.of(AppTextType)` عند الحاجة إلى `TextStyle`. لا `Theme.of(context).textTheme` للأحجام في الكود الجديد، ولا `Text` خام لنص يخص الواجهة، ولا تطبيق التحجيم المتجاوب مرتين. `letterSpacing` يبقى `0` دائماً (أي قيمة أخرى تكسر وصل الحروف العربية).
- **المسافات والأبعاد:** `context.ui.spacing` و`padding` و`radius` و`size` و`icon` و`shadow` مع Tokens (`AppSpacing` وغيرها)، بدل أرقام حرفية و`SizedBox` برقم.
- **التخطيط المتجاوب:** `context.ui.grid.widget` لقرار التخطيط حسب نوع الجهاز، و`context.ui.grid.adaptive` حسب المساحة الفعلية للعنصر، و`context.ui.screen` لنوع الشاشة. اختر `ResponsiveMode` المناسب ولا تخلط scaling مع adaptive selection. حدود الشاشات مصدرها `ScreenEngine`؛ لا تنسخ أرقامها.
- **الودجتات:** استخدم Core Widget (`AppText` و`AppButton` و`AppIcon` و`AppImage` و`AppAppBar` وعناصر التنقل) عندما يغطي الحاجة. يجوز استخدام Flutter Widget مباشرة للتخطيط الهيكلي (`Row` و`Column` و`Stack` و`Expanded` و`Padding` و`Scaffold` و`ListView`...) ولما لا يوجد له مقابل في Core، بشرط أن تأتي قيمه من `context.ui` والثيم. لا تبنِ زراً أو نصاً أو شريط تنقل مشتركاً بديلاً.
- **الرسائل:** `MessageViewWidgets` هو نظام الرسائل الوحيد (مع `AppKey`)؛ لا `SnackBar` أو `AlertDialog` خام للرسائل.
- **الثيم:** `AppTheme` و`ThemeCubit` وملفات `theme/`. الثيم لا يعتمد على محرك Responsive.
- حافظ على RTL والترجمة عبر الأدوات الموجودة.
- لا تغيّر API عامة أو defaults للـ design system دون فحص كل الاستخدامات والاختبارات.

**ممنوع لأنه قديم أو مكرر:** `ResponsiveContextExtension` واختصاراتها (`context.spacing()` و`pad()` و`gap()`...)، والامتداد القديم على `BuildContext` المسمى `ThemeExtension` (و`themeColor`/`themeValue`)، و`TypographyHelper.h1..caption`، و`ThemeModeExtension.nameAr/nameEn`. هذه حُذفت ولا يعاد إنشاؤها.

## 6. Network وStorage وErrors

- استخدم `IApiClient` و`DioService` والـ Interceptors الموجودة؛ لا Dio لكل Feature.
- أضف المسارات إلى `AppEndpoints` ولا تكرر المسارات النصية.
- مسار الأخطاء الموحد: Data يرمي `AppException` ← `ExceptionMapper` يحولها إلى `Failure` ← تُمرَّر `failure.messageKey` (AppKey) وتُترجم وقت العرض (`AppText` أو `MessageViewWidgets`)، و`FailureTranslator` فقط حيث يلزم `String` جاهز (ويترجم مرة واحدة). Effects ورسائل الواجهة تحمل `AppKey` لا نصاً مترجماً. لا تترجم داخل Repository ولا وقت الإصدار.
- **الترجمة:** `AppKey` للودجتات، و`.tran` فقط حيث يلزم `String`، و`.tr(args:/namedArgs:)` عند وجود متغيرات. ممنوع `'text'.tr()` ونصوص واجهة ثابتة جديدة؛ أضف المفتاح في `AppKeys` وملفات ar/en.
- **الإعدادات:** `AppConfig` هو المدخل الوحيد لإعدادات التطبيق وقيم البيئة؛ Features لا تستورد `EnvConfig`. قراءة `fromEnvironment` تبقى `const` وقت البناء.
- **التحقق من المدخلات:** `AppValidator`/`ValidationRule` هو النظام الوحيد؛ لا validator موازياً.
### سياسة Retry وidempotency — `RetryInterceptor`

المصدر التنفيذي: `network/dio/interceptors/retry_interceptor.dart`.

- يعيد تلقائياً طلبات `GET` و`HEAD` و`OPTIONS` فقط.
- لا يعيد طلبات الكتابة `POST` و`PUT` و`PATCH` و`DELETE` تلقائياً؛ انتهاء المهلة لا يثبت أن الخادم لم ينفذ العملية.
- يمكن لطلب كتابة أن يطلب إعادة المحاولة عبر `Options(extra: {'idempotent': true})`، لكن لا تستخدم ذلك لعملية مالية إلا إذا كان الخادم يفرض idempotency حقيقياً يمنع تنفيذ الأثر مرتين.
- الأخطاء المؤقتة التي يعالجها: `connectionTimeout` و`receiveTimeout` و`connectionError` واستجابات HTTP ذات الحالة `5xx` أو أعلى. لا يعيد أخطاء `4xx`.
- الحد الأقصى للمحاولات والتأخير الأساسي من `AppConfig.maxRetries` و`AppConfig.retryDelay`. التأخير خطي: `baseDelay × رقم المحاولة`.


- اختر Storage حسب طبيعة البيانات. **لا تحفظ Tokens في SharedPreferences**؛ استخدم مسار التخزين الآمن المعتمد.
- لا تحفظ أسرار الخادم أو `service_role` داخل التطبيق أو المستودع.
- لا يوجد تنفيذ Realtime فعّال؛ `RealtimeClient` عقد مجرد فقط.

## 7. قواعد الأموال وسلامة السجلات

- لا تستخدم `double` لتمثيل المبالغ المالية المعتمدة أو تخزينها؛ استخدم تمثيلاً عشرياً دقيقاً أو وحدات نقدية صحيحة بعد اعتماد نموذج العملة.
- احتفظ بالعملة الأصلية والمبلغ الأصلي وسعر الصرف المستخدم ومصدره؛ لا تجمع عملات مختلفة دون تحويل موثق.
- اشتق الأرصدة من المستندات والحركات والمدفوعات والتخصيصات والتسويات المرحلة، لا من إجماليات قابلة للتعديل يدوياً.
- لا تعدّل المستند المالي المرحّل بصمت؛ استخدم reversal أو correction موثقاً وقابلاً للتدقيق.
- نفّذ الترحيل المالي وتحديث المخزون والتحقق من القيود الحرجة على الخادم الموثوق ضمن معاملات آمنة قدر الإمكان.
- امنع تكرار الآثار المالية بآلية idempotency يفرضها الخادم؛ لا تعتمد على Flutter وحده.
- لا تخترع قواعد محاسبية عند غموض يؤثر في الأرصدة أو المخزون أو العملات؛ اطلب توضيحاً.

## 8. DI ودورة الحياة

- Core DI (`initCoreDI()`) مسؤول عن تسجيل خدمات Core فقط. خدمة تخص ميزة (مثل `GoogleSignIn` للـ Auth) تُسجَّل في DI تلك الميزة.
- Feature DI مسؤول عن اعتماديات Feature، داخل `features/<feature>/di/`.
- `lib/app/app_di.dart` هو منسق التهيئة: يستدعي Core ثم Features بالترتيب المطلوب. لا نقطة تسجيل ثانية.
- افحص التسجيل الحالي قبل الإضافة وتجنب التسجيل المكرر.
- اختر factory/singleton/lazy singleton حسب عمر الكائن ومشاركة الحالة وموارد `close/dispose`.
- لا تسجل Cubit حالته مستقلة لكل صفحة كـ Singleton، ولا Cubit تراه عدة واجهات كنسخة جديدة في كل مرة دون فهم الأثر.

## 9. الاختبارات والتوثيق

عند إضافة أو تعديل أداة Core:
- أضف أو حدّث الاختبار المناسب.
- حدّث `CORE_MAP.md` عند تغيير المسؤولية أو إضافة ملف/قدرة، مع تحديث `CORE_TEST_COVERAGE.md` عند تغيّر الاختبارات أو الفجوات.
- حدّث `CORE_USAGE.md` عند إضافة نمط استخدام أو تغيير توقيع.
- حدّث `AGENTS.md`/`CLAUDE.md`/`SKILL.md` فقط عند تغيّر قواعد العمل نفسها.
- راجع الاستخدامات وImports وExports وpart/part of.
- لا تصنف API بأنها جاهزة إن كانت عقداً أو stub، وسجل القيود والفجوات صراحة.
- **قاعدة توثيق نتائج الفحوصات:** لا تصف `flutter analyze` أو `flutter test` أو `dart format` أو بناء منصة بأنه ناجح ما لم يُشغّل الأمر فعلياً؛ اذكر الأوامر التي لم تُشغّل صراحةً.
- لا تثبّت في التوثيق قيماً تتقادم (عدد ملفات، Breakpoints، SHA، قيم إعدادات)؛ أشر إلى الملف المسؤول.

## 10. مجموعات part/part of

توجد مجموعات مترابطة في Responsive:
- `engine/app_enums.dart` وملفات `engine/app_enums/*.dart`.
- `extension/ui_extension.dart` وملفات `extension/ui_extension/*.dart` (وتشمل `app_text_type.dart` الذي يعرّف `AppTextType`).

وفي Access: `access_cubit.dart` مع `access_state.dart`.

`helper/responsive_helper.dart` ملف مستقل (لا أجزاء تابعة بعد حذف `ResponsiveContextExtension`).

لا تفصل أو تنقل ملفاً مفرداً من هذه المجموعات، وافحص جميع أعضاء المجموعة قبل تعديلها.

## 11. القاعدة الإلزامية عند إضافة نظام أو ميزة جديدة في Core

1. افحص أولاً علاقتها بـ `context.ui`. إن وُجدت علاقة، أضف واجهة الوصول المناسبة داخله.
2. اجعل `context.ui` المدخل العام الموحد للـ Features؛ لا تجعلها تصل مباشرة إلى المحركات أو التفاصيل الداخلية متى أمكن توفير واجهة.
3. لا تضف وظائف لمجرد إضافتها (راجع شروط §2).
4. إن احتاج نظام موجود إلى تطوير، فطوّره بدل إنشاء بديل.
5. لا تغيّر بنية الأنظمة المستقرة دون مبرر واختبارات.
