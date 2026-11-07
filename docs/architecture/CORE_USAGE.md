# استخدام Core — دليل عملي

> السؤال الذي يجيب عنه هذا الملف: **أريد تنفيذ وظيفة داخل Feature، فأي نظام أستخدم، ومن أي مسار، وكيف؟**
> اقرأ `CORE_MAP.md` لاكتشاف الأداة وموقعها، وافتح الملف المصدر وتحقق من التوقيع قبل نسخ أي مثال. السياسة المعمارية (متى نضيف إلى Core، حدود الطبقات، DI) في `ARCHITECTURE_RULES.md` ولا تتكرر هنا.

## جدول سريع: الوظيفة ← المدخل

| أريد | المدخل المعتمد | الاستيراد |
|---|---|---|
| لوناً من ColorScheme | `context.ui.theme.colors` | `responsive/extension/ui_extension.dart` |
| لوناً دلالياً (نجاح/تحذير/معلومة/مدين/دائن) | `context.ui.theme.semanticColors` | نفسه |
| لوناً حسب الوضع فاتح/داكن | `context.ui.theme.value(dark:, light:)` | نفسه |
| نصاً في الواجهة | `AppText` + `AppTextType` | `widgets/app_text/app_text.dart` |
| `TextStyle` متجاوباً | `context.ui.text.of(AppTextType)` | `ui_extension.dart` |
| مسافة/حشوة/زاوية/أيقونة/حجم | `context.ui.spacing/padding/radius/icon/size` | `ui_extension.dart` |
| تخطيطاً حسب الجهاز أو المساحة | `context.ui.grid.widget/adaptive` | `ui_extension.dart` |
| زراً | `AppButton` | `widgets/app_button/app_button.dart` |
| رسالة للمستخدم | `MessageViewWidgets.showMessage` | `widgets/app_message/message_view_widgets.dart` |
| نصاً مترجماً | `AppKeys` + `AppKey` | `localization/translations/` |
| طلب شبكة | `IApiClient` + `AppEndpoints` | `network/` |
| تحويل خطأ | `ExceptionMapper` ثم `Failure.messageKey` | `error/` |
| إعداداً أو قيمة بيئة | `AppConfig` | `foundation/config/app_config.dart` |
| تحققاً من حقل نموذج | `AppValidator` | `foundation/validation/app_validator.dart` |
| تخزيناً | `PrefsStorageService` / `SecureStorageService` / Hive | `storage/` |
| تنقلاً | `AppRoutes` + GoRouter | `routing/routes.dart` |
| صلاحية | `PermissionGate` / `context.can` | `access/` |

افتراضياً الاستيراد الأساسي للواجهات:

```dart
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
```

## 1. الألوان

```dart
final colors = context.ui.theme.colors;             // ColorScheme فقط
final semantic = context.ui.theme.semanticColors;   // success / warning / info / debit / credit

Container(color: colors.surface, child: ...);
Icon(Icons.check, color: semantic.success);
final shimmerBase = context.ui.theme.value(dark: darkColor, light: lightColor);
```

- لون الخطأ: `colors.error` (لا خطأ دلالي منفصل). `onSuccess` و`onWarning` و`onInfo` للنص فوق اللون الدلالي.
- `debit` و`credit` قيم مؤقتة (placeholder) بانتظار الهوية البصرية.
- القيم تتغير بين الفاتح والداكن تلقائياً؛ لا تتفرع بنفسك على `isDark` لتختار لوناً دلالياً.

**ممنوع / قديم ← البديل**
- `Colors.green` و`Color(0xFF...)` في الواجهة ← `semanticColors` أو `colors`.
- `AppColors.x` في الواجهة (للثيم فقط) ← `context.ui.theme`.
- `Theme.of(context).colorScheme` ← `context.ui.theme.colors`.
- `context.isDark` / `context.colors` / `context.themeColor` (الامتداد القديم المحذوف) ← `context.ui.theme.isDark` / `colors` / `value(dark:, light:)`.

## 2. النصوص

```dart
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';

AppText(AppKeys.common.save, type: AppTextType.titleMedium); // نص مترجم
AppText.raw(user.name); // نص بيانات (غير مترجم)

// عند الحاجة إلى TextStyle فقط:
final style = context.ui.text.of(AppTextType.bodyLarge);
```

- `AppText` يدعم أيضاً `AppText.rich` و`AppText.selectable`.
- أحجام خارج الأدوار: `context.ui.text.size(AppFontSize.lg)` أو `context.ui.text.style(AppFontSize.lg, weight: ...)`.
- لا تغيّر `letterSpacing` عن `0` (يكسر وصل الحروف العربية).

