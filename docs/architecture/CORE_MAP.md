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
| `routing/` | `RouteItem`، transitions، observer ومساعدات GoRouter (المسارات نفسها في الميزات) | `routing/route_item.dart` |
| `storage/` | عقد التخزين وتطبيقات SharedPreferences وSecure وHive | `storage/storage_service.dart` |

## 2. تفاصيل الأدوات الموجودة

### Access
- `AccessSnapshot` (`access/models/access_snapshot.dart`): لقطة typed مطابقة لعقد `public.get_my_access()`، وتشمل المستخدم والأدوار والصلاحيات والفروع والمستودعات ونقاط البيع. تحليل الحقول المطلوبة صارم؛ `email` و`warehouses[].branch_id` يقبلان `null` لكن يجب وجود المفتاحين وفق مخطط قاعدة البيانات.
- `AccessRemoteDataSource` يستدعي `POST /rest/v1/rpc/get_my_access` عبر `IApiClient` و`AppEndpoint` مع جلسة مصادق عليها؛ لا ينشئ Dio أو Supabase client جديداً.
- `AccessRepository` و`GetMyAccessUseCase` يمرران النتائج عبر `ApiResult.toEither` و`RepositoryExecutor`.
- `AccessCubit` (`access/cubit/access_cubit.dart`): حالات initial/loading/ready/failure، و`load/retry/clear/selectBranch`، و`can/canOperate/canOperateInSelectedBranch/canAny/canAll/require`. `AccessContextX` يوفّر `context.can` و`context.canOperate`. لا صلاحيات أثناء التحميل أو الفشل؛ تغيير الفرع المقبول يعيد تحميل اللقطة.
- `KnownPermissionCodes` يسجل الأكواد المعروفة للتطبيق؛ أي كود غير معروف يُهمل وفق العقد. لا توجد أدوار افتراضية أو `SystemRoles`.
- `PermissionGate` و`AccessContextX` يعتمدان اللقطة الناجحة فقط. `AccessStatusGate` يحجب Shell أثناء التحميل والفشل ويعرض إعادة المحاولة. هذا فحص UX وليس حماية؛ التفويض الحقيقي يفرضه الخادم وRLS.
- سياسة الذاكرة وإعادة التحميل والمسح موثقة في [ADR-0006](ADR/0006-access-snapshot-lifecycle.md). DI للصلاحيات في `access/di/access_di.dart`، ويُستدعى من Composition Root بعد تسجيل الشبكة.

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
- `FailureTranslator.translate(Failure)` (`error/translators/failure_translator.dart`): أداة مستقلة عن `ExceptionMapper`؛ تحوّل `Failure` إلى نص مترجم **مرة واحدة** (`failure.messageKey.tran`). لا يستهلكها كود فعّال حالياً: `AuthFlowCubit`/`SessionCubit` يمرران `failure.messageKey` (AppKey) إلى `FlashMessages` وتتم الترجمة وقت العرض. استخدمها فقط حيث يلزم `String` جاهز. الترتيب: `ExceptionMapper` (Exception → Failure) ثم الترجمة عند العرض. لا تترجم داخل Repository.

