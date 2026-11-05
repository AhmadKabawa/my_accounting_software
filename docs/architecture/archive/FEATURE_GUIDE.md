# دليل بناء Feature جديدة

> السؤال الذي يجيب عنه هذا الملف: **أريد إضافة ميزة (وحدة) جديدة، فأي ملفات أنشئ، وفي أي مجلد، وبأي ترتيب، وكيف تتصل بـ Core؟**
>
> الملفات المرتبطة:
> - `ARCHITECTURE_RULES.md`: السياسة وحدود الطبقات (المرجع الوحيد للسياسة).
> - `CORE_MAP.md`: ما هو موجود في Core وأين.
> - `CORE_USAGE.md`: أمثلة استخدام أدوات Core.
> - `CORE_CONTRACT.md`: ما هو **إلزامي** استخدامه من Core ولماذا.
> - `CODING_STANDARDS.md`: أسلوب كتابة الكود.
> - `FEATURE_CHECKLIST.md`: قائمة التحقق قبل الدمج.
> - `KNOWN_GAPS.md`: فجوات معروفة في الكود الحالي (لا تنسخ منها).
>
> **تنبيه مهم:** ميزتا `auth` و`home` غير مكتملتين، فهما مصدر للأنماط الصحيحة فقط حيث يُذكر ذلك صراحة هنا. لا تنسخ شاشة `home` (ألوان وأرقام حرفية، واستدعاء `init()` مرتين). التزم بهذا الدليل وبـ `CORE_CONTRACT.md` أولاً.

---

## 1. مفهوم الميزة

الميزة = **قدرة أعمال واحدة** لها شاشاتها وحالتها ومستودعها (مثل: العملاء، فواتير البيع، المخزون). لا تجعل الميزة "مجلداً لكل ما لا نعرف أين نضعه" (راجع `ARCHITECTURE_RULES.md` §1).

### قاعدة التسمية الموحدة

اسم الميزة (snake_case) يتكرر في كل مكان، ليعرف المطوّر المكان دون بحث:

| المكان | مثال لميزة `customers` |
|---|---|
| مجلد الميزة | `lib/app/features/customers/` |
| وحدة الصلاحيات | `Permissions.customers` (موجودة سلفاً في `core/access/permissions.dart`) |
| مجموعة المسارات | `AppRoutes.customers` و`/customers` |
| مجموعة الـ endpoints | `AppEndpoints.customers` |
| مفاتيح الترجمة | `AppKeys.customers` (`customers.title`...) |
| صندوق Hive (إن وُجد) | `HiveBoxNames.customers` |
| دالة DI | `initCustomersDI()` |
| ملفات الاختبار | `test/features/customers/` |

---

## 2. الشجرة القياسية

```
lib/app/features/<feature>/
├── di/
│   └── <feature>_di.dart                      تسجيل كل اعتماديات الميزة
├── domain/                                    لا Flutter ولا Dio ولا Hive
│   ├── entity/<name>/<name>_entity.dart       كائنات الأعمال
│   ├── repositories/<feature>_repository.dart واجهة المستودع (abstract)
│   └── usecase/<verb>_<noun>_usecase.dart     حالة استخدام واحدة لكل عملية
├── data/
│   ├── models/<name>/<name>_model.dart        DTO (+ .freezed.dart / .g.dart)
│   ├── datasources/
│   │   ├── remote_data_source/                <feature>_remote_data_source.dart + _impl
│   │   └── local_data_source/                 فقط إن وُجد كاش أو تخزين محلي
│   └── repositories/<feature>_repository_impl.dart
└── presentation/
    ├── cubit/
    │   ├── <feature>_cubit.dart
    │   ├── states/<feature>_state.dart        (+ .freezed.dart)
    │   └── effect/<feature>_effect.dart       (+ .freezed.dart)
    ├── pages/<page>/<page>_screen.dart
    └── widgets/<name>.dart                    ودجتات خاصة بالميزة فقط
```