**ممنوع / قديم ← البديل**
- `Text('...')` لنص واجهة ← `AppText` / `AppText.raw`.
- `'key'.tr()` ونصوص ثابتة ← `AppKeys` (أضف المفتاح، راجع §7).
- `context.ui.text.h1()/body()/caption()/button()` (حُذفت) ← `context.ui.text.of(AppTextType.x)`.
- `TextStyle(fontSize: 14)` و`Theme.of(context).textTheme.x.fontSize` ← `AppTextType`.

## 3. المسافات والأبعاد

```dart
Padding(
  padding: context.ui.padding.all(AppSpacing.md),
  child: Column(
    children: [
      const AppText.raw('Title'),
      context.ui.spacing.gap(AppSpacing.sm),   // محور المسافة يُستنتج من Row/Column
      Icon(Icons.add, size: context.ui.icon.md),
    ],
  ),
)

Container(
  width: context.ui.size.width(AppComponentSize.medium),
  decoration: BoxDecoration(borderRadius: context.ui.radius.md),
)
```

- أيضاً: `ui.padding.symmetric/only/horizontal/vertical` و`ui.radius.top/bottom/corners` و`ui.spacing.value(...)` (رقم) و`ui.shadow.value/shadows`.

**ممنوع / قديم ← البديل**
- `SizedBox(height: 16)` و`EdgeInsets.all(16)` و`BorderRadius.circular(12)` برقم حرفي ← Tokens عبر `context.ui`.
- `context.spacing()` و`context.pad()` و`context.gap()` و`context.rad()` و`context.txt()` (امتداد `ResponsiveContextExtension` المحذوف) ← `context.ui.spacing.value` / `padding.*` / `spacing.gap` / `radius.*` / `text.style`.
- حسابات `MediaQuery` يدوية للأحجام ← `context.ui.screen` وTokens.

## 4. التخطيط المتجاوب

```dart
// حسب نوع الجهاز:
context.ui.grid.widget(
  mobile: (_) => const MobileView(),
  tablet: (_) => const TabletView(),
  desktop: (_) => const DesktopView(),
);

// حسب المساحة الفعلية للعنصر (داخل pane أو عمود):
context.ui.grid.adaptive(
  mobile: (_) => const CompactContent(),
  tablet: (_) => const MediumContent(),
  desktop: (_) => const WideContent(),
);

final columns = context.ui.grid.crossAxisCount();
if (context.ui.screen.isDesktop) { /* ... */ }
```

- `grid.widget` / `Rh.builder`: قرار على مستوى نوع الجهاز.
- `grid.adaptive` / `AdaptiveLayout`: قرار على قيود العرض التي يمررها الأب؛ للأعمدة واللوحات الجانبية.
- `ResponsiveMode`: `fixed` قيمة ثابتة، `scaleOnly` قياس مستمر، `adaptiveOnly` اختيار Token حسب الشاشة، `adaptiveScale` استيفاء/قياس. افحص الافتراضي لكل helper.
- حدود الشاشات في `ScreenEngine` (لا تنسخ أرقامها).

## 5. الودجتات المشتركة

```dart
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';

AppButton(AppKeys.common.save, onPressed: onSave); // مترجم
AppButton.raw('Save', onPressed: onSave); // نص خام
AppButton(AppKeys.common.cancel, variant: AppButtonVariant.outlined, onPressed: onCancel);
AppButton(AppKeys.common.save, isLoading: state.isBusy, onPressed: onSave);
```

**متى Core Widget ومتى Flutter Widget؟**
- Core Widget عندما يغطي الحاجة: `AppText` للنص، `AppButton` للأزرار، `AppIcon` و`AppImage` للأيقونات والصور، `AppPageAppBar` و`AppCard` للتجميع، و`AppNavigationBar`/`AppNavigationRail`/`AppSidebar` للتنقل. أبعاد وسُمك الحدود دائماً من التوكنز (`AppSpacing` و`AppRadius` و`AppBorderWidth`...) لا بأرقام حرفية.
- Flutter Widget مباشرة للتخطيط الهيكلي (`Row` و`Column` و`Stack` و`Expanded` و`Padding` و`Scaffold` و`ListView`...) ولما ليس له مقابل في Core، مع قيم من `context.ui` والثيم.
- لا تبنِ زراً/نصاً/شريط تنقل مشتركاً بديلاً.

## 6. الرسائل

```dart
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';

// SnackBar بمفتاح ترجمة (المفضل: تُترجم وقت العرض):
MessageViewWidgets.showMessage(context, messageKey: AppKeys.success.signin, type: MessageType.success);

// Dialog:
MessageViewWidgets.showMessage(
  context,
  messageKey: failure.messageKey,
  titleKey: AppKeys.errors.unexpected,
  type: MessageType.error,
  isDialog: true,
);

// تحميل ثم إغلاق:
MessageViewWidgets.showMessage(context, messageKey: AppKeys.common.loading, type: MessageType.loading);
MessageViewWidgets.hideMessage(context);
```

