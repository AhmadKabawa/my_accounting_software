# خريطة Core — مرجع إعادة الاستخدام

> **المسار:** `lib/app/core/`.
> هذه خريطة توجيه وليست بديلاً عن قراءة التنفيذ. الكود هو المرجع؛ عند أي اختلاف بين الخريطة والكود يُعتمد الكود ثم تُصحَّح الخريطة.
> القيم المتغيرة (Breakpoints، المهلات، عدد المحاولات، أسماء الإعدادات) لا تُنسخ هنا: افتح الملف المسؤول عنها.

## الغرض

يحتوي Core على البنية التحتية المشتركة، وأنظمة العرض والتصميم، والأدوات العامة التي تعتمد عليها الميزات. قبل إنشاء أي Helper أو Service أو Widget أو Theme أو Responsive logic جديد، ابحث هنا أولاً. قرار إضافة شيء إلى Core تحكمه `ARCHITECTURE_RULES.md`.

## 1. خريطة المجلدات

جميع مسارات «نقطة البداية» في الجدول أدناه نسبية إلى `lib/app/core/` ما لم يُذكر خلاف ذلك.

| المجلد | المسؤولية | نقطة البداية |
|---|---|---|
| `access/` | الدور الحالي والصلاحيات وفحص إظهار عناصر الواجهة | `access/cubit/access_cubit.dart` |
| `di/` | تسجيل خدمات Core في GetIt | `di/service_locator.dart` |
| `error/` | الاستثناءات الداخلية، Failure، التحويل والترجمة | `error/mappers/exception_mapper.dart` |
| `foundation/` | أنواع ونتائج مشتركة، إعدادات، Logger، UseCases، التحقق، ثوابت الصور | `foundation/types/api_result.dart` |
| `localization/` | اللغة الحالية، مفاتيح الترجمة، تحميل الترجمات واتجاه النص | `localization/cubit/locale_cubit.dart` |
| `network/` | Dio وواجهته، Interceptors، الاتصال، الإلغاء، عقد Realtime | `network/api_client_interface.dart` |
| `presentation/design_system/responsive/` | القياس والـ Tokens وواجهات Responsive | `presentation/design_system/responsive/extension/ui_extension.dart` |
| `presentation/design_system/theme/` | Light/Dark Theme والألوان والطباعة وThemeCubit | `presentation/design_system/theme/app_theme.dart` |
| `presentation/state_management/` | BaseCubit وEffects وBlocObserver | `presentation/state_management/base_cubit.dart` |
| `presentation/widgets/` | Widgets موحدة مشتركة | `presentation/widgets/app_*` |
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
- `initCoreDI()` يسجل خدمات Core فقط (Storage وNetwork وTheme وLocale وAccess). `GoogleSignIn` ليس فيها: يُسجَّل في `initAuthDI()` (`features/auth/di/auth_di.dart`) بقيمة `AppConfig.googleClientId`.
- `lib/app/app_di.dart` هو منسق التهيئة (Composition Root): يستدعي Core ثم DI كل Feature بالترتيب الموثق فيه. لا تضف نقطة Service Locator ثانية.
- DI الخاص بكل Feature داخل `features/<feature>/di/`. افحص عمر كل Cubit/Service وطريقة تسجيله قبل اختيار Singleton أو Factory.

### Error handling
- `AppException` و`ApiException`: تمثيل أخطاء طبقة البيانات والشبكة.
- `Failure` (`error/failures/failure.dart`): عقد الخطأ الذي يصل إلى Domain/Presentation، ويحمل `messageKey` من نوع `AppKey` و`statusCode` اختيارياً.
- `ExceptionMapper.map` (`error/mappers/exception_mapper.dart`): يحوّل `AppException` إلى `Failure`. مستخدم في Repositories (مثل `AuthRepositoryImpl`).
- `ServerErrorMapper.map`: يحوّل رسائل الخادم أو Status Code إلى `AppKey`.
- `FailureTranslator.translate(Failure)` (`error/translators/failure_translator.dart`): أداة مستقلة عن `ExceptionMapper`؛ تحوّل `Failure` إلى نص مترجم **مرة واحدة** (`failure.messageKey.tran`). لا يستهلكها كود فعّال حالياً: `AuthCubit` يمرر `failure.messageKey` (AppKey) مباشرة في `AuthEffect.showMessage` وتتم الترجمة وقت العرض. استخدمها فقط حيث يلزم `String` جاهز. الترتيب: `ExceptionMapper` (Exception → Failure) ثم الترجمة عند العرض. لا تترجم داخل Repository.

