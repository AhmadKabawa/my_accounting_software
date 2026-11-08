# قالب الميزة: Auth هو المرجع

ميزة `features/auth` هي النموذج الذي تُبنى عليه بقية الميزات. هذا الملف يصف بنيتها وما يُنسخ منها؛ القواعد الملزمة في [قواعد المعمارية](ARCHITECTURE_RULES.md) وقائمة التسليم في [قائمة مراجعة الميزة](FEATURE_CHECKLIST.md).

## الشجرة

```
features/<feature>/
  di/                      تسجيل اعتماديات الميزة فقط (يستدعيه app_di.dart)
  domain/
    entity/                كيانات نقية (freezed) بلا Flutter/Dio
    repositories/          عقود Repository
    usecase/               حالة استخدام لكل فعل
  data/
    models/                DTO وتحويل JSON
    datasources/           remote / local
    repositories/          تنفيذ العقود وتحويل AppException إلى Failure
  presentation/
    cubit/                 Cubit + states/ (حالة مستمرة) + effect/ (أفعال لمرة واحدة)
    pages/<page>/          شاشة واحدة لكل مجلد، وبجانبها widgets/ الخاصة بها
    sections/              أقسام الشاشة عندما تكبر (مثل profile وhome)
    widgets/               ودجتات مشتركة بين صفحات الميزة نفسها
```

## ما يُنسخ من Auth

- **إطار الصفحة:** `AuthPageScaffold` يجمع التخطيط والتمرير وحد العرض والعنوان و`FlashMessageListener` الذي يعرض الرسائل. صفحة جديدة تعطيه `child` فقط.
- **الـ Cubits:** `SessionCubit` عام (singleton، يطبّق `SessionGate`: checking/authenticated/unauthenticated)، و`AuthFlowCubit` لكل صفحة (factory، يعتمد على الواجهة الصغيرة `SessionAuthenticator` (`onAuthenticated` فقط) لا على `SessionCubit` مباشرة، حالته idle/loading، وآثار التنقل `AuthFlowEffect`)، و`ProfileCubit` لتحديث الملف وكلمة المرور بتحميل محلي. الرسائل عبر `FlashMessages` بـ `AppKey` (لا نصاً مترجماً). بريد الاسترجاع يمر بين الصفحتين كمعامل مسار.
- **عقد الجلسة:** Splash والـ Router يعتمدان على `SessionGate` فقط.
- **النصوص:** enum لكل ميزة + سطر في `key_registry.dart` ([LOCALIZATION.md](LOCALIZATION.md)).
- **المجلدات:** `pages/<page>/sections/` للأقسام الكبيرة، و`widgets/` للصغيرة.
- **الحقول:** `AppTextField` (core) و`PasswordField` (غلاف رقيق فوقه) مع `AppValidator`؛ لا validator موازياً.
- **النصوص والأزرار:** `AppText` و`AppButton` ومفاتيح `AppKeys` في ملفي ar/en.
- **المسارات:** المسار في `presentation/routing/<feature>_routes.dart` وفي `all` الخاص بها، و`...<Feature>Routes.all` في `route_registry.dart`، وفي `publicRoutes` أو `protectedRoutes`، ثم تسجيله في `app_go_router.dart`. الصفحات التي تشارك Cubit مفرداً تأخذه بـ `BlocProvider.value` (`AppRouter._withAuth`).
- **الحراس:** `resolveRedirect` دالة نقية مغطاة في `test/routing/route_guards_test.dart`.

## متى أستخدم ماذا

| الحاجة | الأداة | القاعدة |
|---|---|---|
| شاشة عادية: تحميل، إرسال نموذج، أفعال متتابعة | **Cubit** (الافتراضي، غالباً `BaseCubit` عند وجود Effects) | لا تُنشئ Bloc دون سبب من الصفين التاليين |
| بحث/تصفية يجب إلغاء ما سبقه، أو زر يجب ألا يتكرر، أو عمليات يجب ألا تتداخل | **Bloc** مع `bloc_concurrency` | `restartable()` للبحث وإلغاء الأقدم، و`droppable()` لتجاهل النقرات أثناء التنفيذ، و`sequential()` لعمليات مرتبة (debounce يحتاج `stream_transform` وتُضاف عند أول شاشة تحتاجها) |
| حالات الـ Cubit/Bloc | **`sealed class` + `Equatable`** | لا freezed للحالات؛ حالة بيانات واحدة تكفي لها `final class` بـ Equatable (مثل `OnBoardingState`) |
| كيان نطاق كبير (فاتورة، سطور، حالات، نسخ) | **freezed** | `copyWith` والمساواة وfromJson لكيانات كبيرة فقط؛ كيانات/نماذج auth الصغيرة الحالية باقية كما هي |

الأمثلة هنا للتوضيح فقط ولا ميزة وهمية في `lib/`.

Bloc بـ `restartable` (بحث يُلغى فيه الطلب الأقدم):

```dart
sealed class SearchEvent { const SearchEvent(); }
final class QueryChanged extends SearchEvent {
  const QueryChanged(this.query);
  final String query;
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._search) : super(const SearchIdle()) {
    on<QueryChanged>(_onQuery, transformer: restartable());
  }
  final SearchUseCase _search;

  Future<void> _onQuery(QueryChanged e, Emitter<SearchState> emit) async {
    emit(const SearchLoading());
    final result = await _search(e.query); // الأقدم يُلغى عند وصول أحدث
    emit(result.fold(SearchFailed.new, SearchLoaded.new));
  }
}
```

كيان freezed كبير (في `domain/entity/`):

```dart
part 'invoice.freezed.dart';

@freezed
class Invoice with _$Invoice {
  const Invoice._();
  const factory Invoice({
    required String id,
    required String customerId,
    required List<InvoiceLine> lines,
    @Default(InvoiceStatus.draft) InvoiceStatus status,
    DateTime? dueDate,
  }) = _Invoice;

  // قاعدة نطاق على الكيان؛ المبالغ الفعلية تنتظر قرار نوع Money (ADR-0001).
  bool get isEditable => status == InvoiceStatus.draft;
}
```

انظر [ADR-0002](ADR/0002-state-modeling-and-bloc-vs-cubit.md).

## كيف تضيف ميزة جديدة

1. أنشئ الشجرة أعلاه بالطبقات التي لها مسؤولية فعلية فقط.
2. سجّل الاعتماديات في `features/<feature>/di/` واستدعِها من `app_di.dart` بعد ما تعتمد عليه.
3. أضف المسارات ومفاتيح الترجمة بلغتين.
4. اتبع [قائمة مراجعة الميزة](FEATURE_CHECKLIST.md).

## قيود معروفة

- `features/home` لوحة محاسبة بدائية على بيانات تجريبية (`SampleHomeRepository`) وتتبع هذا القالب؛ يُستبدل المستودع بتجميع الوحدات الحقيقية لاحقاً.
- `on_boarding` ما زال تجريبياً ومستثنى من اختبار منع العناصر الخام فقط؛ الأرقام المباشرة صارت مفحوصة فيه أيضاً.
- لا قالب CRUD (قائمة + تفاصيل + نموذج) بعد؛ يُبنى على أول ميزة حقيقية.
- قرارا أمان الجلسة: [SECURITY_DECISIONS.md](SECURITY_DECISIONS.md).