### Foundation
- `ApiResult<T>`: نتيجة طبقة البيانات (`ApiSuccess` و`ApiFailure`) مع `toEither()` و`toEitherAsync()`.
- `PaginatedResult` و`PaginatedParser`: نتائج وتحليل الصفحات.
- `EnvConfig` (`foundation/config/env_config.dart`): يقرأ متغيرات البيئة عبر `String.fromEnvironment` (ثوابت وقت البناء) ويتحقق منها (`validate` للاختبارات). يتوقع `--dart-define-from-file`؛ المثال في `config/dart_defines.example.json`. يُستهلك من `AppConfig` فقط. لا تضع أسرار الخادم أو service_role في التطبيق.
- `AppConfig` (`foundation/config/app_config.dart`): **المدخل الوحيد لإعدادات التطبيق**، وكل قيمه ثابتة بعد التهيئة. يمرر قيم البيئة (`baseUrl` و`supabaseAnonKey` و`googleClientId` و`ensureConfigured()`) ويحمل الثوابت العامة (مهلات، إعادة المحاولة، لغات، حجم الصفحة (`defaultPageSize` = 25 و`pageSizeOptions` = 10/25/50/100 و`resolvePageSize`)، صيغ تواريخ…). الميزات لا تستورد `EnvConfig`. `appName` قيمة مؤقتة بانتظار الاسم الرسمي. افحصه قبل إضافة ثوابت ولا تنسخ قيمه إلى التوثيق.
- `Logger`: سجل موحد؛ لا تسجل Tokens أو كلمات مرور أو بيانات مالية حساسة.
- `UseCase` و`UseCaseNoParams`: عقود Use Cases.
- `AppValidator` و`ValidationRule` (`lib/app/core/foundation/validation/app_validator.dart`): نظام التحقق من مدخلات النماذج، ورسائله `AppKey`. التوقيع `AppValidator.validate(value, rules, {params, customKeys})` يعيد نصاً مترجماً أو `null`. نوع قيم `params` هو `dynamic`؛ و`ValidationRule.async` و`AsyncValidator` محجوزان ولا يوجد مسار async في `validate()`.
- `AppPathImage` و`AppPathImages` (`lib/app/core/foundation/constants/image_constants.dart`): ثوابت مسارات الصور والأصول. يجمع `AppPathImage.path` مسار الأصل مع الاسم، ويحدد `isRtl` ما إذا كان الأصل مرتبطاً باتجاه النص.
- `Money` و`CurrencyMismatchException` (`lib/app/core/foundation/money/money.dart`): نوع المال `Money(amount, currencyId)` فوق `decimal` (قرار-70، [ADR-0005](ADR/0005-money-type-and-amount-formatter.md)). الجمع والطرح والمقارنة بعملة واحدة فقط وإلا `CurrencyMismatchException`؛ `times` و`convert` صريحان؛ ولا تقريب ضمني (`Money.rounded(MoneyRounding)`). `Money.fromRaw` يقرأ قيم PostgREST دون المرور بـ `double` حين تصل نصاً. ممنوع تسجيل قيمه في `Logger`. حالة التحقق: `NOT_RUN`.
- `MoneyRounding` و`MoneyRoundingMethod` (`money_rounding.dart` و`money_rounding_method.dart`): إعدادات تقريب العملة من جدول `currencies` (`decimal_places` و`rounding_increment` و`rounding_method`) تُمرَّر معاملاً ولا تُثبَّت في Flutter. دلالات `rounding_increment` > 0 و`UP`/`DOWN` للسالب تحتاج مطابقة مع `erp.round_currency`. `MoneyDecimalMath` (`money_decimal_math.dart`) أدوات داخلية لا تُستعمل من الميزات.
- `AmountFormatter` و`CurrencyDisplay` و`CurrencyLabelPlacement` (`foundation/money/amount_formatter.dart`، C13): تنسيق المبالغ بدوال خالصة: أرقام غربية، فاصل آلاف وعشري، كسور العملة لا القيمة، علامة `−`، عزل Bidi (`LRI…PDI`) حول الرقم، رمز العملة خارج العزل، بلا اختصار. التقريب في العرض لا يغيّر القيمة المحفوظة.