- الأنواع: `error` (من `colors.error`) و`success` و`warning` و`info` (من `semanticColors`) و`loading`.
- `message: 'نص جاهز'` (String) مقبول للتوافق فقط؛ فضّل `messageKey`.

استهلاك Effect يحمل `AppKey` (النمط المعتمد؛ الترجمة وقت العرض، فتحترم اللغة الحالية):

```dart
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/routing/routes.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/effect/auth_effect.dart';

BlocEffectListener<AuthFlowEffect, AuthFlowCubit>(
  onEffect: (context, effect) => effect.whenOrNull(
    showMessage: (key, type) =>
        MessageViewWidgets.showMessage(context, messageKey: key, type: type),
    navigateToHome: (_) => context.go(AppRoutes.home.path),
  ),
  child: const LoginBody(),
)
```

- الـ Effect أحادي الاستخدام (راجع §10)، والتنقل بعده عبر GoRouter و`AppRoutes`، لا `Navigator.pushNamed` ولا مسار نصي حرفي.

## 7. الترجمة

```dart
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';

AppText(AppKeys.auth.signIn); // في الودجت
final s = AppKeys.auth.signIn.tran;          // String عند الحاجة فقط
final t = AppKeys.valid.fieldMinLength.tr(namedArgs: {'length': '8'}); // مع متغيرات
```

- مفتاح جديد: عرّفه في `AppKeys` (`app_keys.dart`) ثم أضف نصه في `app_ar.dart` و`app_en.dart`.
- اللغة: `LocaleCubit`/`AppLanguage`/`AppSettingsManager`؛ لا locale provider مستقل.
- **مدخل الاتجاه الموصى به لهذا الدليل:** `context.ui.dir.isRTL` و`context.ui.dir.icon(rtl:, ltr:)` و`context.ui.dir.value(rtl:, ltr:)` و`context.ui.dir.transformFlip(...)`؛ وهو جزء من مدخل `context.ui` الموحد. يوجد أيضاً `DirectionExtension` في `localization_extension.dart`، لكنه يكرر بعض الوظائف بأسماء مختلفة ولا يُستخدم في ملفات الميزات المفحوصة (باستثناء مثال معلّق)، كما أن `transformFlip` فيه لا يطابق سلوك `context.ui.dir` عندما تكون `isRtlChild: false`؛ لذلك لا يُعد بديلاً متوافقاً بالكامل ولا يُنصح به في كود جديد. اختيار المدخل الموحد هنا مقترح توثيقي ينتظر موافقتك.
- **ممنوع:** `'string'.tr()` ونصوص واجهة ثابتة وقاموس ترجمة خاص بميزة.

## 8. الشبكة والأخطاء

```dart
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';

final result = await apiClient.get<UserModel>(
  AppEndpoints.auth.user,
  fromJson: UserModel.fromJson,
  requiresAuth: true,
);
final either = result.toEither();   // Either<Failure, UserModel>
```

- `IApiClient` يُحقن من GetIt؛ لا Dio جديد داخل Feature. أضف المسارات إلى `AppEndpoints` (المقاطع الديناميكية تُرمَّز تلقائياً).
- مسار الأخطاء: Data يرمي `AppException` ← `ExceptionMapper.map(e)` يعيد `Failure` ← اعرض `failure.messageKey` عبر `AppText`/`MessageViewWidgets`. لا تترجم داخل Repository.
- `FailureTranslator.translate(failure)` فقط حيث يلزم `String` جاهز (يترجم مرة واحدة).
- لا يوجد Realtime فعّال: `RealtimeClient` عقد مجرد فقط.
- سياسة Retry وidempotency، بما فيها السماح بإعادة عمليات الكتابة، موضحة في [قواعد المعمارية §6](ARCHITECTURE_RULES.md).

## 9. الإعدادات والتحقق من المدخلات

```dart
import 'package:accounting_software/app/core/foundation/config/app_config.dart';

final size = AppConfig.defaultPageSize;
final clientId = AppConfig.googleClientId;   // مدخل واحد؛ لا تستورد EnvConfig في Feature
```

التحقق من حقول النماذج (`AppValidator`، رسائله `AppKey`):

```dart
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';

TextFormField(
  validator: (value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.email],
  ),
)

TextFormField(
  obscureText: true,
  validator: (value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.password],
    params: {ValidationRule.minLength: 8},
  ),
)

// تطابق حقلين: مرّر قيمة الحقل الآخر
TextFormField(
  validator: (value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.match],
    params: {ValidationRule.match: passwordController.text},
  ),
)
```