### Foundation
- `ApiResult<T>`: نتيجة طبقة البيانات (`ApiSuccess` و`ApiFailure`) مع `toEither()` و`toEitherAsync()`.
- `PaginatedResult` و`PaginatedParser`: نتائج وتحليل الصفحات.
- `EnvConfig` (`foundation/config/env_config.dart`): يقرأ متغيرات البيئة عبر `String.fromEnvironment` (ثوابت وقت البناء) ويتحقق منها (`validate` للاختبارات). يتوقع `--dart-define-from-file`؛ المثال في `config/dart_defines.example.json`. يُستهلك من `AppConfig` فقط. لا تضع أسرار الخادم أو service_role في التطبيق.
- `AppConfig` (`foundation/config/app_config.dart`): **المدخل الوحيد لإعدادات التطبيق**، وكل قيمه ثابتة بعد التهيئة. يمرر قيم البيئة (`baseUrl` و`supabaseAnonKey` و`googleClientId` و`ensureConfigured()`) ويحمل الثوابت العامة (مهلات، إعادة المحاولة، لغات، `defaultPageSize`، صيغ تواريخ…). الميزات لا تستورد `EnvConfig`. `appName` قيمة مؤقتة بانتظار الاسم الرسمي. افحصه قبل إضافة ثوابت ولا تنسخ قيمه إلى التوثيق.
- `Logger`: سجل موحد؛ لا تسجل Tokens أو كلمات مرور أو بيانات مالية حساسة.
- `UseCase` و`UseCaseNoParams`: عقود Use Cases.
- `AppValidator` و`ValidationRule` (`lib/app/core/foundation/validation/app_validator.dart`): نظام التحقق من مدخلات النماذج، ورسائله `AppKey`. التوقيع `AppValidator.validate(value, rules, {params, customKeys})` يعيد نصاً مترجماً أو `null`. نوع قيم `params` هو `dynamic`؛ و`ValidationRule.async` و`AsyncValidator` محجوزان ولا يوجد مسار async في `validate()`.
- `AppPathImage` و`AppPathImages` (`lib/app/core/foundation/constants/image_constants.dart`): ثوابت مسارات الصور والأصول. يجمع `AppPathImage.path` مسار الأصل مع الاسم، ويحدد `isRtl` ما إذا كان الأصل مرتبطاً باتجاه النص.

### Localization
- `LocaleCubit` و`LocaleState`: حالة اللغة (الحالة تحمل `Locale` فقط).
- `AppLanguage`: اللغات المدعومة وتحويل الكود إلى Locale.
- `AppKey` و`AppKeys`: مفاتيح الترجمة المنظمة (`AppKey.tran` للترجمة المباشرة، و`.tr(args:/namedArgs:)` عند وجود متغيرات). ملفا `app_ar.dart` و`app_en.dart` يحويان النصوص. مفاتيح الثيم في `AppKeys.theme` و«موافق» في `AppKeys.common.ok`.
- `MyDartLoader` (`lib/app/core/localization/translations/asset_loader.dart`): تنفيذ `easy_localization.AssetLoader` يختار `app_en.dart` أو `app_ar.dart`، ويُستخدم في `main.dart`.
- `DirectionExtension` (`lib/app/core/localization/translations/localization_extension.dart`): امتداد مستقل على `BuildContext` يوفر `isRTL` و`directionalIcon` و`directionalValue` و`transformFlip`. المدخل الموحد الموصى به في هذا الدليل هو `context.ui.dir`؛ أما هذا الامتداد فيبقى تعريفاً منفصلاً غير مستخدم في ملفات الميزات المفحوصة.
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

