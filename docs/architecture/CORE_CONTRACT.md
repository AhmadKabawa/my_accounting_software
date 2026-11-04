# عقد استخدام Core (الإلزامي)

> **القاعدة:** كل ما يغطيه Core تُستخدم أداته **إلزاماً** داخل الـ Features. إنشاء بديل موازٍ ممنوع (`ARCHITECTURE_RULES.md` §3). هذا الملف يجيب لكل أداة على ثلاثة أسئلة: **ما المطلوب؟ لماذا هو الأفضل؟ وما الممنوع؟**
>
> - اكتشاف الأداة ومكانها: `CORE_MAP.md`.
> - أمثلة الاستخدام: `CORE_USAGE.md`.
> - افتح الملف المصدر وتحقق من التوقيع قبل نسخ أي مثال.
> - إن لم تناسبك أداة Core: **طوّرها** (`ARCHITECTURE_RULES.md` §3 و§10) ولا تنشئ بديلاً.

---

## 1. الواجهة والتصميم

| الحاجة | الإلزامي | لماذا | الممنوع |
|---|---|---|---|
| لون | `context.ui.theme.colors` (ColorScheme)، `semanticColors` (نجاح/تحذير/معلومة/مدين/دائن)، `theme.value(dark:, light:)` | مصدر واحد يتبدل تلقائياً بين الفاتح والداكن، وتغيير الهوية البصرية يتم في مكان واحد | `Colors.x`، `Color(0xFF...)`، `AppColors.x` داخل الواجهات، `Theme.of(context).colorScheme` |
| نص | `AppText(AppKeys.x, type: AppTextType.x)` و`AppText.raw(data)` | يترجم وقت العرض فيتبع اللغة الحالية، ويقيس الخط حسب الشاشة، ويحافظ على `letterSpacing = 0` (غيره يكسر وصل الحروف العربية) | `Text('...')` لنص واجهة، `TextStyle(fontSize: ...)`، `'key'.tr()` |
| `TextStyle` فقط | `context.ui.text.of(AppTextType.x)`؛ ولأحجام خارج الأدوار `context.ui.text.size/style` | نفس القياس المتجاوب ولون الثيم | `Theme.of(context).textTheme.x.fontSize` |
| مسافة/حشوة/زاوية/أيقونة/حجم/ظل | `context.ui.spacing/padding/radius/icon/size/shadow` مع `AppSpacing`/`AppRadius`/... | Tokens تتكيف مع الجهاز، وتصميم متسق، وتعديل مركزي | `SizedBox(height: 16)`، `EdgeInsets.all(16)`، `BorderRadius.circular(12)` |
| مسافة بين عناصر | `context.ui.spacing.gap(AppSpacing.x)` (أو `Gap`) | يحدد محوره تلقائياً من `Row`/`Column` الأب | `SizedBox` برقم حرفي |
| تخطيط حسب الجهاز | `context.ui.grid.widget(mobile/tablet/desktop)`، `context.ui.screen.isDesktop`... | حدود الشاشات من مصدر واحد (`ScreenEngine`) | `MediaQuery` يدوي بأرقام، حدود عرض خاصة |
| تخطيط حسب مساحة العنصر (داخل pane/عمود) | `context.ui.grid.adaptive` (`AdaptiveLayout`) | يقرر بقيود الأب الفعلية لا بعرض الشاشة كله | `LayoutBuilder` بحدود مكررة |
| زر | `AppButton(AppKeys.x, ...)` / `AppButton.raw` (variants، `isLoading`) | حالات التحميل والتعطيل والأنماط والتصميم موحدة، والنص مترجم | `ElevatedButton`/`TextButton` لزر مشترك |
| أيقونة/صورة | `AppIcon`، `AppImage` (`.asset`، `.network`، `.avatar`، `.banner`، `.square`) | تحميل وخطأ وأشكال وHero جاهزة (انظر ملاحظة `AppImage` في `KNOWN_GAPS.md`) | `Image.network` مباشرة |
| شريط علوي/تنقل | `AppAppBar`، `AppNavigationBar`/`AppNavigationRail`/`AppSidebar` عبر `AppShell` و`AppDestination` | تنقل متكيف مع الشاشة وصلاحية لكل وجهة | بناء شريط تنقل بديل |
| رسالة للمستخدم | `MessageViewWidgets.showMessage(context, messageKey:, type:)` | ألوان ودلالات موحدة، يقبل `AppKey` فيتبع اللغة، أنواع `error/success/warning/info/loading` | `SnackBar`/`AlertDialog` خام للرسائل |
| اتجاه النص RTL | `context.isRTL`، `directionalIcon`، `directionalValue`، `context.ui.dir` | دعم العربية والإنجليزية بكود واحد | شروط `Directionality` يدوية |
| تغيير الثيم | داخل `core/.../theme/` فقط (`AppTheme`، `light_theme`، `dark_theme`)، والاختيار عبر `ThemeCubit` | الثيم لا يعتمد على Responsive ولا على Features | تلوين محلي لتجاوز الثيم |

