# CAT-07 — الجداول المرجعية الوصفية

**الحالة:** مواصفة مقترحة غير منفذة. مسار الفهرس المقترح: `/catalog/reference-data`.  
**المراجع:** S52/S51، DATA_MODEL.

## الغرض
تجميع جداول مرجعية وصفية في تجربة موحدة بشرط أن يكون لكل جدول تعريف typed خاص به، وليس CRUD ديناميكي يعتمد على اكتشاف schema. أنواع الحقول وقواعد التحقق تختلف، ويجب أن تبقى مرتبطة بجدولها.

## نطاق الجدول
المجموعات المذكورة في السيناريو (sports، age groups، genders، seasons، collections، tags، materials، fabrics، care instructions) تخضع لفحص schema: لا تضم جدولاً أو حقلاً غير موجود أو غير معتمد. ترتيب الأولوية المقترح يجب أن يراعي اعتماد size_groups على genders.

## قالب
فهرس يختار الجدول؛ لكل جدول قائمة ونموذج خاص به (typed configuration)، بحث وترقيم/فرز، تفعيل/تعطيل وفق قيود الاستخدام. لا generic schema-driven editing، ولا bulk actions غير موثقة.

## حالات/Responsive
Loading/Empty/No Results/Error/Permission Denied. استخدم ListPageTemplate/AppDataView والتوكنز الحالية، والتعامل مع RTL/LTR وLight/Dark.

## مراجعة
لا تنفيذ لهذه الجداول ضمن catalog في vscode. أسماء الجداول ومسارات الشاشة وتفاصيل الحقول يجب تأكيدها مقابل schema الفعلية والسيناريو قبل التنفيذ. لا migrations أو UI.