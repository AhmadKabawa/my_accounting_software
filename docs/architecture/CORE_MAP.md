# خريطة Core — مرجع إعادة الاستخدام

> **المسار:** `lib/app/core/`.
> هذه خريطة توجيه وليست بديلاً عن قراءة التنفيذ. الكود هو المرجع؛ عند أي اختلاف بين الخريطة والكود يُعتمد الكود ثم تُصحَّح الخريطة.
> القيم المتغيرة (Breakpoints، المهلات، عدد المحاولات، أسماء الإعدادات) لا تُنسخ هنا: افتح الملف المسؤول عنها.

## الغرض

يحتوي Core على البنية التحتية المشتركة، وأنظمة العرض والتصميم، والأدوات العامة التي تعتمد عليها الميزات. قبل إنشاء أي Helper أو Service أو Widget أو Theme أو Responsive logic جديد، ابحث هنا أولاً. قرار إضافة شيء إلى Core تحكمه `ARCHITECTURE_RULES.md`.

## 1. خريطة المجلدات

| المجلد | المسؤولية | نقطة البداية |
|---|---|---|
| `access/` | الدور الحالي والصلاحيات وفحص إظهار عناصر الواجهة | `access/cubit/access_cubit.dart` |
| `di/` | تسجيل خدمات Core في GetIt | `di/service_locator.dart` |
| `error/` | الاستثناءات الداخلية، Failure، التحويل والترجمة | `error/mappers/exception_mapper.dart` |
| `foundation/` | أنواع ونتائج مشتركة، إعدادات، Logger، UseCases، التحقق، ثوابت الصور | `foundation/types/api_result.dart` |
| `localization/` | اللغة الحالية، مفاتيح الترجمة، تحميل الترجمات واتجاه النص | `localization/cubit/locale_cubit.dart` |
| `network/` | Dio وواجهته، Interceptors، الاتصال، الإلغاء، عقد Realtime | `network/api_client_interface.dart` |
| `presentation/design_system/responsive/` | القياس والـ Tokens وواجهات Responsive | `responsive/extension/ui_extension.dart` |
| `presentation/design_system/theme/` | Light/Dark Theme والألوان والطباعة وThemeCubit | `theme/app_theme.dart` |
| `presentation/state_management/` | BaseCubit وEffects وBlocObserver | `state_management/base_cubit.dart` |
| `presentation/widgets/` | Widgets موحدة مشتركة | ملفات `app_*` |
| `routing/` | تعريفات المسارات، transitions، observer ومساعدات GoRouter | `routing/routes.dart` |
| `storage/` | عقد التخزين وتطبيقات SharedPreferences وSecure وHive | `storage/storage_service.dart` |

## 2. تفاصيل الأدوات الموجودة

### Access
- `AccessCubit` (`access/cubit/access_cubit.dart`): المصدر الوحيد للدور الحالي. يدعم `setRole` و`clear` و`can` و`canAny` و`canAll` و`require` (تعيد `Right(unit)` أو `Left(PermissionFailure)`). مسجّل Singleton في `initCoreDI()`.
- `AccessState` (`access/cubit/access_state.dart`): حالة تحمل `Role role` فقط. ملف `part of 'access_cubit.dart'`؛ لا يُنقل منفرداً.
- `AccessContextX` (`access/extensions/access_extension.dart`): امتداد على `BuildContext` يوفر `context.can(Permission)`. يستخدم `select` فيعيد البناء عند تغيّر الدور، لذا يُستدعى داخل `build` فقط. لا يوجد له استخدام فعلي في `lib` خارج Core حالياً.
- `Permission` و`PermissionAction` (`access/permission.dart`): `Permission` هو extension type على String بصيغة `module.action`، يدعم `*` و`module.*` عبر `covers`. `PermissionAction` enum بالإجراءات القياسية (view, create, edit, delete, post, reverse, approve, export). الإنشاء عبر `Permission.of(module, action)` أو `Permission.module(module)`.
- `Permissions` و`Role`: تعريفات الصلاحيات الجاهزة والأدوار (`Role.none` قبل الدخول وبعد الخروج؛ `allows/allowsAny/allowsAll`).
- `PermissionGate`: يعرض `child` إن توفرت الصلاحية وإلا `fallback`.
- **حد أمني:** هذه الطبقة لتحسين تجربة المستخدم والفحص المبكر فقط. التفويض الحقيقي يفرضه الخادم وRLS.

