# استخدام Core — أمثلة عملية

> اقرأ `CORE_MAP.md` أولاً، ثم افتح الملفات المشار إليها قبل نسخ أي مثال. الأمثلة التالية توضح نمط الاستخدام في الفرع الحالي وليست بديلاً عن التحقق من التوقيع الفعلي.

## 1. Responsive UI

استورد واجهة Responsive الموحدة:

```dart
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
```

استخدم Design Tokens بدلاً من قيم عشوائية متكررة:

```dart
Padding(
  padding: context.ui.padding.all(AppSpacing.md),
  child: content,
)
```

اختيار تخطيط حسب الجهاز (مثل AppShell):

```dart
context.ui.grid.widget(
  mobile: (_) => const MobileView(),
  tablet: (_) => const TabletView(),
  desktop: (_) => const DesktopView(),
)
```

اختيار تخطيط حسب المساحة الفعلية المتاحة للعنصر داخل الشاشة:

```dart
context.ui.grid.adaptive(
  mobile: (_) => const CompactContent(),
  tablet: (_) => const MediumContent(),
  desktop: (_) => const WideContent(),
)
```

الفرق مهم:
- `grid.widget` / `Rh.builder`: قرار على مستوى نوع الجهاز/الشاشة.
- `grid.adaptive` / `AdaptiveLayout`: قرار على قيود العرض الفعلية التي يمررها الأب عبر LayoutBuilder؛ استخدمه داخل الأعمدة واللوحات الجانبية.
- استخدم `ResponsiveMode.fixed` عندما تريد القيمة ثابتة، و`scaleOnly` للقياس المستمر لقيمة تصميم أساسية، و`adaptiveOnly` لاختيار Token حسب نوع الشاشة، و`adaptiveScale` للاستيفاء/القياس وفق Tokens. افحص defaults الخاصة بكل helper.

## 2. النصوص والأزرار المشتركة

```dart
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';

// ترجمة عبر AppKey:
AppText(AppKeys.common.save)

// نص خام:
AppText.raw('Save')

// زر مترجم:
AppButton(
  AppKeys.common.save,
  onPressed: onSave,
)

// زر بنص خام:
AppButton.raw('Save', onPressed: onSave)
```

قبل إنشاء Text أو Button مخصص مشترك، افحص AppTextType وAppButtonVariant/Size وملفات Style. لا تستخدم AppText لكل نص غني دون حاجة؛ افحص `AppText.rich` و`AppText.selectable` أيضاً.

## 3. Theme

```dart
final light = AppTheme.light();
final dark = AppTheme.dark();
```

في الواجهة استخدم ThemeData/ColorScheme الحاليين أو AppColors/AppTextStyles حسب الاستخدام القائم. تغيير الثيم للمستخدم يتم عبر ThemeCubit (مثل `changeTheme`, `setLightTheme`, `setDarkTheme`, `setSystemTheme`) وليس بإنشاء Theme manager جديد.

## 4. ApiClient ونتائج الشبكة

استخدم IApiClient المحقون من GetIt في Repository/مصدر البيانات، ولا تنشئ Dio جديداً:

```dart
final result = await apiClient.get<UserModel>(
  AppEndpoints.auth.user,
  fromJson: UserModel.fromJson,
);
```

تعامل مع ApiResult في Data layer، ثم حوّله إلى عقد Domain الموجود:

```dart
final either = result.toEither();
```

للنتائج التي تتطلب إجراءً غير متزامن عند النجاح، افحص `toEitherAsync`. أضف Endpoint إلى AppEndpoints عند الحاجة، مع الحفاظ على AppEndpoint encoding للمقاطع الديناميكية. لا تضع URL literals متكررة في كل Repository.

## 5. Failure وException

- ارمِ/أعد AppException المناسبة داخل Data layer وفق نمط المشروع.
- حوّلها مركزياً عبر `ExceptionMapper.map(exception)`.
- استخدم Failure المناسب من `failure.dart` في Domain/Presentation.
- لا تحوّل الاستثناء إلى نص UI داخل Repository؛ الترجمة تتم باستخدام AppKey/AppText.
- عند إضافة نوع Failure جديد، افحص ExceptionMapper وServerErrorMapper والاختبارات والمفاتيح الموجودة أولاً.

## 6. State management وEffects

إذا احتاج Cubit أحداث UI أحادية الاستخدام، افحص BaseCubit/EffectMixin أولاً:

```dart
class ExampleCubit extends BaseCubit<ExampleState, ExampleEffect> {
  ExampleCubit() : super(const ExampleState.initial());

  Future<void> save() async {
    // update state...
    emitEffect(const ExampleEffect.saved());
  }
}
```

لا تستخدم Effect لإيصال بيانات الحالة الدائمة؛ هذه مسؤولية State. استخدم replayable فقط للأحداث التي يظل عرضها صحيحاً لمستمع لاحق، وافحص مدة replayWindow وسلوك المستمع.

## 7. DI

- أضف تسجيل الخدمات العامة إلى `initCoreDI()` فقط إذا كانت جزءاً من البنية التحتية المشتركة.
- تسجيل كل Feature يبقى في ملف DI الخاص بها، ويُستدعى من `lib/app/app_di.dart`.
- افحص الاختبارات وعمليات التسجيل الحالية قبل إضافة تسجيل جديد.
- اختر `registerLazySingleton` أو `registerFactory` وفق دورة الحياة الفعلية، لا كقاعدة موحدة لكل Cubit.

## 8. Localization وStorage

- اللغة: استخدم AppLanguage/LocaleCubit/AppSettingsManager؛ لا تنشئ locale provider مستقلاً.
- الترجمة: أضف المفاتيح في بنية AppKey/AppKeys وملفات اللغات الحالية، لا في Map خاصة بميزة إذا كان النص جزءاً من نظام الترجمة.
- الإعدادات البسيطة: AppSettingsManager/PrefsStorageService.
- البيانات الحساسة: SecureStorageService/TokenManager.
- الكاش/الكائنات: افحص HiveStorageService/CacheManager.
- لا تضف Storage implementation قبل فحص StorageService والـ implementations الحالية.

## 9. Access وRouting

- إظهار عنصر بناءً على Permission: افحص PermissionGate أو AccessCubit.
- تحقق الصلاحية في التطبيق لا يغني عن RLS أو التحقق على الخادم.
- تعريف مسار جديد: AppRoutes، ثم راجع `lib/app/routing/route_guards.dart` لتصنيفه public/protected، وراجع AppGoRouter لبناء الوجهة.
- استخدم RouteTransitions وGoRouterRefreshStream الموجودين بدلاً من بناء بديل.

## 10. قاعدة ما قبل الإنشاء

قبل كتابة أي helper/widget/service جديد:
1. ابحث بالاسم وبالوظيفة في `lib/app/core`.
2. اقرأ التنفيذ الفعلي والاختبارات.
3. حدد هل توجد أداة تؤدي الوظيفة جزئياً ويمكن توسيعها بأمان.
4. إذا لم توجد، طبّق قواعد `ARCHITECTURE_RULES.md`.
5. أضف اختباراً وتحديثاً لهذه الوثائق عندما تضيف قدرة مشتركة.
