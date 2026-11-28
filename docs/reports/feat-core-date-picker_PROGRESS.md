# feat/core-date-picker — Progress

## الحالة
- أُضيف `AppDatePickerField` في Core مع label/value/onChanged وحدود التاريخ وhelper/error/validator/enabled/clearable.
- الحقل وحده يستدعي `showDatePicker`، ويفتح من مساحة الحقل أو أيقونة التقويم.
- أُضيف `DateOnly` لتحويل `DateTime` إلى/من `yyyy-MM-dd` مع تطبيع الوقت إلى منتصف الليل المحلي.
- أُضيف تنسيق تاريخ يعتمد على `MaterialLocalizations`، واختبارات للغتين العربية والإنجليزية.
- أُضيف تحقق `validateDateRange` ومفتاح ترجمة عربي/إنجليزي.
- تم التأكد من تهيئة التطبيق عبر `context.localizationDelegates`، ويشمل اختبار Core الآن GlobalMaterial/Widgets/Cupertino delegates للغتين.
- حُدّثت CORE_MAP وCORE_USAGE وCORE_TEST_COVERAGE وسُجلت مفاتيح الترجمة.
- اختبارات الحقل تغطي الاختيار والمسح والحدود والتعطيل والخطأ وRTL/LTR والفاتح/الداكن وعرض 280px بمقياس 1.5.

## CI
- التشغيل المخصص الأخير: تنسيق Dart والتحليل والاختبارات المستهدفة نجحت (run 46096886612؛ commit التنسيق الناتج `e7b41f5fbeaf631b83526f5322a93288cedf6274`).
- التشغيل الكامل السابق على commit أقدم: 1576 اختباراً نجح و22 فشل؛ فشلان كانا متعلقين بمفتاح datepicker واختيار يوم الحوار وقد أُصلحا. بقيت إخفاقات خارج الملفات المعدلة، منها حد طول ملف attribute editor واختبارات ترتيب وجهات الشريط الجانبي وميزات attributes/categories/option_sets. لم تُعدّل هذه المجالات.
- التشغيل الرسمي على آخر commit بعد التنسيق لم يُؤكد بعد؛ سيُتابع بعد إزالة ملف التحقق المؤقت.

## القيود والمتبقي
- لا يوجد تحقق بصري على Chrome أو أجهزة فعلية.
- لم يُختبر أي سلوك على Supabase؛ الميزة Core محلية ولا تحتاج اتصالاً حياً.
- PR مفتوح باتجاه `integration/catalog-scope-1-combined` ولم يُدمج.
