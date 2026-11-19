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
| حالة فارغة | `AppEmptyState` مع `AppKey` و`AppIconData` وslot اختياري لـ `AppButton` | `widgets/app_empty_state/app_empty_state.dart` |
| هيكل تحميل | `AppSkeleton.line/block/card/tableRow` | `widgets/app_skeleton/app_skeleton.dart` |
| رسالة للمستخدم | `MessageViewWidgets.showMessage` | `widgets/app_message/message_view_widgets.dart` |
| نصاً مترجماً | `AppKey` من enum القسم (`CommonKeys` أو `AuthKeys` مثلاً) | `localization/keys/` أو `features/<feature>/presentation/localization/` |
| طلب شبكة | `IApiClient` + `<Feature>Endpoints` | `network/` + `features/<f>/data/` |
| تحويل خطأ | `ExceptionMapper` ثم `Failure.messageKey` | `error/` |
| إعداداً أو قيمة بيئة | `AppConfig` | `foundation/config/app_config.dart` |
| تحققاً من حقل نموذج | `AppValidator` | `foundation/validation/app_validator.dart` |
| مبلغاً مالياً أو تنسيقه | `Money` + `AmountFormatter` | `foundation/money/` |
| تخزيناً | `PrefsStorageService` / `SecureStorageService` / Hive | `storage/` |
| تنقلاً | `<Feature>Routes` + GoRouter | `features/<f>/presentation/routing/` |
| صلاحية | `AccessCubit` (لقطة الخادم) + `PermissionGate` / `context.can` | `access/` |

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
- `AppColors.x` أو `AppLightColors.x` أو `AppDarkColors.x` في الواجهة (للثيم فقط) ← `context.ui.theme`.
- `Theme.of(context).colorScheme` ← `context.ui.theme.colors`.
- `context.isDark` / `context.colors` / `context.themeColor` (الامتداد القديم المحذوف) ← `context.ui.theme.isDark` / `colors` / `value(dark:, light:)`.

## 2. النصوص

```dart
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';

AppText(CommonKeys.save, type: AppTextType.titleMedium); // نص مترجم
AppText.raw(user.name); // نص بيانات (غير مترجم)

// عند الحاجة إلى TextStyle فقط:
final style = context.ui.text.of(AppTextType.bodyLarge);
```

- `AppText` يدعم أيضاً `AppText.rich` و`AppText.selectable`.
- أحجام خارج الأدوار: `context.ui.text.size(AppFontSize.lg)` أو `context.ui.text.style(AppFontSize.lg, weight: ...)`.
- لا تغيّر `letterSpacing` عن `0` (يكسر وصل الحروف العربية).

**ممنوع / قديم ← البديل**
- `Text('...')` لنص واجهة ← `AppText` / `AppText.raw`.
- `'key'.tr()` ونصوص ثابتة ← `AppKey` من enum القسم (أضف القيمة، راجع §7).
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
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';

AppButton(CommonKeys.save, onPressed: onSave); // مترجم
AppButton.raw('Save', onPressed: onSave); // نص خام
AppButton(CommonKeys.cancel, variant: AppButtonVariant.outlined, onPressed: onCancel);
AppButton(CommonKeys.save, isLoading: state.isBusy, onPressed: onSave);
```

**حالة فارغة وهيكل تحميل:** مرّر `AppKey` للنصين و`AppIcons.*` للأيقونة إلى `AppEmptyState`؛ لا تستخدم نصوصاً خاماً. مرّر `AppButton(AppKey, ...)` في slot الإجراء. استخدم `AppSkeleton` بالشكل الذي يحافظ على أبعاد المحتوى المتوقع. كلا المكوّنين قيد المراجعة حتى ربطهما بالشاشات الطيّارة AUTH-04 وCAT-07.

**متى Core Widget ومتى Flutter Widget؟**
- Core Widget عندما يغطي الحاجة: `AppText` للنص، `AppButton` للأزرار، `AppIcon` و`AppImage` للأيقونات والصور، `AppPageAppBar` و`AppCard` للتجميع، و`AppNavigationBar`/`AppNavigationRail`/`AppSidebar` للتنقل. أبعاد وسُمك الحدود دائماً من التوكنز (`AppSpacing` و`AppRadius` و`AppBorderWidth`...) لا بأرقام حرفية.
- Flutter Widget مباشرة للتخطيط الهيكلي (`Row` و`Column` و`Stack` و`Expanded` و`Padding` و`Scaffold` و`ListView`...) ولما ليس له مقابل في Core، مع قيم من `context.ui` والثيم.
- لا تبنِ زراً/نصاً/شريط تنقل مشتركاً بديلاً.

## 6. الرسائل

```dart
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';