### متى يُحذف جزء من الشجرة؟

| نوع الميزة | الطبقات المطلوبة |
|---|---|
| واجهة فقط بلا بيانات خارجية (Splash، Onboarding) | `presentation` + `di` |
| تقرأ/تكتب بيانات (أي وحدة محاسبية) | الطبقات الثلاث كاملة + `di` |
| بلا كاش محلي | احذف `local_data_source/` |
| ميزة كبيرة فيها مفاهيم متعددة | قسّمها إلى ميزات فرعية: `features/sales/invoices/`، `features/sales/returns/`، لكل منها شجرتها، ويبقى DI واحداً للوحدة |

قاعدة الحذف: **لا تنشئ مجلداً فارغاً ولا طبقة بلا محتوى** (`AGENTS.md` §1). لكن إن كانت الميزة تتعامل مع بيانات فلا تحذف `domain`؛ هي مكان قواعد الأعمال المحاسبية.

---

## 3. مسؤولية كل طبقة وحدود اعتمادها

| الطبقة | تحتوي | تستورد من | **لا** تستورد |
|---|---|---|---|
| `domain` | Entity، واجهة Repository، UseCase، قواعد الأعمال والحسابات | `core/error` (Failure)، `core/foundation` (UseCase، NoParams)، `dartz` | Flutter، Dio، Hive، `data`، `presentation` |
| `data` | Model، DataSource، RepositoryImpl | `domain`، `core/network`، `core/storage`، `core/error`، `core/foundation` | `presentation` |
| `presentation` | Cubit، State، Effect، Screen، Widgets | `domain`، `core/presentation`، `core/localization`، `core/routing` | `data` مباشرة |
| `di` | تسجيل GetIt فقط | الطبقات الثلاث | لا منطق أعمال |

قواعد إضافية:
- **لا منطق أعمال داخل Widgets أو Cubit.** حساب إجمالي فاتورة أو خصم أو ضريبة مكانه Entity أو UseCase، والـ Cubit ينسّق فقط.
- Feature لا تستورد Feature أخرى. إن احتاجت ميزتان إلى شيء مشترك فهو إما يمر عبر Core (وفق شروط `ARCHITECTURE_RULES.md` §2) أو يُمرَّر عبر `app_di.dart`.
- الاستثناء الحالي: `AppRouter` و`route_guards.dart` يستوردان `AuthCubit` و`AuthState` (تنسيق الجلسة)، وهذا مقبول لأنهما خارج Core ويعملان كـ composition root للتنقل.

---

## 4. تدفق البيانات (سلسلة الطلب)

```
الذهاب:
Screen ──► Cubit ──► UseCase ──► Repository (واجهة Domain)
                                     │
                              RepositoryImpl ──► RemoteDataSource ──► IApiClient ──► Supabase
                                     │
                              (اختياري) LocalDataSource ──► Hive / Secure / Prefs

العودة:
ApiResult<Model>  ──[toEither / toEitherAsync + ExceptionMapper]──►  Either<Failure, Entity>
                                  │
                       UseCase يعيد Either كما هي
                                  │
              Cubit.fold:   نجاح ► emit(State)      فشل ► emit(State) + emitEffect(failure.messageKey)
                                  │
              Screen:  BlocBuilder يرسم State   +   BlocEffectListener ► MessageViewWidgets / التنقل
```

ما يعبر كل حدّ:

| الحد | النوع المار |
|---|---|
| DataSource ← IApiClient | `ApiResult<Model>` (لا يرمي استثناءات الشبكة) |
| Repository ← DataSource | `ApiResult<Model>` ثم يتحول إلى `Either<Failure, Entity>` |
| UseCase ← Repository | `Either<Failure, T>` |
| Cubit ← UseCase | `Either<Failure, T>` |
| Cubit → Screen | `State` (دائم) و`Effect` (أحادي الاستخدام) |