**Core Widget أم Flutter Widget؟** Core Widget عندما يغطي الحاجة. Flutter Widget مباشرة للتخطيط الهيكلي (`Row`، `Column`، `Stack`، `Expanded`، `Padding`، `Scaffold`، `ListView`...) ولما ليس له مقابل، **بشرط** أن تأتي قيمه من `context.ui` والثيم.

---

## 2. الترجمة واللغة

| الحاجة | الإلزامي | لماذا | الممنوع |
|---|---|---|---|
| نص مترجم | `AppKeys` + `AppKey` (`AppText(key)`؛ `.tran` عند الحاجة لـ `String`؛ `.tr(namedArgs:)` مع متغيرات) | مفاتيح مضبوطة بالنوع، ومنع الأخطاء الإملائية، والترجمة وقت العرض | `'text'.tr()`، نص ثابت في الواجهة، قاموس خاص بميزة |
| إضافة مفتاح | تعريفه في `app_keys.dart` + نصه في `app_ar.dart` و`app_en.dart` (سلسلة فريدة لكل مفتاح) | اكتمال اللغتين | مفتاح بلا نص في إحدى اللغتين، أو سلسلة مكررة لمعنى مختلف |
| تغيير اللغة | `LocaleCubit` / `AppLanguage` / `AppSettingsManager` | مصدر واحد، و`LanguageInterceptor` يرسلها للخادم | `locale provider` مستقل |

---

## 3. الحالة والأحداث

| الحاجة | الإلزامي | لماذا | الممنوع |
|---|---|---|---|
| Cubit | `BaseCubit<State, Effect>` | يغلق موارد الـ Effects تلقائياً | `Cubit` مباشر في الميزات |
| حدث أحادي (رسالة/تنقل) | `emitEffect(effect, replayable:)` + `BlocEffectListener` | الأحداث لا تتكرر عند إعادة بناء الواجهة | رسالة داخل State، أو `ScaffoldMessenger` من الـ Cubit |
| State | `freezed` sealed class | حالات مغلقة وكاملة (switch شامل) | `bool isLoading` متناثرة |
| إغلاق | `close()` يلغي الاشتراكات و`cancelRequests()` | لا تسريب ولا `emit` بعد الإغلاق | نسيان الإلغاء |

---

## 4. الشبكة والأخطاء

