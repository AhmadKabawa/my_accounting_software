# خريطة Core — مرجع إعادة الاستخدام

> **لقطة المصدر:** الفرع `claude/adaptive-shell`، عند commit `a59584b94d2056856376549e665421b7c51b0817`.
> **المسار:** `lib/app/core/`.
> **النطاق:** تم حصر 137 ملف Dart في Core في هذه اللقطة، وفحص الملفات المحورية المذكورة أدناه. هذه خريطة توجيه وليست بديلاً عن قراءة التنفيذ الحالي قبل التعديل.

## الغرض

يحتوي Core على البنية التحتية المشتركة، وأنظمة العرض والتصميم، والأدوات العامة التي تعتمد عليها الميزات. قبل إنشاء أي Helper أو Service أو Widget أو Theme أو Responsive logic جديد، ابحث هنا أولاً.

## 1. خريطة المجلدات

| المجلد | المسؤولية | نقطة البداية |
|---|---|---|
| `access/` | الدور الحالي والصلاحيات وفحص إظهار عناصر الواجهة | `access/cubit/access_cubit.dart` |
| `di/` | تسجيل خدمات Core في GetIt | `di/service_locator.dart` |
| `error/` | الاستثناءات الداخلية، Failure، وتحويل الأخطاء | `error/mappers/exception_mapper.dart` |
| `foundation/` | أنواع ونتائج مشتركة، إعدادات، Logger، UseCases والتحقق | `foundation/types/api_result.dart` |
| `localization/` | اللغة الحالية، مفاتيح الترجمة، تحميل الأصول واتجاه النص | `localization/cubit/locale_cubit.dart` |
| `network/` | Dio وواجهته، Interceptors، الاتصال، الإلغاء وRealtime | `network/api_client_interface.dart` |
| `presentation/design_system/responsive/` | Breakpoints وTokens والقياس وواجهات Responsive | `responsive/extension/ui_extension.dart` |
| `presentation/design_system/theme/` | Light/Dark Theme والألوان والطباعة وThemeCubit | `theme/app_theme.dart` |
| `presentation/state_management/` | BaseCubit وEffects وBlocObserver | `state_management/base_cubit.dart` |
| `presentation/widgets/` | Widgets موحدة مشتركة للتطبيق | ملفات `app_*` |
| `routing/` | Route definitions، transitions، observers ومساعدات GoRouter | `routing/routes.dart` |
| `storage/` | Storage abstraction وتطبيقات SharedPreferences وSecure Storage وHive | `storage/storage_service.dart` |

## 2. تفاصيل الأدوات الموجودة

### Access
- `AccessCubit`: مصدر حالة الدور الحالي، ويدعم `setRole` و`clear` و`can` و`canAny` و`canAll` و`require`.
- `PermissionGate`: إظهار أو إخفاء Widget بحسب Permission.
- `Permission` و`Permissions` و`Role`: تعريفات الصلاحيات والأدوار.
- **حد أمني:** هذه الطبقة لتحسين تجربة المستخدم والفحص المبكر فقط. التفويض الحقيقي يجب أن يفرضه الخادم وRLS.

### Dependency Injection
- `sl` هو `GetIt.instance`.
- `initCoreDI()` يسجل خدمات Core فقط.
- `lib/app/app_di.dart` هو Composition Root ويستدعي Core ثم تسجيل الميزات. لا تضف نقطة Service Locator ثانية.
- افحص عمر كل Cubit/Service وطريقة تسجيله قبل اختيار Singleton أو Factory.

### Error handling وFoundation
- `AppException` و`ApiException`: تمثيل أخطاء طبقة البيانات والشبكة.
- `Failure`: عقد الخطأ الذي يصل إلى Domain/Presentation، مع أنواع مثل NetworkFailure وServerFailure وValidationFailure وUnauthorizedFailure وغيرها.
- `ExceptionMapper.map`: يحول AppException إلى Failure.
- `ServerErrorMapper.map`: يحول رسائل الخادم أو Status Code إلى AppKey.
- `ApiResult<T>`: نتيجة طبقة البيانات، وتدعم `ApiSuccess` و`ApiFailure` وامتداد `toEither()` و`toEitherAsync()`.
- `PaginatedResult` و`PaginatedParser`: نتائج وتحليل الصفحات.
- `EnvConfig`: يقرأ القيم عبر `String.fromEnvironment` ويتوقع `--dart-define-from-file=config/dart_defines.json`. لا تضع أسرار الخادم أو service_role في تطبيق العميل.
- `AppConfig`: إعدادات عامة حالية؛ افحصها قبل إضافة ثوابت جديدة.
- `Logger`: سجل موحد؛ لا تسجل Tokens أو كلمات مرور أو بيانات مالية حساسة.
- `UseCase` و`UseCaseNoParams` و`FormValidator` و`ImageConstants`: أدوات Foundation إضافية.

