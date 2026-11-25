# وثائق تصميم الواجهات

هذه الوثائق تضبط سير العمل من فهم المهمة إلى مواصفة الشاشة ثم التنفيذ والتحقق. لا تحل محل المراجع المعتمدة؛ بل تربط بها.

## الوثائق
- [منهجية UI/UX](UI_UX_GUIDELINES.md): كيف نحلل الشاشة ونختار عناصرها وحالاتها دون افتراضات.
- [قالب مواصفة الشاشة](SCREEN_UIUX_SPEC_TEMPLATE.md): قالب موحد يبرر القرارات قبل كتابة الكود.
- [مواصفة CAT-07 — الماركات](specs/CAT-07_brands.md): المواصفة القائمة للماركات.
- [مواصفة CAT-07 — الألوان](specs/CAT-07_colors.md): المواصفة القائمة للألوان.
- [مصدر مواصفة CAT-07 — الألوان (النص الأصلي المرفق)](specs/CAT-07_colors_source_original.md): نسخة المصدر محفوظة مستقلة دون استبدال الوثيقة القائمة.
- [CAT-01 — قائمة المنتجات](specs/CAT-01_products_list.md): مواصفة قائمة المنتجات (غير منفذة).
- [القواعد المشتركة CAT-07](specs/CAT-07_master_data_common.md): قواعد مشتركة للمواصفات المرجعية غير المنفذة.
- [CAT-07 — التصنيفات](specs/CAT-07_categories.md).
- [CAT-07 — أنواع المنتجات](specs/CAT-07_product_types.md).
- [CAT-07 — أنظمة المقاسات](specs/CAT-07_size_systems.md).
- [CAT-07 — وحدات القياس](specs/CAT-07_units.md).
- [CAT-07 — الخصائص ومجموعات الخيارات](specs/CAT-07_attributes_options.md).
- [CAT-07 — الجداول المرجعية الوصفية](specs/CAT-07_descriptive_tables.md).
- [مراجعة التوافق مع vscode](specs/SPEC_FORMAT_REVIEW.md): حدود المراجعة والتعارضات.

## المراجع الملزمة
- [نظام التصميم](../architecture/DESIGN_SYSTEM.md) و[ADR-0003](../architecture/ADR/0003-ledger-design-system.md): الهوية والتوكنز والكثافة.
- [قالب الميزة](../architecture/FEATURE_TEMPLATE.md) و[قائمة مراجعتها](../architecture/FEATURE_CHECKLIST.md): الطبقات والتسليم.
- [قواعد المعمارية](../architecture/ARCHITECTURE_RULES.md) و[خريطة Core](../architecture/CORE_MAP.md) و[دليل استخدامه](../architecture/CORE_USAGE.md): حدود المسؤوليات وإعادة الاستخدام.
- [سيناريوهات المنتج](../product/scenarios/) و[خريطة الشاشات والتنقل](../product/ERP_Screen_Navigation_Map.md): مصدر السلوك والمسارات والصلاحيات.

## دورة العمل
تحليل ← متطلبات ← مواصفة ← قرارات مفتوحة ← تنفيذ ← تحقق.

لا يبدأ التنفيذ قبل مراجعة المواصفة واعتمادها. أي قرار غير مدعوم بمصدر يُسجل بوضوح كاقتراح أو قرار مفتوح، ولا يتحول إلى وظيفة ضمنية.