#### RetryInterceptor

سياسة Retry وidempotency وتفاصيل المحاولات موضحة في [قواعد المعمارية §6](ARCHITECTURE_RULES.md).

#### Realtime — لا يوجد تنفيذ فعّال
- `RealtimeClient` (`lib/app/core/network/realtime/realtime_client.dart`) **عقد مجرد فقط** (`connect/disconnect/on/off/emit/statusStream/onTableChange/offTable` وenum `RealtimeStatus`)؛ ليس خدمة جاهزة.
- لا يوجد تنفيذ Supabase Realtime فعّال موصول أو مستخدم: لا implementation ملموس للعقد، ولا تسجيل في DI، ولا مستهلك في `lib` أو `test`.
- عند الحاجة إلى Realtime يلزم تنفيذ جديد وتسجيله في DI وإضافة اختباراته؛ لا تفترض أنه متوفر.

### Responsive وDesign System
- `ScreenEngine`: مصدر واحد لتحديد نوع الشاشة والأبعاد وحدود الشاشات (Breakpoints). افتحه لمعرفة القيم الحالية ولا تنسخها.
- `ScaleEngine`: حساب القياس والاستيفاء بين tokens وقياس الخط مع TextScaler.
- `ResponsiveMode`: أنماط القياس (`fixed` و`scaleOnly` و`adaptiveOnly` و`adaptiveScale`).
- Tokens/enums: `AppSpacing` و`AppRadius` و`AppFontSize` و`AppIconSize` و`AppElevation` و`AppComponentSize` و`AppAspectRatio` و`AppBaseWidth` و`ResponsiveToken` و`ScreenType` و`AppOrientation`.
- `Rh` (اسم مستعار لـ `ResponsiveHelper` في `responsive_helper.dart`): API ساكنة للقياس واختيار الـ builders.
- `context.ui` من `UIContextExtension`: **المدخل العام الموحد** إلى `padding` و`size` و`text` و`spacing` و`radius` و`icon` و`shadow` و`grid` و`screen` و`theme` و`dir`. تم حذف `ResponsiveContextExtension` (اختصارات `context.spacing()`/`pad()`/...)؛ لا تستخدمها ولا تعد إنشاءها.
- `context.ui.text`: `of(AppTextType)` لنمط نص متجاوب بلون الثيم، و`size` و`style` لأحجام وأنماط خارج الأدوار.
- `AppTextType` و`AppTextTypeX` (`extension/ui_extension/app_text_type.dart`، جزء من `ui_extension.dart`): أدوار النص الموحدة. أُعيد تصديرهما من `widgets/app_text/app_text_enum.dart` و`app_text_extension.dart` للتوافق. تعريفات الأحجام في `AppTextStyles`؛ بعض أنماطها (`inputText` و`link` و`overline` و`appBarTitle`...) ليس لها دور في `AppTextType` لعدم وجود Core Widget يستهلكها.
- `context.ui.theme`: `colors` (ColorScheme فقط) و`semanticColors` (الألوان الدلالية) و`textTheme` و`isDark`/`isLight` و`value`/`valueOrNull`.
- `AppTextStyleResolver` (`extension/ui_extension/app_text_style_resolver.dart`): امتداد على `AppTextStyle` بدالة `resolve(context, {mode, respectTextScaler})` تعيد `TextStyle` متجاوباً عبر `Rh.textStyle`. يستخدمه `AppText`. موضعه هنا لأن الثيم لا يجوز أن يعتمد على محرك Responsive (الثيم يستخدم `AppTextStyle.baseline` فقط). `part of 'ui_extension.dart'`.
- `Gap` (`engine/app_gap.dart`): Widget مسافة يحدد محوره تلقائياً من أقرب `Flex` أب (عمودي افتراضياً)، ويدعم `axis` و`Gap.expand()`. يُنتج بحجم متجاوب عبر `context.ui.spacing.gap(AppSpacing.md)` أو `Rh.gapSpace`.
- `context.ui.grid.widget` يختار بناءً على نوع الجهاز. `context.ui.grid.adaptive` يختار بناءً على المساحة الفعلية للعنصر (`AdaptiveLayout`) لا عرض الشاشة.
- `AdaptiveLayout`: لتخطيطات المحتوى داخل panes أو sidebars.
- مجموعات `part/part of`: `app_enums.dart` و`ui_extension.dart` و`responsive_helper.dart` وملفاتها التابعة. اقرأ المجموعة معاً ولا تفصل أو تنقل ملفاً منها (راجع `ARCHITECTURE_RULES.md`).