### Localization
- `LocaleCubit` و`LocaleState`: حالة اللغة (الحالة تحمل `Locale` فقط).
- `AppLanguage`: اللغات المدعومة وتحويل الكود إلى Locale.
- `AppKey` (`localization/translations/app_key.dart`): عقد النص المترجم، يحمل `key` و`ar` و`en`، ويوفر `.tran` للنص الجاهز و`.tr(args:/namedArgs:)` عند وجود متغيرات.
- مفاتيح النصوص معرفة كـ enum مستقل لكل قسم (`CommonKeys` و`FieldKeys` و`ValidationKeys` و`ErrorKeys` و`ServerErrorKeys` و`ErpErrorKeys` و`ThemeKeys` و`NavKeys`) في `localization/keys/`، ومفاتيح الميزات في `features/<feature>/presentation/localization/`. المفتاح مشتق من اسم القيمة؛ لا يوجد `AppKeys` أو قاموس `app_ar.dart`/`app_en.dart`.
- `key_registry.dart` (`lib/app/localization/key_registry.dart`) يجمع `allKeys` خارج Core حتى لا يعتمد Core على Features. يمرر جذر التركيب القائمة إلى `MyDartLoader(allKeys)`.
- `MyDartLoader` (`lib/app/core/localization/translations/asset_loader.dart`): تنفيذ `easy_localization.AssetLoader` يعيد نصوص `AppKey.ar` أو `AppKey.en` من السجل الممرر إليه.
- `DirectionExtension` (`lib/app/core/localization/translations/localization_extension.dart`): امتداد مستقل على `BuildContext` يوفر `isRTL` و`directionalIcon` و`directionalValue` و`transformFlip`. المدخل الموحد الموصى به في هذا الدليل هو `context.ui.dir`؛ أما هذا الامتداد فيبقى تعريفاً منفصلاً غير مستخدم في ملفات الميزات المفحوصة، ولا يُعد بديلاً متوافقاً بالكامل لأن سلوك `transformFlip` يختلف عندما تكون `isRtlChild: false`.
- لا تنشئ قاموس ترجمة موازياً.

### Network
- `IApiClient`: واجهة طلبات GET/POST/PUT/PATCH/DELETE/Upload والـ Pagination. المسارات من نوع `AppEndpoint`.
- `ApiClient`: التنفيذ عبر Dio وتحويل الاستجابة إلى `ApiResult`.
- `DioService`: إنشاء Dio وإضافة Interceptors.
- Interceptors (`network/dio/interceptors/`): Auth وConnectivity وLanguage وLogger وRefreshToken وRetry.
- `AppEndpoint` و`encodePathSegment` (`network/api_end_points.dart`): أداتان فقط. الـ endpoints نفسها في `features/<feature>/data/<feature>_endpoints.dart` (مثل `AuthEndpoints`)؛ المقاطع الديناميكية تمر بـ `encodePathSegment` فتُرمَّز وتُرفض `.` و`..`. `DioService`/`initCoreDI` يستقبلان `refreshEndpoint` من `app_di.dart` لأن Core لا يستورد ميزة.
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
- Tokens/enums: `AppSpacing` و`AppRadius` و`AppFontSize` و`AppIconSize` و`AppElevation` و`AppBorderWidth` و`AppComponentSize` و`AppAspectRatio` و`AppBaseWidth` و`ResponsiveToken` و`ScreenType` و`AppOrientation`، والجديدة: `AppGrid` (أعمدة/هامش/فاصل لكل فئة جهاز) و`AppDensity` (comfortable/compact لارتفاع الصف والرأس والحقل) و`AppDensityScope` (نطاق كثافة لشجرة فرعية؛ `AppDensityScope.of(context)`، الافتراضي comfortable). تقع في `responsive/engine/app_enums/`.
- `design_system/tokens/` (مستقلة عن Responsive): `AppMotion`/`AppMotionDuration` (مدد ومنحنيات الحركة، وتصير المدة صفراً عند «تقليل الحركة») و`AppLayer` (z-index للطبقات).
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
- `light_theme.dart` و`dark_theme.dart`: `ColorScheme` الوضعين (الداكن تصميم مستقل لا قلب آلي). `buildTheme` يستقبل `background` (لون الصفحة) منفصلاً عن `surface` (البطاقات).
- `AppColors` (السلالم الخام green/neutral) و`AppLightColors` و`AppDarkColors` (الأدوار بالأسماء نفسها) و`AppTextStyles` (الأنماط النصية بما فيها أدوار المبالغ `amount*` و`docCode` و`tableHeader` و`codeMono`) و`AppFontFamily`. الأدوار الخام للاستخدام داخل ملفات الثيم فقط، والواجهات تصل للألوان عبر `context.ui.theme`. التفاصيل والقرارات: [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md).
- `AppSemanticColors` (`theme/extensions/app_semantic_colors.dart`): `ThemeExtension` حقيقي (`copyWith` و`lerp`) بألوان `success` و`warning` و`info` (مع `onX` و`xContainer`) والمحاسبة (`debit`/`credit` محايدان، `balancePositive`/`balanceNegative`) وخمس حالات مستندات (`StatusColor` = fg/bg) وسلاسل الرسوم (`chart` و`chartColor(i)`) و`onSurfaceMuted` و`outlineStrong` و`focusRing`، ومسجل في الثيمين عبر `buildTheme`. القراءة: `context.ui.theme.semanticColors`. لا لون خطأ دلالي منفصل: استخدم `colors.error`. لا يستورد محرك Responsive.
- `ThemeCubit` و`ThemeState`: اختيار light/dark/system وحفظه عبر `AppSettingsManager`.
- `theme/extensions/theme_mode_extension.dart`: `ThemeModeExtension` على `ThemeMode` (`icon` و`nameKey` وهو `AppKey` من `ThemeKeys`). لا يوجد مستهلك فعّال حالياً. الامتداد القديم على `BuildContext` المسمى `ThemeExtension` (الذي يتعارض مع كلاس Flutter) حُذف؛ استخدم `context.ui.theme`.
- ألوان `ColorScheme` الحالية (وتعارض مسميات مثل `primary`/`primaryLight`/`primaryDark`) لم تُراجع بعد.