### Localization
- `LocaleCubit` و`LocaleState`: حالة اللغة.
- `AppLanguage`: اللغات المدعومة (حالياً ar/en) وتحويل الكود إلى Locale.
- `AppKey` و`AppKeys`: مفاتيح الترجمة المنظمة.
- `AssetLoader`: تحميل ملفات الترجمة.
- `LocalizationExtension`: اتجاه RTL/LTR وقيم وأيقونات الاتجاه.
- استخدم مفاتيح AppKey وAppText حيث يلائم نمط الواجهة؛ لا تنشئ قاموس ترجمة موازياً.

### Network
- `IApiClient`: واجهة طلبات GET/POST/PUT/PATCH/DELETE/Upload وطلبات Pagination.
- `ApiClient`: التنفيذ عبر Dio، وتحويل الاستجابة إلى ApiResult.
- `DioService`: إنشاء Dio وإضافة Interceptors.
- Interceptors الحالية: Auth وConnectivity وLanguage وLogger وRefreshToken وRetry.
- `AppEndpoint` و`AppEndpoints`: تعريف مسارات API، بما فيها مسارات Auth وProducts الحالية.
- `NetworkInfo`: واجهة معرفة الاتصال، و`NetworkInfoImpl`: التنفيذ.
- `CancellableMixin` و`CancelTokenRegistry`: إلغاء طلبات Dio المرتبطة بعمر Cubit/Controller.
- `RealtimeClient` و`SupabaseRealtimeClient`: تجريد وتنفيذ Realtime.
- لا تنشئ Dio جديداً داخل Feature ولا تكرر Interceptors. لا تفترض أن فحص connectivity وحده يثبت الوصول إلى الخادم.

### Responsive وDesign System
- `ScreenEngine`: مصدر واحد لتحديد نوع الشاشة والأبعاد. Breakpoints الحالية: mobile أقل من 600، tablet من 600 إلى أقل من 1200، desktop من 1200 فما فوق.
- `ScaleEngine`: حساب القياس للأبعاد، interpolation بين tokens، وقياس الخط مع مراعاة TextScaler.
- `ResponsiveMode`: `fixed` و`scaleOnly` و`adaptiveOnly` و`adaptiveScale`.
- Tokens/enums: `AppSpacing` و`AppRadius` و`AppFontSize` و`AppIconSize` و`AppElevation` و`AppComponentSize` و`AppAspectRatio` و`AppBaseWidth` و`ResponsiveToken` و`ScreenType` و`AppOrientation`.
- `Rh` في `responsive_helper.dart`: API ساكنة للـ responsive helpers.
- `context.ui` من `UIContextExtension`: مدخل موحد إلى `padding` و`size` و`text` و`spacing` و`radius` و`icon` و`shadow` و`grid` و`screen` و`theme` و`dir`.
- `context.ui.grid.widget` يختار بناءً على نوع الجهاز. `context.ui.grid.adaptive` يختار بناءً على المساحة الفعلية التي يحصل عليها العنصر (AdaptiveLayout)، لا عرض الشاشة كله.
- `AdaptiveLayout`: استخدمه لتخطيطات المحتوى داخل panes أو sidebars حيث قد يختلف عرض العنصر عن عرض الشاشة.
- ملفات `app_enums.dart` و`ui_extension.dart` و`responsive_helper.dart` مرتبطة بملفات `part/part of`. اقرأ المجموعة معاً ولا تفصل أو تنقل ملفاً منها منفرداً.