### Theme
- `AppTheme.light()` و`AppTheme.dark()`: إنشاء ThemeData دون BuildContext.
- `buildTheme`: تجميع ColorScheme وTextTheme وثيمات مكونات Material (`theme/components/`).
- `light_theme.dart` و`dark_theme.dart`: ثيمات الوضعين.
- `AppColors` و`AppTextStyles`: القيم الخام للألوان وتعريفات الأنماط النصية. `AppColors` للاستخدام داخل ملفات الثيم فقط، والواجهات تصل للألوان عبر `context.ui.theme`.
- `AppSemanticColors` (`theme/extensions/app_semantic_colors.dart`): `ThemeExtension` حقيقي (`copyWith` و`lerp`) بألوان `success` و`warning` و`info` وما يقابلها `onX` و`debit` و`credit`، ومسجل في الثيمين عبر `buildTheme`. القراءة: `context.ui.theme.semanticColors`. قيم `debit`/`credit` مؤقتة (placeholder) بانتظار الهوية البصرية. لا لون خطأ دلالي منفصل: استخدم `colors.error`. لا يستورد محرك Responsive.
- `ThemeCubit` و`ThemeState`: اختيار light/dark/system وحفظه عبر `AppSettingsManager`.
- `theme/extensions/theme_mode_extension.dart`: `ThemeModeExtension` على `ThemeMode` (`icon` و`nameKey` وهو `AppKey` من `AppKeys.theme`). لا يوجد مستهلك فعّال حالياً. الامتداد القديم على `BuildContext` المسمى `ThemeExtension` (الذي يتعارض مع كلاس Flutter) حُذف؛ استخدم `context.ui.theme`.
- ألوان `ColorScheme` الحالية (وتعارض مسميات مثل `primary`/`primaryLight`/`primaryDark`) لم تُراجع بعد.

### State management
- `BaseCubit<State, Effect>`: Cubit مع `EffectMixin` ويغلق موارد Effects عند `close`.
- `EffectMixin` و`HasEffects`: Stream لأحداث أحادية الاستخدام، مع replay اختياري ومحدود زمنياً (`emitEffect(effect, {replayable})`).
- `BlocEffectListener` (`lib/app/core/presentation/state_management/bloc_effect_listener.dart`): Widget للاستماع إلى `HasEffects.effectStream`، يقبل Cubit اختياري أو يقرأه من `context`. لا يوجد اختبار مباشر مسجل له. **حالة التحقق: `NOT_VERIFIED`** لأي ملاحظة تحليل/سلامة lifecycle؛ يلزم تشغيل `flutter analyze` واختبار Widget مخصص في بيئة Flutter قبل اعتماد حكم نهائي.
- `AppBlocObserver`: مراقبة Bloc/Cubit.