### State management
- `BaseCubit<State, Effect>`: Cubit مع `EffectMixin` ويغلق موارد Effects عند `close`.
- `EffectMixin` و`HasEffects`: Stream لأحداث أحادية الاستخدام، مع replay اختياري ومحدود زمنياً (`emitEffect(effect, {replayable})`).
- `BlocEffectListener` (`lib/app/core/presentation/state_management/bloc_effect_listener.dart`): Widget للاستماع إلى `HasEffects.effectStream`، يقبل Cubit اختياري أو يقرأه من `context`. لا يوجد اختبار مباشر مسجل له. **حالة التحقق: `NOT_VERIFIED`** لأي ملاحظة تحليل/سلامة lifecycle؛ يلزم تشغيل `flutter analyze` واختبار Widget مخصص في بيئة Flutter قبل اعتماد حكم نهائي.
- `AppBlocObserver`: مراقبة Bloc/Cubit.

### Shared widgets
- `AppText`: نص مترجم عبر `AppKey` أو `AppText.raw`، ويدعم `rich` و`selectable`.
- `AppSkeleton` (`widgets/app_skeleton/app_skeleton.dart`, C09): هياكل تحميل responsive بأشكال `line` و`block` و`card` و`tableRow`؛ يستعمل `shimmer` الموجودة، يؤخر الظهور 200ms افتراضياً ويوقف الحركة عند تفضيل تقليلها. **قيد المراجعة** حتى استعماله في AUTH-04 وCAT-07.
- `AppEmptyState` (`widgets/app_empty_state/app_empty_state.dart`, C08): حالة فارغة بأيقونة `AppIcon` وعنوان ووصف من `AppKey` وslot اختياري للإجراء؛ يدعم عرضاً مضغوطاً للحاويات المضمّنة. **قيد المراجعة** حتى استعماله في AUTH-04 وCAT-07.
- `AppButton`: زر موحد، بـ `AppKey` أو `AppButton.raw`، مع variants/sizes/loading. التصميم في `AppButtonStyle`.
- `AppIcon` و`AppImage`: عرض الأيقونات والصور؛ اقرأ الـ API قبل إعادة التنفيذ.
- `AppNavigationBar` و`AppNavigationRail` و`AppSidebar` وأنماطها: عناصر التنقل حسب حجم الشاشة.
- `MessageViewWidgets` و`MessageType` (`widgets/app_message/message_view_widgets.dart`): نظام الرسائل الموحد (SnackBar/Dialog/Loading). يقبل `messageKey` (AppKey، المفضل) أو `message` (String للتوافق)، ويبني على `AppText`/`AppButton`، وألوانه من `colors.error` و`semanticColors`. أنواع الرسالة: error وsuccess وwarning وinfo وloading. لا يوجد استهلاك فعّال حالياً (شاشات auth التي ستستخدمه معلّقة). `hideMessage` يُخفي أعلى نافذة رسالة فقط (يتعرف عليها باسم المسار على الـ root navigator) ولا يغلق صفحة، ولا أثر له إن لم توجد رسالة. `failureBanner(Failure)` يبني `InlineBanner` للخطأ: عنوان «يرجى مراجعة البيانات» لـ `ValidationFailure`، و«تعذّر إكمال العملية» لأعطال الشبكة والخادم والتخزين وغير المتوقع، وبلا عنوان للجلسة والصلاحية وغير الموجود؛ والنص دائماً `failure.messageKey` المترجم (لا نص خادم). مسار `message:` النصي لا يُستعمل لنص الخادم.
- `InlineBanner` و`InlineBannerVariant` (`widgets/app_inline_banner/inline_banner.dart`، C38): رسالة داخل الشاشة (success/error/warning/info) بعنوان اختياري وأيقونة وزر إغلاق عند تمرير `onDismiss`. النص `AppKey` فقط (لا `String`). ألوانه `xContainer` للخلفية و`x` للنص والأيقونة والحد من `semanticColors` (والخطأ من `ColorScheme`)، فيعمل في Light وDark دون فرع. منطقة حية (`liveRegion`) باسم نوعها لقارئ الشاشة، والنص قابل للتحديد (`selectable`). يتبع `AppDensityScope`: في الوضع المضغوط على شاشة أكبر من الهاتف تضيق المسافة الرأسية ويضيق زر الإغلاق (عبر `AppIconButton`)، ولا يتغير على الهاتف. نصوصه في `MessageKeys` (قسم `message`).