// SnackBar بمفتاح ترجمة (المفضل: تُترجم وقت العرض):
MessageViewWidgets.showMessage(context, messageKey: AuthKeys.signInSuccess, type: MessageType.success);

// Dialog:
MessageViewWidgets.showMessage(
  context,
  messageKey: failure.messageKey,
  titleKey: ErrorKeys.unexpected,
  type: MessageType.error,
  isDialog: true,
);

// تحميل ثم إغلاق:
MessageViewWidgets.showMessage(context, messageKey: CommonKeys.loading, type: MessageType.loading);
MessageViewWidgets.hideMessage(context); // يُخفي نافذة الرسالة فقط، لا يغلق الصفحة أبداً
```

خطأ داخل النموذج (بدل SnackBar زائل)، من `Failure` مباشرة:

```dart
if (state.failure case final failure?)
  MessageViewWidgets.failureBanner(failure, onDismiss: cubit.clearError),

// أو رسالة بمفتاح ترجمة:
const InlineBanner(
  variant: InlineBannerVariant.warning,
  messageKey: AuthKeys.someKey,
)
```

لا تمرّر نص الخادم أو رسالة استثناء إلى `message:`/`title:` ولا إلى أي نص ظاهر.

- الأنواع: `error` (من `colors.error`) و`success` و`warning` و`info` (من `semanticColors`) و`loading`.
- `message: 'نص جاهز'` (String) مقبول للتوافق فقط؛ فضّل `messageKey`.

استهلاك Effect يحمل `AppKey` (النمط المعتمد؛ الترجمة وقت العرض، فتحترم اللغة الحالية):

```dart
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/effect/auth_effect.dart';

BlocEffectListener<AuthFlowEffect, AuthFlowCubit>(
  onEffect: (context, effect) => effect.whenOrNull(
    showMessage: (key, type) =>
        MessageViewWidgets.showMessage(context, messageKey: key, type: type),
    navigateToHome: (_) => context.go(HomeRoutes.home.path),
  ),
  child: const LoginBody(),
)
```

- الـ Effect أحادي الاستخدام (راجع §10)، والتنقل بعده عبر GoRouter و`<Feature>Routes`، لا `Navigator.pushNamed` ولا مسار نصي حرفي.

## 7. الترجمة

```dart
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/validation_keys.dart';
import 'package:accounting_software/app/features/auth/presentation/localization/auth_keys.dart';

AppText(AuthKeys.signIn); // في الودجت
final s = AuthKeys.signIn.tran; // String عند الحاجة فقط
final t = ValidationKeys.fieldMinLength.tr(namedArgs: {'length': '8'}); // مع متغيرات
```

- نص جديد: أضف قيمة إلى enum القسم المناسب، مع `ar` و`en` إلزاميين؛ المفتاح مشتق من اسم القيمة.
- قسم/ميزة جديدة: أنشئ `enum XKeys implements AppKey` في مجلدها، ثم أضف `...XKeys.values` إلى `lib/app/localization/key_registry.dart`.
- لا تنشئ `app_keys.dart` أو ملفي `app_ar.dart` و`app_en.dart`؛ تفاصيل التسجيل والاختبارات في [LOCALIZATION.md](LOCALIZATION.md).
- اللغة: `LocaleCubit`/`AppLanguage`/`AppSettingsManager`؛ لا locale provider مستقل.
- **مدخل الاتجاه الموصى به لهذا الدليل:** `context.ui.dir.isRTL` و`context.ui.dir.icon(rtl:, ltr:)` و`context.ui.dir.value(rtl:, ltr:)` و`context.ui.dir.transformFlip(...)`؛ وهو جزء من مدخل `context.ui` الموحد. يوجد أيضاً `DirectionExtension` في `localization_extension.dart`، لكنه يكرر بعض الوظائف بأسماء مختلفة ولا يُستخدم في ملفات الميزات المفحوصة (باستثناء مثال معلّق)، كما أن `transformFlip` فيه لا يطابق سلوك `context.ui.dir` عندما تكون `isRtlChild: false`؛ لذلك لا يُعد بديلاً متوافقاً بالكامل ولا يُنصح به في كود جديد. اختيار المدخل الموحد هنا مقترح توثيقي ينتظر موافقتك.
- **ممنوع:** `'string'.tr()` ونصوص واجهة ثابتة وقاموس ترجمة خاص بميزة.

## 8. الشبكة والأخطاء

```dart
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/auth/data/auth_endpoints.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';