### Shared widgets
- `AppText`: نص مترجم عبر `AppKey` أو `AppText.raw`، ويدعم `rich` و`selectable`.
- `AppButton`: زر موحد، بـ `AppKey` أو `AppButton.raw`، مع variants/sizes/loading. التصميم في `AppButtonStyle`.
- `AppIcon` و`AppImage`: عرض الأيقونات والصور؛ اقرأ الـ API قبل إعادة التنفيذ.
- `AppAppBar` (`lib/app/core/presentation/widgets/app_appbar/app_appbar.dart`): يأخذ `progress` ويُستخدم في `features/home/presentation/pages/home_screen.dart`. يحمل التنفيذ الحالي علامة VAUDE التجارية، وأزرار القائمة والبحث والحقيبة بلا callbacks افتراضياً؛ لذلك لا يُعد AppBar عاماً مكتملاً لكل الميزات.
- `AppNavigationBar` و`AppNavigationRail` و`AppSidebar` وأنماطها: عناصر التنقل حسب حجم الشاشة.
- `MessageViewWidgets` و`MessageType` (`widgets/app_message/message_view_widgets.dart`): نظام الرسائل الموحد (SnackBar/Dialog/Loading). يقبل `messageKey` (AppKey، المفضل) أو `message` (String للتوافق)، ويبني على `AppText`/`AppButton`، وألوانه من `colors.error` و`semanticColors`. أنواع الرسالة: error وsuccess وwarning وinfo وloading. لا يوجد استهلاك فعّال حالياً (شاشات auth التي ستستخدمه معلّقة).

### Routing
- Core يوفر `AppRoutes` و`RouteItem` و`RouteTransitions` و`GoRouterRefreshStream` و`MyNavObserver` (`lib/app/core/routing/app_router_observer.dart`): الاسم الفعلي للمراقب؛ لا يوجد `AppRouterObserver`. يسجل أحداث التنقل عبر `debugPrint`، ويُستخدم في `AppRouter`.
- تكوين GoRouter والحراس موجودان خارج Core في `lib/app/routing/app_go_router.dart` و`route_guards.dart`.

### Storage
- `StorageService`: العقد العام read/write/delete/clearAll/containsKey.
- `PrefsStorageService`: SharedPreferences. `SecureStorageService`: التخزين الآمن.
- `TokenManager`: إدارة tokens وإشعار `sessionCleared` عند إزالة الجلسة.
- `AppSettingsManager`: Theme وLanguage وOnboarding.
- `HiveManager` و`HiveStorageService` و`HiveObjectBox` و`CacheManager`: Hive/cache. `HiveManager.init()` تُستدعى من `main.dart`؛ الميزات تفتح صناديقها عبر `HiveManager.openBox` (مثل `auth_di.dart`). لا يُسجَّل Hive في `initCoreDI()` بل في DI الميزة.
- `HiveBoxNames` (`storage/hive/hive_box_names.dart`): أسماء الصناديق (`cache` و`users` و`products`). `HiveBoxTypeId`: معرّفات `typeId` للـ adapters، وحالياً `user` فقط. يُستخدم في `@HiveType(typeId: HiveBoxTypeId.user)` لـ `UserModel`. أي typeId جديد يُعرّف هنا لتجنب التضارب.
- `StorageKey` و`StorageKeys`: مفاتيح التخزين المركزية.
- اتبع سياسة تخزين Tokens في [قواعد المعمارية §6](ARCHITECTURE_RULES.md).

## 3. تغطية الاختبارات

تفاصيل ملفات الاختبار الموجودة وما تغطيه والفجوات المعروفة في [تغطية اختبارات Core](CORE_TEST_COVERAGE.md).

## 4. ملاحظات وحدود هذه الخريطة

- لم تُشغَّل `flutter analyze` أو `flutter test` ضمن هذا التدقيق؛ حالة التنفيذ هنا `NOT_RUN`.
- لا تحتفظ الخريطة بملاحظات تاريخية عن تعديل ملفات مولّدة أو حالة بيئة سابقة؛ عند تغيير Freezed/JSON/Hive annotations أعد التوليد بالأداة المعتمدة وتحقق من عدم وجود diff غير متوقع.

- افحص الكود الحالي دائماً؛ قد تتغير الملفات أو APIs.
- لا تعني الإشارة إلى أداة أنها مناسبة لكل استعمال؛ تحقق من حدودها وتوقيعها وطبقتها.
- وجود API في Core لا يعني نقل منطق Feature إليه.
- الفرض الآلي للقواعد المعمارية غير موجود حالياً (راجع `ARCHITECTURE_RULES.md`).