### Routing
- Core يوفر `RouteItem` (`routing/route_item.dart`) و`RouteTransitions` و`GoRouterRefreshStream` و`MyNavObserver` (`lib/app/core/routing/app_router_observer.dart`): الاسم الفعلي للمراقب؛ لا يوجد `AppRouterObserver`. يسجل أحداث التنقل عبر `debugPrint`، ويُستخدم في `AppRouter`.
- تكوين GoRouter والحراس وسجل المسارات موجودة خارج Core في `lib/app/routing/app_go_router.dart` و`route_guards.dart` و`route_registry.dart` (`allRoutes` يجمع `<Feature>Routes.all`).

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

- تُسجَّل نتائج `dart format` و`flutter analyze` و`flutter test` من تشغيلها الفعلي؛ وجود ملفات الاختبار وحده لا يثبت نجاحها.
- لا تحتفظ الخريطة بملاحظات تاريخية عن تعديل ملفات مولّدة أو حالة بيئة سابقة؛ عند تغيير Freezed/JSON/Hive annotations أعد التوليد بالأداة المعتمدة وتحقق من عدم وجود diff غير متوقع.

- افحص الكود الحالي دائماً؛ قد تتغير الملفات أو APIs.
- لا تعني الإشارة إلى أداة أنها مناسبة لكل استعمال؛ تحقق من حدودها وتوقيعها وطبقتها.
- وجود API في Core لا يعني نقل منطق Feature إليه.
- الفرض الآلي للقواعد المعمارية غير موجود حالياً (راجع `ARCHITECTURE_RULES.md`).


## إضافات الدفعة C (ودجتس core الجديدة)

- `AppIconData` (sealed: material/svg/networkSvg/image/networkImage) و`AppIcons` (المكان الوحيد لتعريف الأيقونات؛ و`NavBarItem.icons` يأخذ `AppIconData`، والمُنشئ القديم بـ `IconData` ما زال يعمل) و`AppIcon(AppIconData, size: AppIconSize)` بحجم responsive. `AppIcon` غير قابل للضغط عمداً.
- `AppButtonVariant.text` (زر نصي) وأيقونة `AppButton.icon` من نوع `AppIconData`.
- `AppIconButton` (`widgets/app_button/app_icon_button.dart`): ضمن نظام الأزرار، `tooltipKey` مطلوب، منطقة لمس >= 48 من التوكنز.
- `AppTextField` + `AppTextFieldStyle` (`widgets/app_text_field/`).
- `AppDivider` (نص اختياري) و`AppPageAppBar` (شريط الصفحات العادية؛ أُزيل شريط الرئيسية القديم `AppAppBar` لأنه خاص بعلامة تجارية).
- `AppCard` (`widgets/app_card/app_card.dart`): سطح بحدّ لتجميع المحتوى (بطاقات الأرقام، القوائم)؛ الحشو والزوايا من التوكنز، والحدّ بـ `AppBorderWidth.thin`، وقابل للنقر عند تمرير `onTap`.
- `AppBorderWidth` (`design_system/responsive/engine/app_enums/app_border_width.dart`): توكن سُمك الحدود والخطوط (`thin` و`thick`) يُقرأ بـ `.of(context)`؛ لا سُمك حدّ برقم حرفي.
- `FlashMessages` + `FlashMessageListener` (`widgets/app_message/flash_messages.dart`): رسائل تعيش بعد انتقال الصفحة.
- `RepositoryExecutor` (`foundation/base/repository_executor.dart`): mixin لنمط try/catch + `ExceptionMapper`.
- `HiveStorageService` و`CacheManager` تُسجَّلان في core DI.