### Dependency Injection
- `sl` هو `GetIt.instance` (`di/service_locator.dart`).
- `initCoreDI()` يسجل خدمات Core فقط.
- `lib/app/app_di.dart` هو منسق التهيئة (Composition Root): يستدعي Core ثم DI كل Feature بالترتيب الموثق فيه. لا تضف نقطة Service Locator ثانية.
- DI الخاص بكل Feature داخل `features/<feature>/di/`. افحص عمر كل Cubit/Service وطريقة تسجيله قبل اختيار Singleton أو Factory.

### Error handling
- `AppException` و`ApiException`: تمثيل أخطاء طبقة البيانات والشبكة.
- `Failure` (`error/failures/failure.dart`): عقد الخطأ الذي يصل إلى Domain/Presentation، ويحمل `messageKey` من نوع `AppKey` و`statusCode` اختيارياً.
- `ExceptionMapper.map` (`error/mappers/exception_mapper.dart`): يحوّل `AppException` إلى `Failure`. مستخدم في Repositories (مثل `AuthRepositoryImpl`).
- `ServerErrorMapper.map`: يحوّل رسائل الخادم أو Status Code إلى `AppKey`.
- `FailureTranslator.translate(Failure)` (`error/translators/failure_translator.dart`): أداة مستقلة عن `ExceptionMapper`؛ تحوّل `Failure` إلى نص مترجم للعرض عبر `failure.messageKey.tran`. مستخدمة فعلياً في `AuthCubit` عند بناء رسالة الخطأ لـ Effect. الترتيب: `ExceptionMapper` (Exception → Failure) ثم `FailureTranslator` (Failure → نص). لا تترجم داخل Repository.

### Foundation
- `ApiResult<T>`: نتيجة طبقة البيانات (`ApiSuccess` و`ApiFailure`) مع `toEither()` و`toEitherAsync()`.
- `PaginatedResult` و`PaginatedParser`: نتائج وتحليل الصفحات.
- `EnvConfig`: يقرأ القيم عبر `String.fromEnvironment` ويتوقع `--dart-define-from-file`؛ المثال في `config/dart_defines.example.json`. لا تضع أسرار الخادم أو service_role في التطبيق.
- `AppConfig`: إعدادات عامة (مهلات، إعادة المحاولة، لغات، صيغ تواريخ…). افحصه قبل إضافة ثوابت جديدة ولا تنسخ قيمه إلى التوثيق.
- `Logger`: سجل موحد؛ لا تسجل Tokens أو كلمات مرور أو بيانات مالية حساسة.
- `UseCase` و`UseCaseNoParams`: عقود Use Cases.
- `AppValidator` و`ValidationRule` (`foundation/validation/form_validator.dart`): تحقق ديناميكي للنماذج. `AppValidator.validate(value, rules, {params, customKeys})` يعيد نصاً مترجماً أو `null`. لا يوجد له مستهلك فعلي نشط حالياً (الاستخدامات الموجودة في الميزات معلّقة).
- `AppPathImage` و`AppPathImages` (`foundation/constants/image_constants.dart`): ثوابت مسارات الصور والأصول (`AppPathImage` يحمل المسار وعلامة `isRtl`).

### Localization
- `LocaleCubit` و`LocaleState`: حالة اللغة (الحالة تحمل `Locale` فقط).
- `AppLanguage`: اللغات المدعومة وتحويل الكود إلى Locale.
- `AppKey` و`AppKeys`: مفاتيح الترجمة المنظمة (`AppKey.tran` للترجمة المباشرة). ملفا `app_ar.dart` و`app_en.dart` يحويان النصوص.
- `MyDartLoader` (`translations/asset_loader.dart`): `AssetLoader` لـ easy_localization يحمّل الترجمات من ملفات Dart لا من JSON. مستخدم في `main.dart`.
- `DirectionExtension` (`translations/localization_extension.dart`): امتداد على `BuildContext` لاتجاه النص: `isRTL` و`directionalIcon` و`directionalValue` و`transformFlip`.
- لا تنشئ قاموس ترجمة موازياً.

### Network
- `IApiClient`: واجهة طلبات GET/POST/PUT/PATCH/DELETE/Upload والـ Pagination. المسارات من نوع `AppEndpoint`.
- `ApiClient`: التنفيذ عبر Dio وتحويل الاستجابة إلى `ApiResult`.
- `DioService`: إنشاء Dio وإضافة Interceptors.
- Interceptors (`network/dio/interceptors/`): Auth وConnectivity وLanguage وLogger وRefreshToken وRetry.
- `AppEndpoint` و`AppEndpoints` (`network/api_end_points.dart`): تعريف مسارات API؛ المقاطع الديناميكية تُرمَّز وتُرفض `.` و`..`.
- `NetworkInfo` و`NetworkInfoImpl`: معرفة الاتصال. لا يثبت وحده الوصول إلى الخادم.
- `CancellableMixin` و`CancelTokenRegistry`: إلغاء الطلبات المرتبطة بعمر Cubit/Controller.
- لا تنشئ Dio داخل Feature ولا تكرر Interceptors.