| الحاجة | الإلزامي | لماذا | الممنوع |
|---|---|---|---|
| طلب HTTP | `IApiClient` (مُحقن من GetIt) | Interceptors موحدة: Auth، RefreshToken، Connectivity، Language، Retry، Logger | `Dio()` جديد، Interceptor مكرر |
| مسار API | `AppEndpoints` + `AppEndpoint` | ترميز المقاطع الديناميكية ورفض `.` و`..` | مسارات نصية حرفية |
| ترقيم القوائم | `getPaginated`/`postPaginated` + `PaginatedResult`/`PaginatedParser` | تحليل موحد للصفحات | ترقيم خاص بكل ميزة |
| نتيجة الطبقة | `ApiResult<T>` (`ApiSuccess`/`ApiFailure`) | لا استثناءات متدفقة | رمي استثناءات الشبكة |
| التحويل إلى Domain | `result.toEither()` / `toEitherAsync()` | **الجسر الوحيد** من `ApiResult` إلى `Either<Failure, T>` | `try/catch` يدوي حول كل استدعاء |
| تحويل الأخطاء | `ExceptionMapper.map` (`AppException` → `Failure`)، `ServerErrorMapper` (رسالة الخادم/الحالة → `AppKey`) | رسائل أخطاء موحدة ومترجمة | `Failure` بنص خام، ترجمة داخل Repository |
| عرض الخطأ | `failure.messageKey` إلى `AppText`/`MessageViewWidgets` | يتبع اللغة وقت العرض | `FailureTranslator.translate` إلا حيث يلزم `String` جاهز |
| إلغاء الطلبات | `CancellableMixin` (`cancelToken`، `cancelRequests()`) مع تمرير `CancelToken` عبر الطبقات | لا نتائج متأخرة بعد إغلاق الشاشة | تجاهل الإلغاء في البحث والقوائم |
| إعادة المحاولة | تلقائية لـ GET/HEAD/OPTIONS فقط | الكتابة قد تتكرر آثارها | `idempotent: true` على عملية مالية دون ضمان من الخادم |
| حالة الاتصال | `NetworkInfo` | لا يثبت وحده الوصول للخادم، ويُستخدم كمؤشر | افتراض أن Wi-Fi يعني وصولاً للخادم |

أنواع `Failure` الجاهزة: `ValidationFailure`، `NetworkFailure`، `CacheFailure`، `ServerFailure`، `GoogleSignInFailure`، `PermissionFailure`، `UnexpectedFailure`، `UnauthorizedFailure`، `NotFoundFailure`. أضف نوعاً جديداً فقط لفئة خطأ جديدة فعلاً (مع حالة في `ExceptionMapper`)، وإلا استخدم الموجود.

لخطأ خادم جديد برسالة خاصة: أضف مفتاحه في `AppKeys.server` وتحويله في `ServerErrorMapper`، لا استثناءً محلياً.

---

## 5. الإعدادات والتحقق والسجل

| الحاجة | الإلزامي | لماذا | الممنوع |
|---|---|---|---|
| إعداد/ثابت عام | `AppConfig` (مهلات، إعادة المحاولة، `defaultPageSize`، لغات...) | مدخل واحد | استيراد `EnvConfig` في ميزة، ثوابت مكررة |
| قيمة بيئة | `--dart-define-from-file`، و`AppConfig` يمررها | لا أسرار في المستودع | `service_role` أو أي سر خادم في التطبيق |
| تحقق حقول النماذج | `AppValidator.validate(value, [ValidationRule...], params:, customKeys:)` | رسائل `AppKey` موحدة | validator موازٍ أو regex داخل الواجهة |
| قواعد أعمال/محاسبة | UseCase/Entity في `domain` | `AppValidator` للحقول العامة فقط | وضعها في `AppValidator` |
| سجل | `Logger` (مثل `Logger.error(msg, error:, stackTrace:, name:)`) | مدخل سجل واحد قابل للتحكم (وسجل الشبكة يخفي الحقول الحساسة، راجع `logger_redaction_test`) | `print`، تسجيل توكنات أو كلمات مرور أو بيانات مالية |

---

## 6. التخزين

| ما تخزّنه | الإلزامي | الممنوع |
|---|---|---|
| إعداد بسيط | `PrefsStorageService` / `AppSettingsManager` | تخزين توكن هنا |
| توكن/سر | `SecureStorageService` / `TokenManager` | SharedPreferences |
| كائنات/كاش | `HiveStorageService` / `HiveObjectBox<T>` / `CacheManager`؛ الصناديق `HiveBoxNames`، الأنواع `HiveBoxTypeId` | `typeId` رقمي حرفي خارج `HiveBoxTypeId` |
| مفاتيح التخزين | `StorageKey` / `StorageKeys` | مفاتيح نصية متفرقة |

---

## 7. التنقل والصلاحيات