قواعد مرتبطة بالسلسلة:
- **الأخطاء:** DataSource يرجع `ApiFailure(AppException)`، والـ Repository يحوّلها مرة واحدة عبر `toEither()` أو `toEitherAsync()` (تستدعي `ExceptionMapper.map` داخلياً). أخطاء التخزين المحلي (`CacheException`) تُلتقط في Repository وتمر عبر `ExceptionMapper.map`.
- **الترجمة:** لا تترجم في أي طبقة قبل العرض. تمرّر الطبقات `failure.messageKey` (نوع `AppKey`) وتُترجم عند العرض.
- **Model ↔ Entity:** التحويل في Model (`toEntity()` و`fromEntity`)؛ الـ Domain لا يعرف الـ Model.

---

## 5. وصفة بناء Feature (خطوة بخطوة)

نفّذ الخطوات بهذا الترتيب. كل خطوة مرتبطة بـ Core، ولا تتجاوز أياً منها. المثال ميزة `customers`.

### الخطوة 0: قبل أي ملف

1. ابحث في `CORE_MAP.md` عن أداة تلبي حاجتك (شبكة، تخزين، ودجت...). `CORE_CONTRACT.md` يحدد ما هو إلزامي.
2. إن احتجت إلى قدرة غير موجودة في Core، فطبّق شروط `ARCHITECTURE_RULES.md` §2 (مستهلك ثانٍ أو مبرر تقني) قبل إضافتها إلى Core، وإلا أبقِها داخل الميزة.
3. إن كانت الميزة تتعامل مع **مبالغ مالية**: راجع `KNOWN_GAPS.md` (لا يوجد نوع Money في Core بعد). لا تبدأ منطق المبالغ باستخدام `double`.

### الخطوة 1: Entity (domain)

كائن أعمال غير قابل للتعديل، بلا أي اعتماد على JSON أو Flutter:

```dart
// domain/entity/customer/customer_entity.dart
import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  const CustomerEntity({required this.id, required this.name, this.phone});

  final String id;
  final String name;
  final String? phone;

  @override
  List<Object?> get props => [id, name, phone];
}
```

قواعد الأعمال البسيطة التي تخص الكائن وحده (مثل فحص حالة) تُكتب هنا كدوال/getters.

### الخطوة 2: Repository (واجهة) وUseCases (domain)

```dart
// domain/repositories/customers_repository.dart
import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import '../entity/customer/customer_entity.dart';

abstract interface class CustomersRepository {
  Future<Either<Failure, CustomerEntity>> getCustomer(String id);
  Future<Either<Failure, Unit>> deleteCustomer(String id);
}
```

```dart
// domain/usecase/get_customer_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';

class GetCustomerUseCase extends UseCase<CustomerEntity, GetCustomerParams> {
  GetCustomerUseCase({required this.repository});
  final CustomersRepository repository;

  @override
  Future<Either<Failure, CustomerEntity>> call(GetCustomerParams params) =>
      repository.getCustomer(params.id);
}

class GetCustomerParams extends Equatable {
  const GetCustomerParams({required this.id});
  final String id;
  @override
  List<Object?> get props => [id];
}
```

- **UseCase واحد لكل عملية.** عملية بلا معاملات تستخدم `NoParams` من `core/foundation/base/use_case.dart`.
- **الـ Cubit لا يستدعي Repository مباشرة أبداً.** UseCase هو نقطة تطبيق قواعد الأعمال والصلاحيات والتحقق قبل الاستدعاء. هذه القاعدة موحدة لكل العمليات (قراءة وكتابة) حتى لا يتعلم المطوّر قاعدتين.
- العمليات التي تغيّر بيانات مالية (ترحيل، عكس، اعتماد): الفحص والتحقق قبل الإرسال يُكتبان هنا، مع التذكير أن **التنفيذ الفعلي والتحقق النهائي في الخادم** (`AGENTS.md` §8).