#### RetryInterceptor (`network/dio/interceptors/retry_interceptor.dart`)
- **إعادة تلقائية** لطلبات `GET` و`HEAD` و`OPTIONS` فقط.
- **عمليات الكتابة** (POST/PUT/PATCH/DELETE) لا تُعاد تلقائياً، لأن انتهاء المهلة لا يثبت أن الخادم لم ينفذها.
- يمكن السماح لعملية كتابة بالإعادة عبر `Options(extra: {'idempotent': true})`.
- **تحذير مالي:** لا تفعّل `idempotent` لعملية مالية إلا إذا كان الخادم يضمن idempotency حقيقياً (مثل مفتاح idempotency يمنع التنفيذ مرتين). غير ذلك قد تتكرر العملية.
- **الأخطاء التي تؤدي إلى Retry:** `connectionTimeout` و`receiveTimeout` و`connectionError`، واستجابات بحالة 5xx أو أعلى. أخطاء 4xx وغيرها لا تُعاد.
- **الحد الأقصى والتأخير:** من `AppConfig.maxRetries` و`AppConfig.retryDelay`. التأخير خطي: `baseDelay × (رقم المحاولة)`. عدّاد المحاولات في `options.extra['retryCount']`.

#### Realtime — لا يوجد تنفيذ فعّال
- `RealtimeClient` (`network/realtime/realtime_client.dart`) **عقد مجرد فقط** (`connect/disconnect/on/off/emit/statusStream/onTableChange/offTable` وenum `RealtimeStatus`). ليس خدمة جاهزة.
- لا يوجد تنفيذ Realtime فعّال موصول أو مستخدم: لا تنفيذ للعقد، ولا تسجيل في DI، ولا مستهلك في `lib` أو `test`.
- تم حذف `supabase_realtime_client.dart` لأنه كان معطلاً بالكامل بالتعليقات.
- عند الحاجة إلى Realtime يلزم تنفيذ جديد وتسجيله في DI وإضافة اختباراته؛ لا تفترض أنه متوفر.

### Responsive وDesign System
- `ScreenEngine`: مصدر واحد لتحديد نوع الشاشة والأبعاد وحدود الشاشات (Breakpoints). افتحه لمعرفة القيم الحالية ولا تنسخها.
- `ScaleEngine`: حساب القياس والاستيفاء بين tokens وقياس الخط مع TextScaler.
- `ResponsiveMode`: أنماط القياس (`fixed` و`scaleOnly` و`adaptiveOnly` و`adaptiveScale`).
- Tokens/enums: `AppSpacing` و`AppRadius` و`AppFontSize` و`AppIconSize` و`AppElevation` و`AppComponentSize` و`AppAspectRatio` و`AppBaseWidth` و`ResponsiveToken` و`ScreenType` و`AppOrientation`.
- `Rh` (اسم مستعار لـ `ResponsiveHelper` في `responsive_helper.dart`): API ساكنة للقياس واختيار الـ builders.
- `ResponsiveContextExtension` (`helper/responsive_helper/responsive_context_extension.dart`): اختصارات على `BuildContext` تغلّف `Rh`: `context.spacing()` و`fontSize()` و`icon()` و`componentSize()` و`elevation()` و`pad()` وغيرها. (`componentSize` لا `size` لأن `BuildContext.size` يحجب الامتداد.) جزء `part of 'responsive_helper.dart'`.
- `context.ui` من `UIContextExtension`: مدخل موحد إلى `padding` و`size` و`text` و`spacing` و`radius` و`icon` و`shadow` و`grid` و`screen` و`theme` و`dir`.
- `AppTextStyleResolver` (`extension/ui_extension/app_text_style_resolver.dart`): امتداد على `AppTextStyle` بدالة `resolve(context, {mode, respectTextScaler})` تعيد `TextStyle` متجاوباً عبر `Rh.textStyle`. يستخدمه `AppText`. موضعه هنا لأن الثيم لا يجوز أن يعتمد على محرك Responsive (الثيم يستخدم `AppTextStyle.baseline` فقط). `part of 'ui_extension.dart'`.
- `Gap` (`engine/app_gap.dart`): Widget مسافة يحدد محوره تلقائياً من أقرب `Flex` أب (عمودي افتراضياً)، ويدعم `axis` و`Gap.expand()`. يُنتج بحجم متجاوب عبر `context.ui.spacing.gap(AppSpacing.md)` أو `Rh.gapSpace`.
- `context.ui.grid.widget` يختار بناءً على نوع الجهاز. `context.ui.grid.adaptive` يختار بناءً على المساحة الفعلية للعنصر (`AdaptiveLayout`) لا عرض الشاشة.
- `AdaptiveLayout`: لتخطيطات المحتوى داخل panes أو sidebars.
- مجموعات `part/part of`: `app_enums.dart` و`ui_extension.dart` و`responsive_helper.dart` وملفاتها التابعة. اقرأ المجموعة معاً ولا تفصل أو تنقل ملفاً منها (راجع `ARCHITECTURE_RULES.md`).

