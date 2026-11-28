# feat/core-date-picker — Progress

## الحالة
- أُنشئ الفرع من `integration/catalog-scope-1-combined`.
- أُضيفت `DateOnly` لتحويل PostgreSQL date بصيغة `yyyy-MM-dd` مع تطبيع الوقت إلى منتصف الليل المحلي.
- أُضيفت `AppDatePickerField` مع فتح المنتقي من الحقل/الأيقونة، clearable، حدود التاريخ، validator/error/helper.
- أُضيفت قاعدة ترتيب التاريخين ومفاتيح عربي/إنجليزي.
- حُدّثت وثائق Core وسجل مفاتيح الترجمة.
- أُضيفت اختبارات وحدة وWidget؛ لم تُشغّل محلياً لعدم توفر Flutter SDK.

## CI
- لم يُنشأ PR بعد، ولم يبدأ CI.

## المتبقي / القيود
- مراجعة CI وإصلاح أي فشل بعد فتح PR.
- التحقق من Material localization على Android/Web فعلياً؛ اختبارات Flutter فقط تغطي delegate في الاختبار.
- لم يُختبر أي اتصال حي بقاعدة Supabase.