### الخطوة 3: Endpoints (core، تعديل مركزي)

أضف مجموعة المسارات في `core/network/api_end_points.dart`:

```dart
abstract final class AppEndpoints {
  static const auth = _AuthEndpoints();
  static const customers = _CustomerEndpoints();   // ← سطر جديد
}

final class _CustomerEndpoints {
  const _CustomerEndpoints();
  static const String base = '/customers';
  AppEndpoint get list => const AppEndpoint(base);
  AppEndpoint byId(String id) => AppEndpoint('$base/${_seg(id)}');
}
```

- **كل مقطع ديناميكي يمر عبر `_seg`** (ترميز + رفض `.` و`..`). حالياً `_seg` معرّفة داخل `_ProductEndpoints` فقط؛ استخرجها إلى دالة على مستوى الملف عند إضافة ثاني كلاس (راجع `KNOWN_GAPS.md`).
- لا مسارات نصية حرفية داخل DataSource.

### الخطوة 4: Model (data)

```dart
// data/models/customer/customer_model.dart
@freezed
class CustomerModel with _$CustomerModel {
  const CustomerModel._();
  const factory CustomerModel({
    required String id,
    required String name,
    String? phone,
  }) = _CustomerModel;

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  CustomerEntity toEntity() =>
      CustomerEntity(id: id, name: name, phone: phone);
}
```

- بعد إنشاء الملف شغّل: `dart run build_runner build --delete-conflicting-outputs` (لا تعدّل ملفات `.freezed.dart`/`.g.dart` يدوياً).
- إن كان الكائن يُخزَّن في Hive: أضف `@HiveType(typeId: HiveBoxTypeId.xxx)` و`@HiveField(n)` وعرّف الـ typeId في `core/storage/hive/hive_box_names.dart` (`HiveBoxTypeId`) لتفادي التعارض.
- **المبالغ المالية:** لا `double` في Model ولا Entity (`AGENTS.md` §8). راجع `KNOWN_GAPS.md` للقرار المطلوب.

### الخطوة 5: DataSource (data)

```dart
// data/datasources/remote_data_source/customers_remote_data_source_impl.dart
class CustomersRemoteDataSourceImpl implements CustomersRemoteDataSource {
  const CustomersRemoteDataSourceImpl({required IApiClient apiClient})
    : _apiClient = apiClient;
  final IApiClient _apiClient;

  @override
  Future<ApiResult<CustomerModel>> getCustomer(String id, {CancelToken? cancelToken}) =>
      _apiClient.get<CustomerModel>(
        AppEndpoints.customers.byId(id),
        fromJson: CustomerModel.fromJson,
        cancelToken: cancelToken,
      );

  @override
  Future<ApiResult<Unit>> deleteCustomer(String id) =>
      _apiClient.delete(AppEndpoints.customers.byId(id));
}
```

- يعتمد على `IApiClient` فقط، **لا Dio مباشر ولا Interceptors جديدة**.
- يعيد `ApiResult`، ولا يترجم الأخطاء ولا يعرف `Failure`.
- القوائم: استخدم `getPaginated` (مع `PaginatedResult` و`PaginatedParser`) بدل بناء ترقيم خاص.
- `requiresAuth: false` فقط للمسارات العامة (مثل تسجيل الدخول).
- **عمليات الكتابة لا تُعاد تلقائياً** (`RetryInterceptor`). لا تضع `Options(extra: {'idempotent': true})` على عملية مالية إلا إذا ضمن الخادم idempotency حقيقياً.

### الخطوة 6: RepositoryImpl (data)

```dart
class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl({required CustomersRemoteDataSource remote}) : _remote = remote;
  final CustomersRemoteDataSource _remote;

  @override
  Future<Either<Failure, CustomerEntity>> getCustomer(String id) async =>
      (await _remote.getCustomer(id)).toEitherAsync((m) async => m.toEntity());

  @override
  Future<Either<Failure, Unit>> deleteCustomer(String id) async =>
      (await _remote.deleteCustomer(id)).toEither();
}
```