## تحديث 2026-11-18 — قشرة التطبيق وقوالب الصفحات

- AppShell في lib/app/shell/app_shell.dart يبقى مالك التنقل المفلتر عبر AccessCubit وAccessStatusGate. أضيفت له واجهة شريط علوي اختيارية تدعم الفرع الحالي عبر ScopeSelector، فتات الخبز، قائمة المستخدم، وشارة جلسة كاشير تُمررها الميزة المالكة.
- AppShellTopBar في presentation/widgets/app_shell يعرض الفرع وشارة القراءة فقط عند can_operate=false، ويعرض جرس إشعارات معطلاً بلا فتح في v1.
- `AppRowActions` / `AppRowAction` (`widgets/app_row_actions/app_row_actions.dart`): إجراءات السجل كأزرار أيقونات فقط (`primary` سطرية بحد أقصى 2، و`overflow` في قائمة «المزيد»). ممنوع أزرار نصية للتعديل/الحذف في الجداول. أيقوناتها `AppIcons.edit/delete/block/restore`.
- `ImagePickerPort` (`core/platform/image_picker/`): اختيار صورة واحدة مستقلاً عن المنصة (`PickedImage`)؛ التنفيذ `FilePickerImagePicker` الملف الوحيد الذي يستورد `file_picker`، ومسجَّل في `app_di.dart`.
- AppMenu في presentation/widgets/app_menu قائمة عامة مبنية على AppKey، وأيقونة اختيارية وعناصر قابلة للتعطيل.
- AppBreadcrumb وAppPageHeader مكوّنان عامان مستقلان. يقبل AppShell breadcrumbBuilder اختيارياً لتوليد المسار من GoRouterState؛ تبقى قائمة breadcrumbs الثابتة متاحة للتوافق.
- FormPageTemplate (T3) وDashboardTemplate (T5) في presentation/widgets/app_page_template؛ القوالب لا تقرأ الصلاحيات. الاستخدام في شاشات AUTH الطيّارة لم يُدمج بعد، لذلك لا تعد القوالب منجزة وفق R12.
- شارة جلسة الكاشير حالياً slot من AppKey وليست اتصالاً بمصدر جلسة POS. لا توجد في AccessSnapshot حالة جلسة مفتوحة؛ مصدرها يجب أن يأتي من ميزة POS عند بنائها.


## متابعة تنفيذ C46/C48 — 2026-11-19

- رُبط AppMenu بقائمة المستخدم داخل AppShell، وتحتوي على الانتقال إلى الملف الشخصي وتسجيل الخروج.
- أضيفت قائمة «المزيد» للجوال عندما تتجاوز الوجهات خمساً؛ تعرض الوجهات الإضافية في BottomSheet.
- أضيفت حالات Empty افتراضية إلى FormPageTemplate وDashboardTemplate باستخدام AppEmptyState، مع إمكانية تمرير حالة فارغة مخصصة.
- على Windows فقط، يتيح AppSidebar الطي إلى شريط أيقونات ويحفظ التفضيل عبر AppSettingsManager؛ الويب يبقي Sidebar الموسع. يُقرأ دعم الطي من PlatformCapabilities عبر تنفيذ شرطي داخل core/platform، لا من Widget.
- زر الرجوع الذي كان يضيفه AppShell أُزيل؛ الرجوع مسؤولية الصفحة/المسار، وتُترك معالجة PopScope للصفحة المالكة.
- `UnsavedChangesGuard` يُحقن في AppShell؛ يسجل FormPageTemplate حالة dirty لكل فرع، ويُستشار قبل التنقل من BottomBar وRail وSidebar وورقة المزيد، وعند تغيير الفرع المؤسسي أو إجراء قائمة مستخدم معلّم بالحارس. يمنع طلب تنقل ثانياً أثناء الحوار.


