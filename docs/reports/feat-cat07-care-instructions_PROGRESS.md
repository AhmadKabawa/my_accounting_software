# feat/cat07-care-instructions — Progress

## الحالة
- أُنشئت ميزة Feature-first كاملة لتعليمات العناية: typed entity/enum، model، endpoint، remote data source، repository، use cases، DI، list Cubit، form Cubit، editor، وCRUD list config.
- العقد المستخدم مطابق لجدول `care_instructions`: `name`, `code`, `care_type`, `description`, `is_active`. لم يُرسل `icon` أو `sort_order` أو أي حقل خارج المصفوفة؛ `sort_order` يُقرأ ويُستخدم في ترتيب القائمة، ويُترك افتراضياً في الإنشاء.
- `CareType.tryParse` يغطي القيم الخمس، وتسمية النوع موحدة في `care_type_presentation.dart`.
- البحث بالاسم والرمز، وفلتر الحالة والنوع، والترتيب `sort_order` ثم `name`، وبطاقات الهاتف، ومنع العمليات الجماعية.
- الكتابة محمية بـ `masterData.manage`. يُخفى الحذف عندما تشير علاقات الاستخدام إلى ارتباط، وSQLSTATE 23503 يُترجم إلى «أوقِف بدلاً من الحذف»؛ 23505 إلى رسالة تكرار واحدة.
- سُجّل المسار `/catalog/care-instructions` في route registry/guards/router، وسُجل DI ومفاتيح الترجمة، وأضيفت بطاقة Hub.
- جرى تحديث حالة `care_instructions` فقط في رأس `CAT-07_descriptive_tables.md`.
- أُصلح حد الاستجابة في Core `AppPageHeader` عند عرض 280px، مع اختبار حدّي مستقل؛ كان السبب أن حد البطاقة يُقاس بـ adaptiveScale فينخفض تحت عرض الهاتف الفعلي.
- لم تُلمس `size_systems` أو `product_types` domain/data.

## CI والاختبارات
- آخر تشغيل تحقق مخصص: نجاح التنسيق، `flutter pub get`، `flutter analyze --no-fatal-infos`، واختبارات `AppPageHeader` وميزة `care_instructions`، run [46098232739](https://github.com/AhmadKabawa/my_accounting_software/actions/runs/46098232739).
- هذا التشغيل شمل اختبارات payload exact fields، قراءة الاستخدام، 23505/23503، حدود الحقول، Form Cubit، ومصفوفة الشاشة 280px RTL بمقياس 1.5 و1200px LTR داكن.
- التشغيل الرسمي على آخر commit بعد إزالة ملف التحقق المؤقت: **نجاح** (تنسيق + تحليل)، run [46098396745](https://github.com/AhmadKabawa/my_accounting_software/actions/runs/46098396745).

## Backend والقيود
- لا يوجد طلب Backend جديد؛ العقد والجدول والعلاقات موثقة في DATA_MODEL ووثائق backend، لذلك لم يُضف شيء إلى `BACKEND_REQUESTS.md`.
- لم يُجرَ اتصال حي بـ Supabase. لم تُختبر فعلياً استجابات رفض القيم، أسماء قيود UNIQUE/FK على الخادم، أو سلوك RLS للمستخدمين/الأدوار.
- لا تحقق بصري على Chrome أو أجهزة فعلية.
- PR مفتوح باتجاه `integration/catalog-scope-1-combined` ولم يُدمج.
