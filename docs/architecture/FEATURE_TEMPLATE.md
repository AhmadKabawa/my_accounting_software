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
- **النصوص والأزرار:** `AppText` و`AppButton` يستقبلان `AppKey` من enum القسم (`AuthKeys` مثلاً)، وكل قيمة تحمل `ar` و`en`. سجّل enum الميزة في `key_registry.dart`؛ لا تستخدم `AppKeys` أو ملفي ar/en. راجع [LOCALIZATION.md](LOCALIZATION.md).
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

  // قاعدة نطاق على الكيان؛ لا يحدد هذا المثال نوع تمثيل المبالغ المالية.
  bool get isEditable => status == InvoiceStatus.draft;
}
```

انظر [ADR-0002](ADR/0002-state-modeling-and-bloc-vs-cubit.md).

## قالب CRUD: Brands هو المرجع

`features/catalog/brands` هو النموذج لأي قائمة + محرر. يُنسخ منه ما يلي:

**الشجرة**

```
catalog/brands/
  data/{datasources,models,repositories,brands_endpoint.dart}
  domain/{entity,failures,repositories,usecase,utility}
  presentation/{cubit/<name>/,dialogs,pages,sections,widgets,localization,routing}
  di/brands_di.dart
```

**الحالة**
- مجلد لكل Cubit: `cubit/<name>/<name>_cubit.dart` و`_state.dart` و`_effect.dart`.
- حالة تحمل بيانات = ملف مستقل (`Equatable`، حقل `status` + بيانات). enum صغير (مثل `BrandFormStatus`) = داخل ملف الـ Cubit. الـ Effects دائماً ملف مستقل. الحالات الفرعية لأي `sealed` في ملف واحد مع الأب بلا `part`.
- State = الحالة الدائمة التي تُعرض؛ Effect = حدث لمرة واحدة (نجاح حفظ، تغيّر بيانات).
- عقد القائمة: `initial / loading / ready / refreshing / failed`. الصفوف القديمة تبقى عند فشل التحديث ويظهر `InlineBanner` مع إعادة المحاولة؛ `AppPageState.error` فقط عند الفشل بلا صفوف، و`loading` فقط عند التحميل الأول.
- نمط العملية: الـ Cubit ينفّذ ويرسل `FlashMessages` ويصدر Effect؛ الشاشة تستمع ولا تنسّق (مثلاً تحديث الإحصائيات من `BrandsMutatedEffect` في موضع واحد). فشل عملية داخل `ConfirmDialog` يُعاد للحوار (`Either`) ليعرضه، ولا يُرسل Flash.
- لا freezed للحالات، وBloc فقط عند الحاجة الفعلية (ADR-0002).

**النماذج**
- `showAppFormDialog` + `AppFormDialog` (core): `busy` و`dirty` و`errorKey`؛ تأكيد مغادرة واضح عند التغيير غير المحفوظ عبر cancel/Escape/back/barrier، ومنع الإغلاق أثناء الحفظ. الإضافة تعرض «مسح المحتوى» للعودة إلى القيم الابتدائية، والتعديل يعرض «إعادة تعيين» للعودة إلى نسخة السجل الأصلية، والنسخ يعيد قيم seed. كلا الإجرائين يتطلب تأكيداً ولا يحفظ شيئاً. `CrudEditorFields.reset()` يعيد الحقول النصية، و`CrudEditorDialog.onReset` يعيد أي حالة إضافية غير نصية مع `extraDirty`. الإغلاق البرمجي `Navigator.pop(true)` بعد نجاح الحفظ يتجاوز الحارس عمداً. لا تغيّر آلية إنشاء أو هدم Cubit.
- مصدر واحد لحالة الحفظ (الـ Cubit)؛ لا `_saving` محلية. Cubits النموذج والرفع تُنشأ فوق الحوار لا داخل قسم، ويُمنع الحفظ أثناء الرفع.
- الأقسام (`sections/`) والجداول والفلاتر تستلم قيماً وCallbacks ولا تقرأ Cubit.
- حقل مولَّد (slug) يتوقف عن التوليد التلقائي عند أول تعديل يدوي، ويبقى فارغاً مع تلميح للاسم العربي بلا transliteration.

**البيانات والأخطاء**
- يُصنَّف الخطأ بـ `ApiException.errorCode` (`23505` تكرار، `23503` ارتباط) لا بـ HTTP 409 وحده.
- مفاتيح رسائل `Failure` الخاصة بالنطاق تعيش في `domain/failures/` لا في `presentation/` (Domain لا يعتمد على Presentation).
- الإحصائيات عبر Use Case مخصص (`GetBrandStatsUseCase`)؛ التنفيذ الحالي طلبا عدّ ويُستبدلان بـ RPC دون تغيير في العرض.
- قرار الحذف من الكيان (`Brand.canDelete`)؛ `productCount == null` لا يعني «مستخدم» بل «تعذر التحقق».

**الجداول**
- عمود إجراءات الصف بعرض ثابت من token (`hitArea × 4`): إجراءان ظاهران، والمدمّر (حذف) في قائمة Overflow وفي حالة `canDelete` فقط.

## كيف تضيف ميزة جديدة

1. أنشئ الشجرة أعلاه بالطبقات التي لها مسؤولية فعلية فقط.
2. سجّل الاعتماديات في `features/<feature>/di/` واستدعِها من `app_di.dart` بعد ما تعتمد عليه.
3. أضف المسارات، وعرّف نصوص الميزة في enum يحمل `ar` و`en`، ثم سجّل قيمه في `key_registry.dart` وفق [LOCALIZATION.md](LOCALIZATION.md).
4. اتبع [قائمة مراجعة الميزة](FEATURE_CHECKLIST.md).

## قيود معروفة

- `features/home` لوحة محاسبة بدائية على بيانات تجريبية (`SampleHomeRepository`) وتتبع هذا القالب؛ يُستبدل المستودع بتجميع الوحدات الحقيقية لاحقاً.
- `on_boarding` ما زال تجريبياً ومستثنى من اختبار منع العناصر الخام فقط؛ الأرقام المباشرة صارت مفحوصة فيه أيضاً.
- قالب CRUD (قائمة + نموذج) المرجع هو `features/catalog/brands`؛ انظر القسم التالي. التفاصيل والنماذج الأعقد (فاتورة بسطور) لم تُبنَ بعد.
- قرارا أمان الجلسة: [SECURITY_DECISIONS.md](SECURITY_DECISIONS.md).

## ما كشفه تطبيق القالب على ميزة ثانية (Colors)

- الهيكل انسخ-وعدّل نجح: Colors بُنيت بنفس الطبقات والتسمية، وكل الملفات ≤250 سطراً، وبوابات المعمارية مرّت دون استثناءات.
- المتكرر فعلاً بين الميزات (مرشحو التجريد القادم): `*ListCubit/State/Effect` (debounce 300ms، `_requestVersion`، refresh)، `*FilterBar`، `*StatusBadge`، تحويل Repository (`switch` على `ApiSuccess/ApiFailure` + `23505`)، ودوال datasource للقائمة/التحديث/التفعيل. لم تُجرَّد بعد عمداً: ميزتان لا تكفيان لتصميم تجريد صحيح؛ يُعاد التقييم عند الميزة الثالثة.
- فجوات Core ظهرت وأُغلقت داخل Core لا في الميزة: عيّنة اللون، حقل نص بمنسّقات واتجاه، ومساعد PostgREST.
- فخ تعلّمناه: ترتيب حقول `TextFormField` في اختبارات النماذج يتبع ترتيب الأقسام في الشاشة لا ترتيب الأعمدة في الجدول.
- التنسيق: لا يوجد Dart محلياً؛ مُنسّق CI يفصل استدعاءات متداخلة حتى لو كانت تتسع في 80 عموداً، فإذا فشل `dart format` فاطبع الفرق من CI بدل التخمين.


### Shared paged list lifecycle

The common list lifecycle has since been extracted to `core/presentation/state_management/paged_list/` because Brands and Colors had a second real consumer. New CRUD list cubits should implement the shared `PagedQuery` and `PagedResult` contracts and extend `PagedListCubit<T,Q,E>`. Keep feature-specific validation, filters, sorting, mutation effects, and use-case wiring in the feature. Brands retains its one/two-criterion sort API as a feature hook; Colors is not migrated by this change.