### Theme
- `AppTheme.light()` و`AppTheme.dark()`: إنشاء ThemeData دون BuildContext.
- `buildTheme`: تجميع ColorScheme وTextTheme وثيمات مكونات Material (`theme/components/`).
- `light_theme.dart` و`dark_theme.dart`: ثيمات الوضعين.
- `AppColors` و`AppTextStyles`: ألوان وأنماط نصية مركزية.
- `ThemeCubit` و`ThemeState`: اختيار light/dark/system وحفظه عبر `AppSettingsManager`.
- `theme_extension.dart`: يحوي `ThemeModeExtension` على `ThemeMode` (`icon` و`nameAr` و`nameEn`) و`ThemeExtension` على `BuildContext` (`isDark` و`isLight` و`themeColor` و`themeValue` و`themeValueOrNull` و`colors` و`textTheme`). ليس `ThemeExtension<T>` الخاص بـ Flutter.

### State management
- `BaseCubit<State, Effect>`: Cubit مع `EffectMixin` ويغلق موارد Effects عند `close`.
- `EffectMixin` و`HasEffects`: Stream لأحداث أحادية الاستخدام، مع replay اختياري ومحدود زمنياً (`emitEffect(effect, {replayable})`).
- `BlocEffectListener`: الاستماع إلى Effects في الواجهة.
- `AppBlocObserver`: مراقبة Bloc/Cubit.

### Shared widgets
- `AppText`: نص مترجم عبر `AppKey` أو `AppText.raw`، ويدعم `rich` و`selectable`.
- `AppButton`: زر موحد، بـ `AppKey` أو `AppButton.raw`، مع variants/sizes/loading. التصميم في `AppButtonStyle`.
- `AppIcon` و`AppImage`: عرض الأيقونات والصور؛ اقرأ الـ API قبل إعادة التنفيذ.
- `AppAppBar` (`widgets/app_appbar/app_appbar.dart`): AppBar مشترك يأخذ `progress`. مستخدم في `home_screen.dart`.
- `AppNavigationBar` و`AppNavigationRail` و`AppSidebar` وأنماطها: عناصر التنقل حسب حجم الشاشة.
- `MessageViewWidgets`: مكونات رسائل/حالات العرض المشتركة.

### Routing
- Core يوفر `AppRoutes` و`RouteItem` و`RouteTransitions` و`GoRouterRefreshStream` و`MyNavObserver` (`routing/app_router_observer.dart`، يسجل أحداث التنقل عبر `debugPrint`، ومستخدم في `AppGoRouter`).
- تكوين GoRouter والحراس موجودان خارج Core في `lib/app/routing/app_go_router.dart` و`route_guards.dart`.

### Storage
- `StorageService`: العقد العام read/write/delete/clearAll/containsKey.
- `PrefsStorageService`: SharedPreferences. `SecureStorageService`: التخزين الآمن.
- `TokenManager`: إدارة tokens وإشعار `sessionCleared` عند إزالة الجلسة.
- `AppSettingsManager`: Theme وLanguage وOnboarding.
- `HiveManager` و`HiveStorageService` و`HiveObjectBox` و`CacheManager`: Hive/cache. `HiveManager.init()` تُستدعى من `main.dart`؛ الميزات تفتح صناديقها عبر `HiveManager.openBox` (مثل `auth_di.dart`). لا يُسجَّل Hive في `initCoreDI()` بل في DI الميزة.
- `HiveBoxNames` (`storage/hive/hive_box_names.dart`): أسماء الصناديق (`cache` و`users` و`products`). `HiveBoxTypeId`: معرّفات `typeId` للـ adapters، وحالياً `user` فقط. يُستخدم في `@HiveType(typeId: HiveBoxTypeId.user)` لـ `UserModel`. أي typeId جديد يُعرّف هنا لتجنب التضارب.
- `StorageKey` و`StorageKeys`: مفاتيح التخزين المركزية.
- اختر التخزين حسب الحساسية، ولا تحفظ Tokens في SharedPreferences.