- استخدمه لقواعد الحقول العامة (مطلوب، بريد، طول، هاتف، كلمة مرور، تطابق). رسالة مخصصة: `customKeys: {ValidationRule.required: AppKey('...')}`.
- لا تستخدمه لقواعد أعمال أو محاسبية (مكانها Domain/Use Case). لا تنشئ validator موازياً. `ValidationRule.async` غير منفذة بعد.

## 10. State management وEffects

```dart
class ExampleCubit extends BaseCubit<ExampleState, ExampleEffect> {
  ExampleCubit() : super(const ExampleState.initial());

  Future<void> save() async {
    // update state...
    emitEffect(const ExampleEffect.saved());
  }
}
```

- الـ Effect للأحداث أحادية الاستخدام؛ البيانات الدائمة في State. `replayable: true` فقط لما يبقى عرضه صحيحاً لمستمع لاحق (راجع `replayWindow`).
- في الـ Effects مرّر `AppKey` لا نصاً مترجماً.

## 11. DI

- خدمات Core العامة في `initCoreDI()` فقط. تسجيل كل Feature (وخدماتها الخاصة مثل `GoogleSignIn` للـ Auth) في DI الخاص بها، ويُستدعى من `lib/app/app_di.dart`.
- افحص عمر الكائن (`registerLazySingleton` أو `registerFactory`) ولا تعمّم قاعدة واحدة على كل Cubit.

## 12. التخزين

- إعدادات بسيطة: `AppSettingsManager` / `PrefsStorageService`.
- بيانات حساسة وTokens: `SecureStorageService` / `TokenManager`.
- كاش وكائنات: `HiveStorageService` / `CacheManager`؛ الصناديق عبر `HiveManager.openBox` وأسماؤها `HiveBoxNames` ومعرّفات الـ adapters `HiveBoxTypeId`.
- اتبع سياسة تخزين Tokens في [قواعد المعمارية §6](ARCHITECTURE_RULES.md).

## 13. التنقل والصلاحيات

- مسار جديد: عرّفه في `AppRoutes` وأضفه إلى `AppRoutes.all`، ثم صنّفه public/protected في `lib/app/routing/route_guards.dart` (اختبار `route_guards_test` يفشل إن نقص)، وابنِ وجهته في `AppRouter` (`lib/app/routing/app_go_router.dart`).
- التنقل: `context.go(AppRoutes.x.path)` أو `context.goNamed(AppRoutes.x.name)`. لا مسارات نصية حرفية ولا `Navigator` للصفحات.
- استخدم `RouteTransitions` و`GoRouterRefreshStream` الموجودين.
- الصلاحيات:

```dart
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/access/extensions/access_extension.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';

PermissionGate(permission: Permissions.sales.view, child: const SalesList());
if (context.can(Permissions.sales.create)) { /* داخل build فقط */ }
// في Use Case:
final check = accessCubit.require(Permissions.sales.post); // Right(unit) أو Left(PermissionFailure)
```

- إخفاء عنصر ليس حماية؛ التفويض الحقيقي في الخادم وRLS.

## 14. قاعدة ما قبل الإنشاء

قبل كتابة أي helper/widget/service جديد: ابحث في `CORE_MAP.md` ثم في `lib/app/core`، وإن لم تجد فطبّق معايير `ARCHITECTURE_RULES.md` §2 و§11، وأضف اختباراً وحدّث `CORE_MAP.md` (وهذا الملف عند تغيّر نمط الاستخدام).


## الأيقونات والأزرار والحقول (الدفعة C)

```dart
AppIcon(AppIcons.email, size: AppIconSize.md)

AppButton(AuthKeys.forgotPassword, variant: AppButtonVariant.text, onPressed: ...)
AppButton(AuthKeys.signIn, icon: AppIcons.google, onPressed: ...)

AppIconButton(AppIcons.visibility,
    tooltipKey: AuthKeys.showPassword, onPressed: toggle)

AppTextField(
  controller: c, labelKey: FieldKeys.email, prefixIcon: AppIcons.email,
  validator: (v) => AppValidator.validate(v, [ValidationRule.required]),
)

const AppDivider(labelKey: AuthKeys.orSignInWith)
Scaffold(appBar: AppPageAppBar(titleKey: ProfileKeys.title), ...)
```

تغيير أيقونة من Material إلى SVG = سطر واحد في `AppIcons`.

## رسائل تعيش بعد انتقال الصفحة

```dart
sl<FlashMessages>().post(AuthKeys.signOutSuccess, MessageType.success);
// يعرضها FlashMessageListener (موجود في AuthPageScaffold وAppShell)؛
// إن لم يوجد مستمع تنتظر وتُعاد لأول مستمع جديد.
```

## Cubit بأثر تنقل

```dart
BlocEffectListener<AuthFlowEffect, AuthFlowCubit>(
  onEffect: (context, effect) { if (effect is ResetCodeSentEffect) { ... } },
  child: ...,
)
```