## قوالب الصفحات والقشرة — عقود الاستخدام

- `AppPageHeader`: عند ضيق العرض يُكدَّس الإجراء الأساسي تحت العنوان. شريط الإجراء السفلي ليس مسؤولية الرأس؛ يتولاه قالب الصفحة.
- `FormPageTemplate` (T3) و`DashboardTemplate` (T5) يستعملان `AppPageState` الموحد لحالات المحتوى والتحميل والفراغ والخطأ. عند غياب `errorKey` يظهر `TemplateKeys.defaultError`.
- جسم T3 العادي يلتف في تمرير رأسي؛ إذا مررت الشاشة `ScrollView` مثل `ListView` فيُستخدم كما هو لتجنب تمرير متداخل. زر الحفظ السفلي هو إجراء T3 الأساسي، ويعطله `saving` ويعرض التحميل.


## تحديث القشرة والشارات — 2026-11-19

- حارس AppShell: تبديل الفرع غير النشط لا يفتح حواراً ويحافظ على حالة FormPageTemplate داخل indexedStack؛ إعادة اختيار التبويب النشط تستدعي الحارس. تسجيل الخروج وتغيير فرع المؤسسة محروسان.
- beforeDestinationChange == false يرفض التنقل نهائياً بلا حوار. في تغيير فرع المؤسسة يُستدعى beforeBranchChange للمالك أولاً ثم الحارس. confirmBranch لا يتلف النموذج؛ discardBranch لا يعمل إلا بعد نجاح الانتقال الفعلي.
- أزيل زر الرجوع الذي كان يمرر context.pop() من AppShell؛ الصفحة/المسار يملك زر الرجوع حتى لا يتجاوز PopScope.
- C02: AppBadge وDocStatusBadge في core/presentation/widgets/app_badge/ (L1). DocStatusBadge يستعمل AppBadge؛ ScopeSelector (C12) يستعمل AppBadge لشارة «عرض فقط»، وAppShell (C46) يصل إليه عبر ScopeSelector.
- AppBadge variants: AppBadgeTone (neutral/success/warning/info/error) وAppBadgeSize (small/medium)، ويحل AppBadgeStyle الألوان والحجم والمسافات من semantic colors وtokens.
- اختبارات AppBadge وDocStatusBadge وحارس التنقل أُضيفت؛ تشغيل indexedStack واختبارات الحارس لم يُتحقق منهما بعد لأن CI توقف عند فحص format. لا يُدّعى اختبار ويب بصري أو جوال أو Windows.


## توثيق C02 وC46 — 2026-11-19

- AppBadge وDocStatusBadge مكوّنا L1 في `core/presentation/widgets/app_badge/`. AppBadge يدعم neutral/success/warning/info/error وsmall/medium وأيقونة اختيارية مع AppKey إلزامي؛ DocStatusBadge يجهّز حالات المستند والسداد والحالة غير المعروفة المحايدة.
- الاستخدام الحالي: C12 ScopeSelector يعرض شارة view-only عبر AppBadge؛ C46 يصل إليه عبر C12. CAT-07 لم يُبنَ بعد.
- سلوك C46: إعادة اختيار الفرع النشط تستدعي الحارس ثم تعيد initial location؛ الفرع غير النشط لا يستدعي الحارس ويحافظ على indexedStack. رفض المالك نهائي، وbeforeBranchChange للمالك يسبق الحارس. لا زر رجوع في Shell، ولا discard إلا بعد الانتقال الفعلي.


## Catalog list UI — 2026-11-19