final result = await apiClient.get<UserModel>(
  AuthEndpoints.user,
  fromJson: UserModel.fromJson,
  requiresAuth: true,
);
final either = result.toEither();   // Either<Failure, UserModel>
```

- `IApiClient` يُحقن من GetIt؛ لا Dio جديد داخل Feature. أضف المسارات إلى `<feature>_endpoints.dart` الخاص بميزتك، وأي جزء ديناميكي يمر بـ `encodePathSegment` (من `api_end_points.dart` في core).
- مسار الأخطاء: Data يرمي `AppException` ← `ExceptionMapper.map(e)` يعيد `Failure` ← اعرض `failure.messageKey` عبر `AppText`/`MessageViewWidgets`. لا تترجم داخل Repository.
- `FailureTranslator.translate(failure)` فقط حيث يلزم `String` جاهز (يترجم مرة واحدة).
- لا يوجد Realtime فعّال: `RealtimeClient` عقد مجرد فقط.
- سياسة Retry وidempotency، بما فيها السماح بإعادة عمليات الكتابة، موضحة في [قواعد المعمارية §6](ARCHITECTURE_RULES.md).

## 9. الإعدادات والتحقق من المدخلات

```dart
import 'package:accounting_software/app/core/foundation/config/app_config.dart';

final size = AppConfig.defaultPageSize;                 // 25
final chosen = AppConfig.resolvePageSize(userChoice);   // 10 أو 25 أو 50 أو 100، وغيرها يرجع للافتراضي
final options = AppConfig.pageSizeOptions;              // لقائمة الاختيار في ترقيم الجدول
final clientId = AppConfig.googleClientId;   // مدخل واحد؛ لا تستورد EnvConfig في Feature
```

التحقق من حقول النماذج (`AppValidator`، رسائله `AppKey`):

```dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/localization/keys/field_keys.dart';
import 'package:accounting_software/app/core/localization/keys/validation_keys.dart';

// بريد إلكتروني: AppTextField هو الودجت المعتمد داخل Features.
AppTextField(
  controller: emailController,
  labelKey: FieldKeys.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.email],
  ),
)

// كلمة مرور: القاعدة المركبة password تطبق الحد الأدنى وبقية شروط كلمة المرور.
AppTextField(
  controller: passwordController,
  labelKey: FieldKeys.password,
  obscureText: true,
  validator: (value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.password],
    params: {ValidationRule.minLength: 8},
  ),
)

// تطابق حقلين: مرّر قيمة الحقل الآخر في params.
AppTextField(
  controller: confirmPasswordController,
  labelKey: FieldKeys.confirmPassword,
  obscureText: true,
  validator: (value) => AppValidator.validate(
    value,
    [ValidationRule.required, ValidationRule.match],
    params: {ValidationRule.match: passwordController.text},
  ),
)
```

- استخدمه لقواعد الحقول العامة (مطلوب، بريد، طول، هاتف، كلمة مرور، تطابق). يمكن تخصيص رسالة قاعدة عبر `customKeys` بتمرير قيمة موجودة من enum يطبق `AppKey`، مثل `ValidationKeys.required`؛ لا تنشئ `AppKey` من سلسلة.
- لا تستخدمه لقواعد أعمال أو محاسبية (مكانها Domain/Use Case). لا تنشئ validator موازياً. `ValidationRule.async` محجوزة وغير منفذة في `validate()`.

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

- مسار جديد: عرّفه في `<feature>_routes.dart` الخاص بميزتك وأضفه إلى `all` (وأضف `...<Feature>Routes.all` إلى `lib/app/routing/route_registry.dart` لميزة جديدة)، ثم صنّفه public/protected في `lib/app/routing/route_guards.dart` (اختبار `route_guards_test` يفشل إن نقص)، وابنِ وجهته في `AppRouter` (`lib/app/routing/app_go_router.dart`).
- التنقل: `context.go(<Feature>Routes.x.path)` أو `context.goNamed(<Feature>Routes.x.name)`. لا مسارات نصية حرفية ولا `Navigator` للصفحات.
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

## المبالغ المالية (Money وAmountFormatter)

```dart
import 'package:decimal/decimal.dart';
import 'package:accounting_software/app/core/foundation/money/amount_formatter.dart';
import 'package:accounting_software/app/core/foundation/money/money.dart';
import 'package:accounting_software/app/core/foundation/money/money_rounding.dart';

