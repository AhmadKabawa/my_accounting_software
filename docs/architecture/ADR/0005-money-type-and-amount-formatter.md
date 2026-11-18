# ADR-0005: نوع `Money` و`AmountFormatter` (C13)

- **الحالة:** معتمد (القرار نفسه قرار-70 وقرار-77)؛ **التنفيذ في حالة «مراجعة»**: لم يُشغَّل `flutter pub get` ولا `flutter analyze` ولا `flutter test`.
- **التاريخ:** 2026-11-16
- **المرجع:** `docs/product/scenarios/A4_decisions_log.md` (قرار-70، قرار-77)، `AGENTS.md` §6، `ARCHITECTURE_RULES.md` §7، كتلة C13 في `docs/product/Missing_UI_Components_Priority_Plan.md`، البند D-UI-01.

## السياق

لم يكن في الكود نوع للمال ولا تمثيل عشري دقيق، والقاعدة تخزّن المبالغ `numeric(20,4)` وأسعار الصرف `numeric(20,8)`، وتحدد لكل عملة `decimal_places` و`rounding_increment` و`rounding_method`. دخول `double` إلى الحساب المالي يُنتج انحرافاً (`0.1 + 0.2`)، والمكوّنات C03 وC13 وC34 تعتمد على نوع دقيق.

## القرار

1. **`Money(amount, currencyId)` فوق حزمة `decimal`** في `lib/app/core/foundation/money/`. نوع Dart خالص (لا Flutter)، فيصلح للاستعمال من Domain.
   - الجمع والطرح والمقارنة بين عملتين مختلفتين ترمي `CurrencyMismatchException` (يقابل `ERP10`).
   - الضرب بنسبة أو كمية: `times`. التحويل بين عملتين صريح عبر `convert(rate:, toCurrencyId:)` بمعامل جاهز؛ اتجاه السعر مسؤولية المستدعي.
   - لا تقريب ضمني. التقريب صريح عبر `Money.rounded(MoneyRounding)`.
2. **التقريب من بيانات العملة**: `MoneyRounding` يستقبل `decimal_places` و`rounding_increment` و`rounding_method` معاملات (`MoneyRounding.fromCurrencyRow` لصف `currencies`). لا قاعدة تقريب ثابتة في Flutter.
3. **القراءة من PostgREST** عبر `Money.fromRaw` التي تقبل نصاً أو `int` أو `BigInt` أو `double` منتهياً أو `Decimal`، وتفكّك النص بحساب `BigInt` دون المرور بـ `double` حين تصل القيمة نصاً.
4. **`AmountFormatter` دوال خالصة** (`formatDecimal` و`format`): أرقام غربية (قرار-77)، فاصل آلاف `,` وعشري `.`، عدد الكسور من العملة لا من القيمة، علامة `−` (U+2212)، عزل الاتجاه `LRI…PDI` حول الرقم بعلامته، رمز العملة خارج العزل بفاصل غير قابل للكسر، ولا اختصار للمبالغ. التقريب في العرض لا يغيّر القيمة المحفوظة.
5. **حزمة واحدة جديدة مباشرة: `decimal`**. لم تُضف `intl` مباشرة لأن التنسيق يدوي وحتمي (الأرقام الغربية والفواصل ثابتة)؛ تصل `intl` تبعياً عبر `decimal` وعبر `easy_localization` فقط.

## النتائج

- كل الميزات الجديدة تتعامل مع المبالغ بـ `Money` ولا تستعمل `double` في أي حساب مالي.
- حدود معروفة (تُراجع قبل أول ترحيل يعتمد عليها):
  - دلالات `rounding_increment` > 0 وسلوك `UP`/`DOWN` للقيم السالبة استُنتجت من أسماء الأعمدة وقيودها (كـ `BigDecimal`: `UP` بعيداً عن الصفر و`DOWN` نحو الصفر)، ولم تُطابَق مع نص `erp.round_currency` لأنه لم يرد في الوثائق.
  - قيمة JSON الرقمية تصل بعد أن حلّلها `jsonDecode` إلى `double`؛ دقتها نحو 15 رقماً معنوياً. للمبالغ الكبيرة يُطلب من الخادم النص.
  - `pubspec.lock` لم يُحدَّث.

## التحقق

اختبارات الوحدة في `test/core/foundation/money/` (ثلاثة ملفات). **لم تُشغَّل** لعدم توفر Flutter/Dart في بيئة التنفيذ؛ قيمها المتوقعة تحقق منها بنسخة Python مطابقة للخوارزمية فقط، وهذا لا يثبت سلامة الترجمة أو توافق واجهة `decimal`.
