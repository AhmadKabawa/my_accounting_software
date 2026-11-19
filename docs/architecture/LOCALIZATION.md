# نظام النصوص (Localization)

كل نص ظاهر للمستخدم **كائن واحد** يحمل المفتاح والعربي والإنجليزي، ويُعرَّف كقيمة `enum` داخل `enum` لكل قسم. لا يوجد `AppKeys` ولا أسماء مسطحة.

## الشكل

```dart
// core/localization/translations/app_key.dart
abstract interface class AppKey { String get key; String get ar; String get en; }

// features/auth/presentation/localization/auth_keys.dart
enum AuthKeys implements AppKey {
  signIn(ar: 'تسجيل الدخول', en: 'Sign in');
  const AuthKeys({required this.ar, required this.en});
  @override final String ar;
  @override final String en;
  @override String get key => 'auth.$name';
}

const AppText(AuthKeys.signIn)   // const يعمل، ويُترجم عند تغيير اللغة
```

- `ar` و`en` معاملان `required`: نسيان لغة يكسر البناء.
- المفتاح مشتق من البادئة واسم القيمة؛ لا تُكتب سلسلة المفتاح ولا يتكرر اسم داخل القسم.
- `AppText` و`AppButton` و`Failure` و`AppValidator` تستقبل `AppKey` كما كانت.

## الأقسام وأماكنها

| القسم | المكان |
|---|---|
| `CommonKeys` `FieldKeys` `ValidationKeys` `ErrorKeys` `ServerErrorKeys` `ErpErrorKeys` `ThemeKeys` `NavKeys` `MessageKeys` | `core/localization/keys/` |
| `AuthKeys` (بما فيها رسائل نجاح الدخول والتسجيل والخروج والاسترجاع) | `features/auth/presentation/localization/` |
| `ProfileKeys` | `features/profile/presentation/localization/` |
| `OnboardingKeys` | `features/on_boarding/presentation/localization/` |
| `AccessKeys` | `core/access/keys/` (مفاتيح تحميل/فشل الوصول) |

القاعدة: ما يخص ميزة يبقى فيها، والمشترك في `core`. إن تضخم قسم (أكثر من ~60 إدخالاً) يُقسَّم إلى أقسام فرعية (مثل `AuthLoginKeys`)، لأن الـ enum لا يُقسَّم على ملفات.

## إضافة نص أو قسم

1. **نص:** سطر واحد في enum القسم.
2. **قسم/ميزة جديدة:** أنشئ `enum XKeys implements AppKey` في مجلد الميزة، ثم سطر `...XKeys.values` في `lib/app/localization/key_registry.dart`.

## السجل خارج core

`key_registry.dart` (`allKeys`) في جذر التركيب `lib/app/localization/`، لأن وضعه في `core` يجعل `core` يستورد من `features` ويعكس اتجاه الاعتماد. المحمّل `MyDartLoader(allKeys)` في `core` يستقبل القائمة فقط.

## الاختبارات (`test/localization/key_registry_test.dart`)

تفرّد المفاتيح عبر السجل، واكتمال السجل (كل `enum … implements AppKey` مسجَّل)، ونصوص غير فارغة، وتطابق متغيرات `@name` بين اللغتين.
وبعد تهيئة `easy_localization` بالمحمّل نفسه `MyDartLoader(allKeys)` لكل لغة (ar وen) يتحقق الاختبار أن `key.tr()` لكل مفتاح مسجَّل يعيد نصاً غير المفتاح نفسه (أي أن السجل يصل فعلاً إلى `tr()`).

## أخطاء القاعدة (ERPnn)

أخطاء الأعمال من القاعدة (`SQLSTATE = ERPnn`، قرار-76) لها قسم `ErpErrorKeys` في `core/localization/keys/`: لكل رمز مفتاح بنصين عربي وإنجليزي، والعربي مأخوذ من `docs/backend/DATA_MODEL.md §5`. المسار: استجابة PostgREST `{code, message, details}` ← `ApiClient` يقرأ `code` فإن كان `ERPnn` أنشأ `ApiException.erp` (نوع `businessRule`) ← `ExceptionMapper` يربطه بـ `ErpErrorKeys.fromCode` ← `FailureTranslator`. نص الخادم والرمز والتفاصيل تُسجَّل للتشخيص ولا تُعرض. رمز غير معروف يعرض النص العام `ErpErrorKeys.unknown`. عند إضافة رمز في القاعدة أضف مدخلاً هنا؛ اختبار `test/core/error/erp_error_test.dart` يفشل إن اختلفت أكواد الوثيقة عن الـ enum.

الأخطاء ذات المتغيرات (اسم الصنف، النسبة، الرصيد المتاح...) غير مدعومة بعد: تُحسم عند أول شاشة تحتاجها (انظر `docs/OPEN_DECISIONS.md`).

## المتغيرات

تبقى كما كانت: `@length` و`@number` وأمثالها داخل النص، وتُستبدل عبر `tr(namedArgs: …)`.

## إضافة لغة ثالثة

أضف حقلاً `required` في `AppKey` وفي كل enum (المترجم يرشد إلى المواضع) وحدّث `MyDartLoader`. إن تجاوز العدد 4 لغات يُستبدل الحقل بـ `Map<String,String>`.

## الممنوعات

- نصوص أو أسماء مفاتيح حرة في الشاشات (إلا البيانات الديناميكية).
- بناء `AppKey` من سلسلة في كود الإنتاج (في الاختبارات استخدم `test/helpers/test_key.dart`).
- ملف عربي/إنجليزي منفصل: لا يوجد `app_ar.dart` ولا `app_en.dart`.

## المقايضة

العربية كلها لم تعد في ملف واحد. للمراجعة اللغوية يمكن تصدير `key|ar|en` من `allKeys` إلى CSV بسكربت.


## مفاتيح أضيفت في 2026-11-18

سُجلت في lib/app/localization/key_registry.dart:
- ShellKeys: shell.branch وshell.notificationsUnavailable وshell.userMenu.
- TemplateKeys: template.unsavedChanges وtemplate.save.


## مفاتيح إضافية — 2026-11-19

أضيفت إلى ShellKeys: shell.more. وأضيفت إلى TemplateKeys: template.emptyTitle وtemplate.emptyDescription. جميعها ضمن allKeys عبر key_registry.dart، باللغتين العربية والإنجليزية.