// القراءة من PostgREST (نص numeric أو رقم) دون المرور بـ double للنصوص:
final price = Money.fromRaw(row['amount'], currencyId);
final total = Money.sum(currencyId, lines.map((l) => l.price.times(l.qty)));

// التقريب من بيانات العملة في القاعدة، صراحةً:
final rounding = MoneyRounding.fromCurrencyRow(
  decimalPlaces: currency['decimal_places'] as int,
  roundingIncrement: currency['rounding_increment'],
  roundingMethod: currency['rounding_method'] as String,
);
final posted = total.rounded(rounding);

// العرض (C13): الرقم داخل عزل Bidi، والرمز خارجه:
final text = AmountFormatter.format(
  posted,
  currency: CurrencyDisplay.fromRounding(rounding, currencyId: currencyId, label: 'USD'),
);
```

- لا `double` في أي حساب مالي. جمع/طرح/مقارنة بين عملتين مختلفتين يرمي `CurrencyMismatchException`؛ التحويل بين العملات عبر `convert(rate:, toCurrencyId:)` بمعامل جاهز ثم `rounded`.
- `AmountFormatter` لا يجمع ولا يحوّل؛ يعرض ما يُعطى له. للرقم وحده: `AmountFormatter.formatDecimal(value, decimalPlaces: n)`؛ `bidiIsolate: false` لمخرجات لا تدعم محارف الاتجاه (CSV).
- ممنوع تسجيل قيم `Money` في `Logger`. القيم الرقمية JSON تمر بـ `double` قبل وصولها (دقة نحو 15 رقماً)؛ للمبالغ الكبيرة اطلب النص من الخادم.
- حالة التحقق: `NOT_RUN` (لم يُشغَّل Flutter). انظر [ADR-0005](ADR/0005-money-type-and-amount-formatter.md).

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


## الصلاحيات والوصول (C47)

- المصدر الوحيد هو `get_my_access()`; لا تنشئ دوراً افتراضياً ولا تستخدم `SystemRoles`.
- استدعاء البيانات يمر عبر `AccessRemoteDataSource` ← `AccessRepository` ← `GetMyAccessUseCase`، ويستخدم `IApiClient` و`AppEndpoint`.
- `AccessCubit.load()` بعد نجاح المصادقة؛ `retry()` عند الفشل؛ `clear()` عند logout أو sessionCleared. الحالة ليست جاهزة إلا بعد تحليل الرد كاملاً.
- افحص `AccessState.isReady` قبل إظهار وظائف محمية. `can(Permission)` يرجع false في initial/loading/failure.
- تغيير الفرع يتم عبر `selectBranch(id)` من الفروع المسموح بعرضها، ويعيد تحميل snapshot قبل اكتمال التبديل.
- لعمليات الكتابة استخدم `canOperate(Permission)` أو `PermissionGate(requiresOperation: true)`؛ فهي تجمع صلاحية الخادم مع `can_operate` للفرع المحدد. `canOperateInSelectedBranch` يعبّر عن حالة الفرع وحدها.
- مجموعات `Permissions` تطابق الأكواد الفعلية: `customers`/`suppliers` ↔ `parties.*`، و`purchases` ↔ `purchasing.*`، و`journal` ↔ `accounting.*`. لا تُنشئ `module.action` غير موجود في `KnownPermissionCodes`.
- `AccessStatusGate` يغلّف محتوى `AppShell` ويمنع عرضه حتى تصبح اللقطة جاهزة؛ عند الفشل يعرض رسالة مترجمة وزر `retry`.
- لا تخزن الصلاحيات محلياً؛ راجع ADR-0006.


## تحديث — استخدام القشرة والقوالب (2026-11-18)

- AppMenu: مرّر List<AppMenuEntry> مع AppKey لكل عنصر، واستعمله لقوائم المستخدم وإجراءات الصفوف.
- AppBreadcrumb: مرّر قائمة AppBreadcrumbItem؛ آخر عنصر هو موضع الصفحة الحالي. داخل AppShell يمكن تمرير breadcrumbBuilder الذي يستقبل GoRouterState ويعيد القائمة؛ عند غيابه تستعمل القشرة breadcrumbs الثابتة القديمة.
- AppPageHeader: عنوان AppKey، وعدد اختياري، وslot للإجراء الأساسي والفتات.
- FormPageTemplate هو T3 وDashboardTemplate هو T5. الشاشة المالكة تمرر المحتوى والحالة والبطاقات؛ لا تضع الصلاحيات أو منطق الأعمال داخل القالب.
- AppShell يقبل beforeBranchChange ليقرر صاحب الشاشة ما إذا كان تغيير الفرع مسموحاً بعد تأكيد C07. لا يعرف Shell شيئاً عن سلة البيع.
- على Windows يمرر AppRouter قدرة supportsCollapsibleSidebar من PlatformCapabilities وAppSettingsManager؛ لا يستعمل الويب هذه القدرة، ويبقى Sidebar موسعاً. زر الرجوع الداخلي يستخدم go_router.
- `UnsavedChangesGuard` يمرر من AppRouter إلى AppShell. FormPageTemplate يسجل نفسه تلقائياً عندما `dirty=true` داخل نطاق القشرة، ويستعمل ConfirmDialog نفسه لحارس PopScope ولتغيير الفرع/الوجهة.
- علّم عنصر قائمة المستخدم الذي يجب أن يطلب تأكيد التغييرات بـ `requiresUnsavedChangesCheck: true` (يُستخدم لتسجيل الخروج). يمكن للمالك تمرير `beforeDestinationChange` لتقرير السماح بتغيير الوجهة قبل سؤال الحارس.
- الحراسة تغطي التنقلات التي تمر عبر AppShell فقط. `context.go` البرمجي، وزر الرجوع في المتصفح، وتغيير الرابط يدوياً غير مغطاة في هذه الآلية.


## متابعة الاستخدام — 2026-11-19

- AppShell يستقبل الآن AppMenuEntry من AppRouter؛ العناصر الافتراضية تتيح الملف الشخصي وتسجيل الخروج.
- قائمة الجوال تعرض أول أربع وجهات ثم «المزيد» عند وجود أكثر من خمس وجهات؛ اختيار وجهة إضافية ينقل إلى فرع GoRouter الصحيح.
- ScopeSelector يعرض فقط الفروع التي تسمح canView بها، ويحدد viewOnly بحسب canOperate.
- FormPageTemplate وDashboardTemplate يعرضان EmptyState افتراضياً عند غياب البيانات، ويمكن للشاشة تمرير EmptyState مخصص.


## تحديث الاستخدام — AppBadge وحارس التنقل (2026-11-19)

مثال الشارة: AppBadge(label: BadgeKeys.posted, tone: AppBadgeTone.success, size: AppBadgeSize.small).
مثال حالة: DocStatusBadge(status: 'PARTIAL').
- استخدم AppBadge مع AppKey إلزامي؛ النغمة لا تحمل المعنى وحدها. DocStatusBadge يترجم حالات المستند والسداد المعروفة، ويعرض BadgeKeys.unknown بنغمة محايدة للحالة غير المعروفة.
- DocStatusBadge يستعمل AppBadge؛ C12 ScopeSelector يستعمل AppBadge لوسم view-only، وC46 AppShell يستعمل C12 في شريطه العلوي.
- التنقل إلى فرع غير نشط لا يستدعي الحارس. إعادة اختيار الفرع النشط، وتسجيل الخروج، وتغيير فرع المؤسسة تستدعيه. رفض beforeDestinationChange يوقف التنقل مباشرة؛ رفض beforeBranchChange من المالك يسبق الحارس. لا يُستدعى discard إلا بعد اكتمال الانتقال.
- إزالة leading الخاص بالقشرة تعني أن الصفحة/المسار مسؤول عن الرجوع؛ لا تستخدم context.pop() من AppShell لتجاوز PopScope.


## أمثلة استخدام Catalog UI — 2026-11-19

- `SearchableDropdown<String>(options: options, labelKey: CatalogUiKeys.chooseOption, optionLabel: (x) => x, value: selected, onChanged: onSelected)`؛ للبحث البعيد مرّر `filterLocally: false` و`onQueryChanged`، وحدّث `options` من مالك الحالة. استبدل قائمة الخيارات بقائمة immutable جديدة عند وصول النتيجة حتى تتحدث نتائج الويب والورقة السفلية.
- `FilterBar(onSearchChanged: cubit.search, activeFilters: chips, onClearAll: cubit.clearFilters, filterPanelBuilder: (context, apply) => FilterEditor(onApply: apply))`؛ الشاشة تملك قيم الفلاتر والاستعلام.
- `AppDataTable<Row>(columns: columns, rows: currentServerPage, rowId: (row) => row.id, onSort: cubit.sort, onPageChanged: cubit.goToPage, onPageSizeChanged: cubit.setPageSize)`؛ بطاقات الهاتف تستخدم AppCard، ويمكن تمرير `cardBuilder` للتخصيص.؛ على الهاتف مرّر `hasMore` و`onLoadMore`. لا تمرر كامل المجموعة ثم تطلب من الجدول فرزها محلياً.
- `ListPageTemplate(titleKey: ..., filterBar: filterBar, dataTable: table, state: AppPageState.content)`؛ يُستعمل كـ body داخل مساحة ذات ارتفاع محدود (مثلاً Expanded في Scaffold/Column).


## تحديث استخدام مكونات Catalog UI — مراجعة الجودة

- AppTextField يقبل onChanged للبحث، وfocusNode عند دمجه مع RawAutocomplete، وautofocus لحقل البحث داخل BottomSheet. يظل controller مملوكاً للصفحة/المكوّن الذي أنشأه.
- AppBadge يقبل labelArgs لمتغيرات AppKey، وonRemove مع removeLabel لإظهار شارة قابلة للإزالة. استخدم AppKey ذات placeholders متطابقة في ar/en.
- AppDataTable على الهاتف يعرض زر «ترتيب حسب» عندما يوجد onSort وأعمدة قابلة للفرز؛ اختيار العمود يرسل DataTableSort إلى المالك ولا ينفذ فرزاً محلياً.
- ListPageTemplate لا يملك بانر الخطأ أو Retry؛ عند state=error مرّر AppDataTable مع errorKey وonRetry، ليكون الجدول المصدر الوحيد للخطأ وإعادة المحاولة. عند loading/empty يتولى القالب حالة الصفحة ولا يعرض الجدول معها.

## تحديث استخدام Catalog UI — إصلاحات المراجعة 2026-11-19

- AppTextField يقبل `readOnly` و`onTap`. القراءة فقط تحتفظ بمظهر الحقل الفعّال، بخلاف `enabled: false` الذي يظهر رمادياً؛ استعملهما للحقل الذي يعرض قيمة ولا يُحرَّر نصاً (مثل زر فتح ورقة الاختيار).
- SearchableDropdown على سطح المكتب: النص المكتوب بحث فقط؛ عند فقدان التركيز يعود الحقل إلى نص القيمة المختارة (أو فارغاً)، ويُرسَل `onQueryChanged('')` لتحرير الاستعلام. زر المسح يستدعي `onChanged(null)` ويظهر افتراضياً (`clearable: true`)؛ مرّر `clearable: false` لحقل يجب أن يحمل قيمة دائماً (مثل عدد الصفوف في الجدول).
- حالات التحميل والخطأ و«لا نتائج» تظهر تحت الحقل لا داخل اللوحة (RawAutocomplete لا يعرض لوحة بلا خيارات)، ويظهر `onAddNew` في الحالة نفسها عند عدم وجود نتائج.
- على الهاتف يُعلن SearchableDropdown كزر واحد (التسمية + القيمة الحالية) بمظهر فعّال؛ حقل البحث وحقل FilterBar يعرضان زر «بحث» على لوحة المفاتيح، والإرسال يبحث فوراً دون انتظار debounce.
- AppBadge القابل للإزالة: مساحة لمس زر الإزالة لا تقل عن `AppComponentSize.hitArea` على الهاتف (تكبر الشارة هناك)، والنص يُقرأ مرة واحدة من تسمية الحاوية.

## AUTH-01: الدخول باسم المستخدم (قرار-66)

- `resolveLoginEmail` (domain) يحوّل اسم المستخدم إلى `username@<LOGIN_EMAIL_DOMAIN>` بأحرف صغيرة؛ وما فيه `@` يُرسَل كما كُتب. التحويل داخل `LoginUseCase` وحده، والنطاق يُحقن من `AppConfig.loginEmailDomain`.
- `AuthFlowCubit.signIn(identifier:, password:)` (بدل `signInWithEmail`). رفض الدخول يصل الصفحة كـ `SignInFailedEffect` فتعرضه في `InlineBanner` واحد (C38) فوق الحقول، ولا يُرسَل flash مكرر. بقية أخطاء المسارات الأخرى كما كانت.
- `AuthPageScaffold(header:)` لكتلة العلامة فوق العنوان؛ شعار v1 نص `vaude` بلا أصل صورة.
- مع `forgotPasswordEnabled = false` يظهر نص «تواصل مع مدير النظام» بدل رابط الاستعادة.
