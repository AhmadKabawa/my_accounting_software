# تعليمات العمل لمشروع Flutter المحاسبي

أنت تعمل على تطبيق Flutter/Dart بنية Feature-first، يستخدم GetIt وCubit/Bloc وDio وSupabase. الأولوية لصحة البيانات والأمان وقابلية الصيانة، لا لمجرد جعل الكود يعمل.

## 1. جودة التنفيذ

- اكتب أقل قدر من الكود يحقق المتطلب بوضوح وأمان؛ لا تختصر على حساب الفهم أو الاختبار.
- لا تضف ملفات أو طبقات أو abstractions أو packages دون حاجة حقيقية ومبرر واضح.
- قبل إنشاء خدمة أو Widget أو Helper، ابحث عن تنفيذ مناسب في Core وتحقق من توقيعه وسلوكه ومستخدميه واختباراته.
- تجنب تكرار المنطق والثوابت ومعالجة الأخطاء وإعدادات الشبكة داخل الميزات.
- استخدم أسماء واضحة، null safety سليمة، و`const` عندما يناسب. تجنب `dynamic` و`late` وforce unwraps بلا مبرر.
- لا تبتلع الاستثناءات بصمت، ولا تستخدم `print` في كود الإنتاج. لا تسجل كلمات المرور أو Tokens أو البيانات المالية الحساسة.
- لا تترك أزراراً أو مسارات شكلية توحي بأن ميزة مكتملة بينما تنفيذها غير موجود.

## 2. بنية المشروع والاعتماديات

- التزم ببنية Feature-first والطبقات الفعلية `data` و`domain` و`presentation` عند وجود مسؤولية حقيقية لكل طبقة.
- اتبع [قواعد المعمارية وحدود الطبقات](docs/architecture/ARCHITECTURE_RULES.md).
- أعد استخدام Dio وGetIt وCubit وFailure وExceptionMapper الموجودة؛ لا تنشئ نظاماً موازياً.
- لا تضف dependency قبل التحقق من توافقها مع Flutter وDart والمنصات المطلوبة، ولا تحدّث الحزم دفعة واحدة دون سبب.
- دورة حياة DI وتسجيل الخدمات وCubit موضحة في [قواعد المعمارية §8](docs/architecture/ARCHITECTURE_RULES.md).
- لا تسجل اعتماديات داخل Widgets أو Repositories، ولا تنشئ Service Locator ثانياً.

## 3. Dart وFlutter وواجهة المستخدم

- اجعل Widgets للعرض والتفاعل، ولا تضع قواعد الأعمال أو الحسابات المالية فيها.
- استخدم نظام التصميم الحالي و`context.ui` بدلاً من إنشاء نظام Responsive أو Theme أو Typography موازٍ.
- راعِ RTL/LTR والثيم الفاتح/الداكن والأحجام المتجاوبة.
- لا تستخدم API خاصاً بمنصة في الكود المشترك دون عزل مناسب: v1 ويب لكن الكود جاهز للهاتف وWindows، والمبادئ في [استراتيجية المنصات](docs/architecture/PLATFORM_STRATEGY.md) (يفرضها `platform_isolation_test`).
- لا تستخدم `dart:io` في كود يجب أن يعمل على Web دون معالجة مناسبة.
- راعِ CORS وHTTPS وmixed content عند اتصال Flutter Web بخادم محلي.
- لا تدّعِ دعم منصة ما دون بناء أو تحقق فعلي؛ اذكر ما لم يُختبر.

## 4. الشبكة والأمان

- استخدم Supabase بوصفه الخلفية البعيدة الحالية وعميل Dio المشترك؛ لا تنشئ Dio داخل Feature.
- لا تضع `service_role` أو أي سر خاص بالخادم في Flutter أو ملفات المستودع.
- اعتمد على RLS والتحقق من جهة الخادم؛ إخفاء زر أو صفحة ليس حماية.
- اتبع سياسة الشبكة وRetry وidempotency وتخزين Tokens في [قواعد المعمارية §6](docs/architecture/ARCHITECTURE_RULES.md).

## 5. الاتصال

الإصدار الأول متصل بالإنترنت فقط (قرار-02): Dio على عنوان Supabase عبر `SUPABASE_URL`. تصميم الخادم المحلي والمزامنة والـ outbox مؤجل إلى v2، وتفاصيله في [OPEN_DECISIONS.md](docs/OPEN_DECISIONS.md) (قسم v2). لا تنفّذ منه شيئاً الآن.

## 6. سلامة النظام المحاسبي