| الحاجة | الإلزامي | لماذا | الممنوع |
|---|---|---|---|
| تعريف مسار | `AppRoutes` + `AppRoutes.all` + تصنيف في `route_guards.dart` | deny by default، وفشل الاختبار إن نقص تصنيف | مسار غير مصنَّف |
| بناء وجهة | `GoRoute` داخل `AppRouter` مع `RouteTransitions` | تحويلات موحدة | `Navigator.push`، transitions خاصة |
| تنقل من الكود | `context.go(AppRoutes.x.path)` / `goNamed` | مسارات مركزية | مسار نصي حرفي |
| صلاحية عنصر واجهة | `PermissionGate` / `context.can(...)` (داخل `build` فقط) | يعيد البناء عند تغيّر الدور | فحص دور يدوي |
| صلاحية مسار | `AccessRoutingLogic.require(Permission)` كـ `redirect` | حارس موحد، والراوتر يعيد التقييم عند تغيّر الدور | حلقة توجيه (الـ fallback لا يتطلب نفس الصلاحية) |
| صلاحية في Use Case | `accessCubit.require(Permissions.x.y)` يعيد `Either` | فحص مبكر | الاكتفاء به كحماية |
| صلاحية جديدة | سطر في `Permissions` (وأدوار `SystemRoles` إن لزم) | تسمية موحدة `module.action` | نصوص صلاحيات حرفية |

> **حد أمني ثابت:** الصلاحيات في التطبيق تحسّن تجربة المستخدم والفحص المبكر فقط. التفويض الحقيقي في الخادم وRLS.

---

## 8. DI وأنواع الأساس

| الحاجة | الإلزامي | الممنوع |
|---|---|---|
| تسجيل خدمة عامة (Storage، Network، Theme، Locale، Access) | `initCoreDI()` | تسجيل خدمة ميزة هنا |
| تسجيل خدمة/كائن ميزة | `initXDI()` داخل `features/<x>/di/` ثم استدعاؤه من `app_di.dart` | `GetIt` ثانٍ أو تسجيل مكرر |
| عقد UseCase | `UseCase<Type, Params>`، `NoParams` | بدائل خاصة |
| نتيجة المجال | `Either<Failure, T>` من `dartz`، و`Unit` لعمليات بلا قيمة | استثناءات من Domain |

---

## 9. ما **ليس** في Core بعد (قرارات مطلوبة قبل بناء ميزاتها)

هذه حاجات يحتاجها نظام محاسبي، ولم أجد لها أداة موثقة في `CORE_MAP.md`. **لا ترتجلها داخل ميزة:** قرّر مكانها أولاً.

| الحاجة | الحالة | ملاحظة |
|---|---|---|
| نوع المبلغ المالي (`Money`) | غير موجود (لا حزمة decimal في `pubspec.yaml`) | `AGENTS.md` §8 يمنع `double`. تعريفه في Core مبرَّر بوجود عدة مستهلكين (مبيعات، مشتريات، مدفوعات، قيود) |
| تنسيق الأرقام والعملات | غير موثق | يحتاج مكاناً واحداً يحترم اللغة والعملة |
| تصدير/طباعة (PDF، باركود) | غير موثق | عزلها خلف واجهات لاختلاف المنصات (`AGENTS.md` §9) |
| مزامنة محلي/بعيد وOutbox | غير موثق | `AGENTS.md` §7 يصفها كمتطلب، ولا تنفيذ في Core |
| Realtime | عقد مجرد فقط | لا تفترض أنه يعمل |
| ترقيم تلقائي للمستندات (مثل أرقام الفواتير) | غير موثق | يجب أن يتم في الخادم لمنع التكرار |

عند حسم أي منها: أضف الأداة إلى Core وفق `ARCHITECTURE_RULES.md` §2، ثم حدّث `CORE_MAP.md` وهذا الجدول.

---

## 10. استثناء من العقد

يجوز الخروج عن أداة Core فقط عندما:
1. تثبت أنها لا تغطي الحاجة بعد فحص توقيعها وخياراتها.
2. يصعب توسيعها دون كسر مستخدميها.
3. يُدوَّن السبب في وصف الـ PR وفي `CORE_MAP.md`.

بخلاف ذلك: طوّر الأداة الموجودة بدل إنشاء بديل.