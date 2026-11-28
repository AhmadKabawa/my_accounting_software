# feat/cat07-care-instructions — Progress

## الحالة
- أُنشئ الفرع من `integration/catalog-scope-1-combined`.
- قُرئ عقد جدول `care_instructions` من DATA_MODEL ومصفوفة CAT-07؛ الجدول والقيود والعلاقات موجودة.
- أُضيفت طبقات domain/data وtyped CareType مع tryParse وتحويل dry_cleaning.
- أُضيفت شاشة CRUD مع فلتر الحالة ونوع العناية، بحث الاسم/الرمز، وترتيب ثابت sort_order ثم name.
- تُقرأ أعداد علاقات الاستخدام لإخفاء الحذف للسجل المستخدم، مع تحويل SQLSTATE 23503 إلى Failure مترجم.
- لم تُضف حقول icon أو sort_order إلى جسم الكتابة؛ الجسم محصور في name/code/care_type/description/is_active.
- لم تُضف إجراءات جماعية.
- اكتمل تسجيل DI والمسار والحارس ومفاتيح الترجمة وبطاقة Hub في commit مستقل بعد إعادة فحص الفرع الأساسي (لم يكن قد تغيّر).
- لم تُعدّل product_types أو size_systems.

## CI
- لم يُفتح PR بعد؛ لم يبدأ CI.

## المتبقي
- تحديث حالة care_instructions وحدها في رأس مواصفة CAT-07.
- مراجعة CI وإصلاح أي فشل.
- لا يوجد اختبار حي حتى الآن لرفض القيم أو أسماء القيود أو RLS.