- `toEither()` للتحويل المباشر، و`toEitherAsync` عند الحاجة إلى خطوة غير متزامنة (حفظ في الكاش مثلاً).
- إن كان في الميزة تخزين محلي، التقط `CacheException` وحوّلها بـ `ExceptionMapper.map(e)` (انظر `AuthRepositoryImpl`).
- `AuthRepositoryImpl` يحتوي دالة `_execute` الخاصة بالتقاط الاستثناءات. عند الحاجة لها في ثاني مستودع، انقلها إلى Core (مستهلك ثانٍ فعلي، `ARCHITECTURE_RULES.md` §2) بدل نسخها.

### الخطوة 7: State وEffect (presentation)

**الفرق:** State = ما يبقى على الشاشة. Effect = حدث لمرة واحدة (رسالة، تنقل).

```dart
// presentation/cubit/states/customers_state.dart
part 'customers_state.freezed.dart';

@freezed
sealed class CustomerDetailsState with _$CustomerDetailsState {
  const factory CustomerDetailsState.initial() = CustomerDetailsInitial;
  const factory CustomerDetailsState.loading() = CustomerDetailsLoading;
  const factory CustomerDetailsState.loaded({required CustomerEntity customer}) = CustomerDetailsLoaded;
  // خطأ يجب أن يبقى ظاهراً مع زر إعادة محاولة: يحمل AppKey لا نصاً
  const factory CustomerDetailsState.failure({required AppKey messageKey}) = CustomerDetailsFailure;
}
```

```dart
// presentation/cubit/effect/customers_effect.dart
@freezed
sealed class CustomerDetailsEffect with _$CustomerDetailsEffect {
  const factory CustomerDetailsEffect.showMessage({
    required AppKey messageKey,
    required MessageType type,
  }) = _ShowMessage;
  const factory CustomerDetailsEffect.deleted() = _Deleted;
}
```

قاعدة الاختيار:
- فشل **تحميل** شاشة (يحتاج "إعادة المحاولة") ← `State.failure(messageKey)`.
- فشل **إجراء** (حفظ، حذف) أو نجاحه ← `Effect.showMessage`.
- الـ Effect يحمل `AppKey` ولا يحمل `String` مترجماً أبداً.
- `replayable: true` فقط لرسالة تبقى صحيحة لمن يستمع لاحقاً (مثل "انتهت الجلسة").

### الخطوة 8: Cubit (presentation)

```dart
class CustomerDetailsCubit
    extends BaseCubit<CustomerDetailsState, CustomerDetailsEffect>
    with CancellableMixin {
  CustomerDetailsCubit({required GetCustomerUseCase getCustomer})
    : _getCustomer = getCustomer,
      super(const CustomerDetailsState.initial());

  final GetCustomerUseCase _getCustomer;

  @override
  Future<void> close() {
    cancelRequests();          // يلغي الطلبات المرتبطة بعمر الـ Cubit
    return super.close();
  }

  Future<void> load(String id) async {
    emit(const CustomerDetailsState.loading());
    final result = await _getCustomer(GetCustomerParams(id: id));
    if (isClosed) return;      // لا emit بعد الإغلاق
    result.fold(
      (failure) => emit(CustomerDetailsState.failure(messageKey: failure.messageKey)),
      (customer) => emit(CustomerDetailsState.loaded(customer: customer)),
    );
  }
}
```

- يرث `BaseCubit<State, Effect>` دائماً (يضمن إغلاق Effects).
- لا تمرر Repository للـ Cubit، فقط UseCases.
- لإلغاء الطلب فعلياً مرّر `cancelToken` من الـ Cubit عبر `Params` إلى UseCase ثم Repository ثم DataSource. **هذا الربط غير منفّذ في `auth` اليوم** (راجع `KNOWN_GAPS.md`)، فنفّذه في كل ميزة فيها بحث أو قوائم.
- عنده أكثر من مسؤولية؟ قسّمه (Cubit لكل شاشة أو مسؤولية). تجنّب Cubit ضخم كما في `AuthCubit`.