### Theme
- `AppTheme.light()` و`AppTheme.dark()`: إنشاء ThemeData دون BuildContext.
- `buildTheme`: تجميع ColorScheme وTextTheme وثيمات مكونات Material.
- `light_theme.dart` و`dark_theme.dart`: ColorSchemes وثيمات الوضعين.
- `AppColors` و`AppTextStyles`: ألوان وأنماط نصية مركزية.
- `ThemeCubit` و`ThemeState`: اختيار light/dark/system وحفظ الاختيار عبر AppSettingsManager.
- `ThemeExtension`: امتداد ثيم إضافي. افحص استخدامه قبل إضافة لون أو Style جديد.

### State management
- `BaseCubit<State, Effect>`: Cubit مع EffectMixin ويغلق موارد Effects عند close.
- `EffectMixin` و`HasEffects`: Stream للأحداث أحادية الاستخدام، مع replay اختياري ومحدود زمنياً.
- `BlocEffectListener`: الاستماع إلى Effects في الواجهة.
- `AppBlocObserver`: مراقبة Bloc/Cubit.
- لا تنشئ BaseCubit أو Effect stream موازياً.

### Shared widgets
- `AppText`: نص مترجم عبر AppKey أو نص خام، ويدعم rich/selectable، ويستفيد من AppTextType وResponsive Typography.
- `AppButton`: زر موحد، ويدعم AppKey أو `AppButton.raw`، variants/sizes/loading/expand. تصميمه في `AppButtonStyle`.
- `AppIcon`: عرض الأيقونات وفق واجهة المشروع.
- `AppImage`: عرض الصور وفق خياراته الحالية؛ اقرأ الـ API قبل إعادة التنفيذ.
- `AppAppbar`: AppBar مشترك.
- `AppNavigationBar` و`AppNavigationRail` و`AppSidebar`: عناصر التنقل حسب حجم الشاشة.
- `AppNavigationBarStyle` وStyles الخاصة بالـ Rail/Sidebar: مظهر عناصر التنقل.
- `MessageViewWidgets`: مكونات رسائل/حالات العرض المشتركة.
- لا تنشئ زرّاً أو نصاً أو شريط تنقل عاماً جديداً قبل تقييم هذه المكونات.

### Routing
- Core يوفر `AppRoutes` و`RouteItem` و`RouteTransitions` و`AppRouterObserver` و`GoRouterRefreshStream`.
- تكوين GoRouter والحراس الفعليون موجودان خارج Core في `lib/app/routing/app_go_router.dart` و`route_guards.dart`.
- راجع الملفين خارج Core عند تعديل تدفق التنقل أو الحماية؛ لا تفترض أن تعريف المسار وحده يكفي.

### Storage
- `StorageService`: العقد العام read/write/delete/clearAll/containsKey.
- `PrefsStorageService`: تخزين إعدادات SharedPreferences.
- `SecureStorageService`: التخزين الآمن.
- `TokenManager`: إدارة access/refresh/user tokens وإشعار `sessionCleared` عند إزالة الجلسة.
- `AppSettingsManager`: Theme وLanguage وOnboarding.
- `HiveManager` و`HiveStorageService` و`HiveObjectBox` و`CacheManager`: Hive/cache.
- `StorageKey` و`StorageKeys`: مفاتيح التخزين المركزية.
- اختر التخزين حسب حساسية البيانات وطبيعتها، ولا تحفظ Tokens في SharedPreferences.

## 3. الاختبارات الموجودة

توجد اختبارات Core ضمن `test/core/` تغطي Access وDI وEnvConfig وApiResult وNetwork/Interceptors وResponsive/AdaptiveLayout وTheme وBaseCubit/Effects وWidgets وTokenManager. راجع الاختبار المقابل عند تغيير أي عقد أو سلوك.

## 4. ملاحظات وحدود هذه الخريطة

- هذه اللقطة تصف الملفات الموجودة عند commit المذكور. قد تتغير الملفات أو APIs لاحقاً؛ افحص الكود الحالي دائماً.
- لا تعني الإشارة إلى أداة أنها مناسبة لكل استعمال؛ تحقق من حدودها وتوقيعها والطبقة التي تنتمي إليها.
- وجود API في Core لا يعني أن منطق Feature أو Business Logic يجب نقله إليه.
- لا تدّعِ نجاح Flutter analyze/test إلا بعد تشغيلهما فعلياً في بيئة فيها Flutter SDK.