- الدقة المالية وصحة العمليات أهم من اختصار الكود.
- اتبع قواعد الأموال والقيود والسجلات في [قواعد المعمارية §7](docs/architecture/ARCHITECTURE_RULES.md).
- **Money:** نُفِّذ `Money(amount, currencyId)` فوق `decimal` في `lib/app/core/foundation/money/` مع `AmountFormatter` (C13)، [ADR-0005](docs/architecture/ADR/0005-money-type-and-amount-formatter.md). استعمله لكل مبلغ ولا `double` في أي حساب مالي؛ التقريب من بيانات العملة في القاعدة (`decimal_places` و`rounding_increment` و`rounding_method`) يُمرَّر إلى `MoneyRounding`. لا ميزة تستعمله بعد، ودلالات `rounding_increment` تحتاج مطابقة مع `erp.round_currency` قبل أي ترحيل يعتمد عليه.
- لا تخترع قواعد محاسبية؛ اطلب توضيحاً عندما يؤثر الغموض في الأرصدة أو المخزون أو العملات.

## 7. الحالة والتنقل ودورة الحياة

- التزم بـ Cubit/Bloc المعتمد، واجعل كل Cubit مسؤولاً عن نطاق محدد. Cubit افتراضي وحالاته `sealed` + `Equatable` بلا freezed؛ Bloc فقط عند الحاجة لتحكم تزامن (انظر [ADR-0002](docs/architecture/ADR/0002-state-modeling-and-bloc-vs-cubit.md) و"متى أستخدم ماذا" في [FEATURE_TEMPLATE.md](docs/architecture/FEATURE_TEMPLATE.md)).
- لا تنشئ نسخاً متعارضة من Cubit أو Repository عندما يجب مشاركة الحالة نفسها.
- ضع بيانات الشاشة المستمرة في State والأفعال أحادية الاستخدام في Effects.
- استخدم GoRouter ومسارات موحدة؛ لا تجعل Domain أو Data ينفذان التنقل.
- ألغِ الطلبات والاشتراكات وأغلق Controllers/Cubits عند انتهاء دورة حياتها.
- لا تستخدم BuildContext بعد `await` دون التحقق من صلاحيته عند الحاجة.

## 8. الاختبارات والتحقق

- أضف اختبارات لقواعد الأعمال والحسابات ومسارات الشبكة والأخطاء عند إضافة سلوك أو إصلاح عطل.
- اختبر الحالات الطبيعية والحدية والفشل والإلغاء، لا مسار النجاح فقط.
- اعزل الشبكة والخدمات الخارجية باستخدام mocks أو fakes في اختبارات الوحدات.
- يُتحقق بـ CI في `flutter-ci.yml` بالأوامر: `pub get`, `dart format --set-exit-if-changed .`, `analyze --no-fatal-infos`, `test`.
- اتبع [قاعدة توثيق نتائج الفحوصات في قواعد المعمارية §9](docs/architecture/ARCHITECTURE_RULES.md).

## 9. التعديل الآمن وسير العمل

- اعمل على فرع Git مستقل؛ لا تدمج تلقائياً في الفرع الأساسي.
- افحص الاستخدامات والمراجع قبل حذف أو إعادة تسمية ملف أو Class أو API.
- لا تنفذ إعادة كتابة شاملة إذا كان إصلاح موضعي آمناً كافياً.
- لا تغيّر سلوكاً أو عقد API أو قاعدة بيانات دون توضيح الأثر.
- اجعل التغييرات صغيرة ومترابطة، وافصل التغييرات غير المرتبطة في Commits مستقلة متى أمكن.
- لا تترك TODO أو UnimplementedError أو بيانات وهمية في مسار إنتاج مكتمل دون توثيق واضح.
- قبل العمل افهم معايير القبول وتدفق البيانات والملفات المتأثرة وأي غموض يمس الأمان أو البيانات.
- بعد العمل راجع diff والاعتماديات والأمان والاختبارات، ثم لخّص الملفات والنتائج والقيود والأعمال المتبقية.

## 10. مراجع المشروع

- [فهرس المعمارية](docs/architecture/README.md) نقطة البداية للوثائق الحالية.
- [خريطة Core](docs/architecture/CORE_MAP.md) للاكتشاف؛ افحص المصدر قبل الاعتماد على API.
- [تغطية اختبارات Core](docs/architecture/CORE_TEST_COVERAGE.md) لمعرفة الاختبارات والفجوات.
- [استخدام Core](docs/architecture/CORE_USAGE.md) للأمثلة.
- [معايير التكويد](docs/architecture/CODING_STANDARDS.md) و[قائمة مراجعة الميزة](docs/architecture/FEATURE_CHECKLIST.md) للمراجعة العملية.

## قواعد حديثة

قبل أي شاشة: [الأخطاء المعروفة](docs/architecture/KNOWN_PITFALLS.md) و[دليل بناء شاشة](docs/design/SCREEN_BUILD_PLAYBOOK.md). تفرضها `test/architecture/ui_quality_gate_test.dart`.

سياسة الواجهة (فجوة الـ core، الممنوعات داخل `features/`، التوكنز) في [قواعد المعمارية §5 وقاعدة «فجوة الـ core»](docs/architecture/ARCHITECTURE_RULES.md)، والنصوص والترجمة في [LOCALIZATION.md](docs/architecture/LOCALIZATION.md). لا تنسخ قواعدها هنا (ADR-0001 بند 8).