### الخطوة 9: DI

```dart
// di/customers_di.dart
void initCustomersDI() {
  // Data
  sl.registerLazySingleton<CustomersRemoteDataSource>(
    () => CustomersRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<CustomersRepository>(
    () => CustomersRepositoryImpl(remote: sl()),
  );
  // Domain
  sl.registerLazySingleton(() => GetCustomerUseCase(repository: sl()));
  // Presentation
  sl.registerFactory(() => CustomerDetailsCubit(getCustomer: sl()));
}
```

ثم أضف الاستدعاء في `lib/app/app_di.dart` داخل `initServiceLocator()` بعد `initCoreDI()` (وقبل أي ميزة تعتمد عليها، مع توثيق الترتيب هناك).

**عمر الكائنات:**

| الكائن | التسجيل | السبب |
|---|---|---|
| DataSource / Repository / UseCase | `registerLazySingleton` | بلا حالة، ويُنشأ عند أول استخدام |
| Cubit لشاشة | `registerFactory` | لكل شاشة نسخة حالتها مستقلة، وتُغلق مع الشاشة |
| Cubit تشاركه عدة واجهات أو يعيش بعمر التطبيق (Auth، Access، Theme، Locale) | `registerLazySingleton` | الحالة مشتركة |

لا تسجّل Cubit حالته خاصة بصفحة كـ Singleton، ولا تسجّل Cubit مشتركاً كـ Factory.

تسجيل خدمة تخص الميزة فقط (مثل `GoogleSignIn` لـ Auth، أو صندوق Hive) يكون هنا في DI الميزة، وليس في `initCoreDI()`.

### الخطوة 10: الشاشة (presentation)

```dart
class CustomerDetailsScreen extends StatelessWidget {
  const CustomerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocEffectListener<CustomerDetailsEffect, CustomerDetailsCubit>(
      onEffect: (context, effect) => effect.whenOrNull(
        showMessage: (key, type) =>
            MessageViewWidgets.showMessage(context, messageKey: key, type: type),
        deleted: () => context.go(AppRoutes.customers.path),
      ),
      child: Scaffold(
        appBar: AppAppBar(progress: 1),   // راجع توقيعه قبل الاستخدام
        body: BlocBuilder<CustomerDetailsCubit, CustomerDetailsState>(
          builder: (context, state) => state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (c) => Padding(
              padding: context.ui.padding.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.raw(c.name, type: AppTextType.titleMedium),
                  context.ui.spacing.gap(AppSpacing.sm),
                  AppButton(AppKeys.common.retry, onPressed: () {}),
                ],
              ),
            ),
            failure: (key) => Center(child: AppText(key)),
          ),
        ),
      ),
    );
  }
}
```

قواعد الواجهة (كلها إلزامية، التفاصيل في `CORE_CONTRACT.md`):
- النصوص عبر `AppText` ومفاتيح `AppKeys`، والبيانات غير المترجمة عبر `AppText.raw`.
- الألوان والمسافات والزوايا عبر `context.ui` فقط، بلا `Colors.x` ولا أرقام حرفية.
- التخطيط المتجاوب عبر `context.ui.grid.widget` (حسب الجهاز) أو `context.ui.grid.adaptive` (حسب المساحة).
- الرسائل عبر `MessageViewWidgets` فقط.
- `BuildContext` بعد `await`: تحقق من `context.mounted`.
- **لا تستدعِ `cubit.load()` مرتين** (مرة في الراوتر ومرة في `initState` كما يحدث في `home`). مكان واحد فقط.
- كل `TextEditingController` و`ScrollController` و`StreamSubscription` يُغلق في `dispose`.
- حقول النماذج: `AppValidator.validate(value, [rules])`، ومع الحقول التي تحتاج رسالة مختلفة استخدم `customKeys`.
- إظهار/إخفاء عنصر حسب الصلاحية: `PermissionGate` أو `context.can(...)` داخل `build` فقط.