## 3. تغطية الاختبارات (`test/core/`)

الجدول من فحص ملفات الاختبار فعلياً. غياب اختبار مباشر لا يعني غياب أي تغطية غير مباشرة، لكن لم يُتحقق منها ما لم يُذكر.

| المجال | الاختبارات الموجودة | ما تغطيه |
|---|---|---|
| Access | `access_cubit_test` و`permission_gate_test` و`permission_test` | حالة الدور، `can/canAny/canAll/require`، `PermissionGate`، `Permission.covers` و`Role` |
| DI | `di_singletons_test` | أن `TokenManager` Singleton فقط |
| Foundation | `env_config_test` و`api_result_either_test` | التحقق من `EnvConfig`، و`ApiResult.toEither/toEitherAsync` |
| Network | `api_client_test` و`app_endpoints_test` و`language_interceptor_test` و`logger_redaction_test` و`network_info_test` و`refresh_token_interceptor_test` و`retry_interceptor_test` | تحليل الاستجابات، ترميز المسارات، Accept-Language، إخفاء الحقول الحساسة، `NetworkInfo`، تجديد الجلسة، سلوك Retry |
| Responsive | `adaptive_layout_test` و`rh_builder_test` و`responsive_helper_equivalence_test` | اختيار التخطيط، `Rh.builder`، تكافؤ padding/radius |
| Theme | `app_theme_test` | بناء الثيم دون `BuildContext` والـ baseline |
| State management | `base_cubit_test` و`effect_mixin_test` | Effects والـ replay |
| Widgets | `app_button_style_test` و`app_navigation_bar_style_test` و`app_navigation_rail_style_test` و`app_sidebar_style_test` و`app_text_test` | أنماط وسلوك الأزرار والتنقل والنص |
| Storage | `token_manager_test` | `TokenManager` فقط (الكتابة، التراجع، `sessionCleared`) |

### الفجوات المسجلة
- **Error:** لا يوجد اختبار مباشر لـ `ExceptionMapper` أو `FailureTranslator`. (اختبارات Auth تستخدم أنواع `Failure` لكنها لا تختبر المحولين نفسيهما.)
- **Localization:** لا يوجد اختبار مباشر لـ `LocaleCubit`. يُستخدم داخل `language_interceptor_test` لتأكيد أن تغيير اللغة يصل إلى الطلب التالي، وهي تغطية غير مباشرة محدودة.
- **Foundation:** لا يوجد اختبار مباشر لـ `AppValidator`.
- **Routing:** لا يوجد مجلد `test/core/routing`. حراس المسارات الفعلية (خارج Core) مغطاة في `test/routing/route_guards_test.dart`، ولا يغطي ذلك `AppRoutes` أو `RouteTransitions` أو `MyNavObserver`.
- **Storage:** لا يوجد اختبار شامل؛ لا اختبار مباشر لـ Hive (`HiveManager` و`HiveStorageService` و`HiveObjectBox` و`CacheManager`) أو `PrefsStorageService` أو `SecureStorageService` أو `AppSettingsManager`.
- **أخرى بلا ملف اختبار مباشر:** `AuthInterceptor` و`ConnectivityInterceptor` و`CancelTokenRegistry` و`AppIcon` و`AppImage` و`AppAppBar` و`MessageViewWidgets` و`BlocEffectListener` و`AppBlocObserver` و`ThemeCubit`.

## 4. ملاحظات وحدود هذه الخريطة

- افحص الكود الحالي دائماً؛ قد تتغير الملفات أو APIs.
- لا تعني الإشارة إلى أداة أنها مناسبة لكل استعمال؛ تحقق من حدودها وتوقيعها وطبقتها.
- وجود API في Core لا يعني نقل منطق Feature إليه.
- لا تدّعِ نجاح `flutter analyze/test` إلا بعد تشغيلهما فعلياً في بيئة فيها Flutter SDK.
- الفرض الآلي للقواعد المعمارية غير موجود حالياً (راجع `ARCHITECTURE_RULES.md`).