- `core/presentation/widgets/app_searchable_dropdown/`: `SearchableDropdown<T>` (L2) يوفّر اختياراً مفرداً عاماً، بحثاً محلياً أو callback remote debounce، subtitle/add-new slots، حالات loading/error/empty/disabled/readOnly، وواجهة desktop keyboard/mobile BottomSheet. تحديث options لا يغيّر نص البحث أو التركيز ولا يفرض إعادة تركيب RawAutocomplete.
- `core/presentation/widgets/app_filter_bar/`: `FilterBar` (L3) يعرض البحث عبر AppTextField والمرشحات النشطة كـ AppBadge قابل للإزالة مع namedArgs للترجمة، ويدعم مسح الكل؛ محرر الفلاتر يحقن من الشاشة عبر slot. لا يملك استعلامات.
- `core/presentation/widgets/app_data_table/`: `AppDataTable<T>` (L3) ثلاث تمثيلات حسب عرض الحاوية: cards أقل من 600، compact 600–1199، full من 1200؛ الفرز والترقيم callbacks للمالك/server، مع قائمة فرز BottomSheet للهاتف، selection وrow actions وsummary slots. حجم الصفحة من `AppConfig.pageSizeOptions`.
- `ListPageTemplate` أضيف إلى `app_page_template/app_page_templates.dart` (L4) ويجمع `AppPageHeader`, `FilterBar`, `AppDataTable`, `AppSkeleton`, `AppEmptyState`. في حالة الخطأ يترك عرض البانر وRetry لـ AppDataTable حتى لا يتكرر المصدر.
- `AppPageBody` (`app_page_body/app_page_body.dart`): إطار الصفحة الموحد؛ حشوة متجاوبة، وعرض أقصى مركزي، وتمرير عمودي واحد. `ListPageTemplate` يعتمد عليه، وتنتقل إليه بقية القوالب في مراحل لاحقة من [خريطة الإصلاح](../design/UI_REMEDIATION_ROADMAP.md). المحتوى بارتفاع غير محدود: لا `Expanded` مباشرة داخله.
- `AppDataTable` يدعم ارتفاعاً غير محدود (داخل `AppPageBody`) بلا تغيير في سلوكه عند ارتفاع محدود.
- لا مكوّن متصل بـ Supabase أو منطق أعمال. لا شاشة CAT-07 أو ADM-01/02 أُنشئت في هذا التحديث.


### استجابة C04/C10/C01/T1 — توضيح 2026-11-19

- C04 يبقي TextEditingController وFocusNode على سطح المكتب ويحدّث خيارات RawAutocomplete دون تعديل controller داخل fieldViewBuilder أو إعادة تركيب المنتقي؛ وعلى الهاتف يستهلك BottomSheet ValueListenable لحالة options/loading/error حتى تظهر نتائج البحث البعيد أثناء بقاء الورقة مفتوحة.
- C10 يقبل `filterControls` كعناصر يمررها مالك الصفحة (ومنها SearchableDropdown C04) أو `filterPanelBuilder`؛ على الهاتف يفتح أياً منهما داخل ورقة سفلية قابلة للتمرير.
- C01 في الهاتف يعرض Load more عبر callback `onLoadMore/hasMore`؛ التابلت/سطح المكتب يعرضان page/pageSize callbacks. صفوف الجدول قابلة للتنقل بلوحة المفاتيح، وEnter ينفذ `onRowActivated` وSpace يبدل التحديد.

- C01 يستخدم AppCard الموجود لبطاقات الهاتف بدلاً من إنشاء Card style موازٍ؛ `cardBuilder` يخصص المحتوى مع بقاء selection/actions slots مستقلة.


### تحديث جودة Catalog UI — 2026-11-19

- AppTextField أضيفت له callbacks وواجهات focusNode/autofocus ليستعمله البحث وRawAutocomplete مع بقاء إدارة التركيز واضحة.
- AppBadge يدعم namedArgs وإجراء إزالة اختياري؛ استعملته FilterBar لشارات الفلاتر النشطة.
- AppDataTable يوفّر فرز الهاتف عبر BottomSheet، ويستخدم مفتاح paginationLabel واحداً مع page/lastPage.
- ListPageTemplate لا يكرر بانر الخطأ أو Retry؛ AppDataTable هو مالك حالة الخطأ في صفحات القوائم.