### الخطوة 11: المسارات (routing)

افعل **الخطوات الأربع كلها**، وإلا يفشل `route_guards_test`:

1. عرّف المسار في `core/routing/routes.dart` وأضفه إلى `AppRoutes.all`:
   ```dart
   static const customers = RouteItem('/customers', 'customers');
   static const customerDetails = RouteItem('/customers/:id', 'customerDetails');
   ```
2. صنّفه في `lib/app/routing/route_guards.dart`: `publicRoutes` (دون تسجيل دخول) أو `protectedRoutes`. الافتراضي أن أي مسار غير مصنّف يُمنع (deny by default).
3. ابنِ وجهته في `lib/app/routing/app_go_router.dart` (`_buildRoutes`):
   ```dart
   GoRoute(
     path: AppRoutes.customerDetails.path,
     name: AppRoutes.customerDetails.name,
     redirect: AccessRoutingLogic.require(Permissions.customers.view),
     pageBuilder: (context, state) => RouteTransitions.slide(
       context, state,
       BlocProvider(
         create: (_) => sl<CustomerDetailsCubit>()..load(state.pathParameters['id']!),
         child: const CustomerDetailsScreen(),
       ),
     ),
   ),
   ```
   - `BlocProvider(create: ...)` للـ Factory (يغلقه عند إغلاق الشاشة). `BlocProvider.value` فقط لـ Cubit مسجّل Singleton.
   - تحويلات الصفحات من `RouteTransitions` (`fade`، `slide`)، ولا تنشئ transitions خاصة.
   - المعاملات الديناميكية من `state.pathParameters`. ومسار أخص (`/customers/add`) يُعرَّف **قبل** `/customers/:id` في نفس المستوى.
4. إن كانت الميزة تبويباً في الشاشة الرئيسية: أضف `AppDestination` في `lib/app/shell/destinations.dart` (مع `permission` إن لزم) وفرع `StatefulShellBranch` المقابل في الراوتر. يجب أن يتساوى عدد الوجهات مع الفروع (`AppShell` يتحقق في debug).

التنقل من الكود: `context.go(AppRoutes.x.path)` أو `context.goNamed(...)`. لا مسارات نصية حرفية ولا `Navigator`.

### الخطوة 12: الترجمة

لكل نص يراه المستخدم:

1. أضف `AppKey` في كلاس مجموعته داخل `core/localization/translations/app_keys.dart`:
   ```dart
   static const customers = _CustomerKeys();     // في AppKeys
   final class _CustomerKeys {
     const _CustomerKeys();
     final title = const AppKey('customers.title');
   }
   ```
2. أضف النص في **الملفين** `app_ar.dart` و`app_en.dart` (مجموعة جديدة تُضاف إلى الخريطة المجمّعة `enUS`/المقابل العربي).
3. **كل مفتاح له سلسلة نص فريدة.** لا تعيد استخدام سلسلة مفتاح موجود لمعنى مختلف (هذا ما حدث مع `profileUpdated`، راجع `KNOWN_GAPS.md`).
4. المتغيرات: `@name` داخل النص و`key.tr(namedArgs: {'name': ...})`.

### الخطوة 13: الصلاحيات

- الوحدة موجودة غالباً في `core/access/permissions.dart` (`Permissions.customers`). وحدة جديدة = سطر واحد هناك.
- أضف الصلاحيات الافتراضية للأدوار في `SystemRoles` (`core/access/role.dart`) عند الحاجة.
- **هذه الطبقة لتجربة المستخدم فقط.** التفويض الحقيقي في الخادم وRLS. لا تعتمد على إخفاء الأزرار كحماية.
- في UseCase: `accessCubit.require(Permissions.sales.post)` يعيد `Right(unit)` أو `Left(PermissionFailure)`.
- على مسار: `AccessRoutingLogic.require(Permission)` كـ `redirect` (مثال في الخطوة 11).

### الخطوة 14: التخزين المحلي (إن لزم)

| ما تخزّنه | الأداة |
|---|---|
| إعداد بسيط | `PrefsStorageService` أو `AppSettingsManager` |
| توكن أو سرّ | `SecureStorageService` / `TokenManager` (لا SharedPreferences أبداً) |
| كائنات وكاش | `HiveStorageService` / `HiveObjectBox<T>` / `CacheManager` |

- افتح صندوق Hive في DI الميزة: `await HiveManager.openBox<T>(HiveBoxNames.x, adapter: ...)`، وأضف اسمه في `HiveBoxNames` ومعرّف النوع في `HiveBoxTypeId`.
- مفاتيح التخزين من `StorageKeys` المركزية.
- بيانات الميزة المحلية تُمسح عند الخروج؟ اربطها بـ `sessionCleared` (انظر `AuthCubit` و`app_di.dart` كيف يُمسح `AccessCubit`).

### الخطوة 15: الاختبارات

مرآة المسارات: `test/features/<feature>/...`.

| ما تختبره | الأسلوب |
|---|---|
| UseCase | Fake Repository يعيد `Right`/`Left` |
| RepositoryImpl | Fake DataSource يعيد `ApiSuccess`/`ApiFailure` ويتحقق من التحويل إلى `Failure` الصحيح |
| Cubit | Fake UseCases، والتحقق من تسلسل الـ States وما أُرسل من Effects (انظر `test/features/auth/auth_cubit_session_test.dart` للنمط) |
| Model | `fromJson` وتحويل `toEntity` |
| قواعد الأعمال والحسابات | حالات طبيعية وحدية ومبالغ كبيرة وأخطاء |
| الشاشة | Widget test عند وجود منطق عرض مهم |

- اختبر الأخطاء وليس النجاح فقط (`AGENTS.md` §10).
- لا تدّعِ نجاح الاختبارات دون تشغيلها.

### الخطوة 16: التوثيق وقبل الدمج

- أضف الميزة إلى `CORE_MAP.md` إن أضفت أداة إلى Core، وحدّث `CORE_USAGE.md` إن ظهر نمط استخدام جديد.
- شغّل: `dart format .` ثم `flutter analyze` ثم `flutter test`.
- أكمل `FEATURE_CHECKLIST.md`.

---

## 6. قرارات سريعة

| السؤال | الجواب |
|---|---|
| هل أنشئ UseCase لعملية قراءة بسيطة؟ | نعم، القاعدة موحدة: الـ Cubit لا يرى Repository |
| أين أضع حساب الإجمالي أو الضريبة؟ | Entity أو UseCase في `domain`، لا Cubit ولا Widget |
| أين أضع تعريف الـ endpoints؟ | `AppEndpoints` في Core (مركزي)، لا داخل الميزة |
| أين أضع مفاتيح الترجمة؟ | `AppKeys` في Core حالياً (يوجد قرار مفتوح عن تقسيمها، `KNOWN_GAPS.md`) |
| أين أسجّل `GoogleSignIn`/صندوق Hive؟ | DI الميزة |
| هل أنقل أداة الميزة إلى Core؟ | فقط عند وجود مستهلك ثانٍ فعلي (`ARCHITECTURE_RULES.md` §2) |
| الخطأ يظهر كرسالة أم حالة؟ | تحميل شاشة ← State، إجراء ← Effect |
| هل أستخدم Singleton للـ Cubit؟ | فقط إن كانت حالته مشتركة بين واجهات متعددة |
| متى أستعمل `BlocProvider.value`؟ | مع Cubit Singleton فقط، حتى لا يُغلق |