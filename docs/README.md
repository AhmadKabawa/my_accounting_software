# فهرس الوثائق — VAUDE ERP

## من أين أبدأ

1. [`../AGENTS.md`](../AGENTS.md) و[`../CLAUDE.md`](../CLAUDE.md): تعليمات العمل على المستودع.
2. [`product/V1_SCOPE.md`](product/V1_SCOPE.md): ما يُبنى في الإصدار الأول وبأي ترتيب.
3. [`OPEN_DECISIONS.md`](OPEN_DECISIONS.md): المحسوم والمؤجل والمفتوح.
4. [`design/README.md`](design/README.md): منهجية UI/UX وقالب مواصفات الشاشات ومواصفة CAT-07.

## خريطة المرجعية (عند التعارض أيهما يغلب)

| الموضوع | المرجع | يليه |
|---|---|---|
| البيانات والدوال وأكواد الأخطاء | القاعدة نفسها، ثم [`backend/DATA_MODEL.md`](backend/DATA_MODEL.md) (قرار-51) | [`backend/SUPABASE_API_INTEGRATION.md`](backend/SUPABASE_API_INTEGRATION.md) و[`backend/GET_MY_ACCESS.md`](backend/GET_MY_ACCESS.md) |
| السلوك والسيناريوهات | [`product/scenarios/`](product/scenarios/README.md) | سجل القرارات `A4_decisions_log.md` |
| الشاشات والتنقل | [`product/ERP_Screen_Navigation_Map.md`](product/ERP_Screen_Navigation_Map.md) | [`product/ERP_System_Dependency_Map.md`](product/ERP_System_Dependency_Map.md) |
| المكوّنات (وترتيب العمل وقوالب التكليف) | [`product/Missing_UI_Components_Priority_Plan.md`](product/Missing_UI_Components_Priority_Plan.md) وترتيب العمل [`COMPONENT_WORK_ORDER.md`](product/COMPONENT_WORK_ORDER.md) | الكود في `lib/app/core/presentation` |
| مظهر التصميم (توكنز وألوان وخطوط) | **الكود**، ثم [`architecture/DESIGN_SYSTEM.md`](architecture/DESIGN_SYSTEM.md) | ADR-0003 |
| المنصات (ويب الآن، هاتف وWindows لاحقاً) | [`architecture/PLATFORM_STRATEGY.md`](architecture/PLATFORM_STRATEGY.md) | قرار-82 |
| الهندسة والحدود بين الطبقات | [`architecture/ARCHITECTURE_RULES.md`](architecture/ARCHITECTURE_RULES.md) | ADR في `architecture/ADR/` |

القاعدة: القاعدة (Supabase) مصدر الحقيقة للبيانات، فإن خالفتها وثيقة صُحّحت الوثيقة (قرار-51).

## المجلدات

| المجلد | المحتوى |
|---|---|
| `architecture/` | المعمارية والـ Core والتصميم والترجمة والأمان وقرارات ADR |
| `backend/` | نموذج البيانات وتكامل Supabase وعقد `get_my_access` |
| `product/` | نطاق v1، السيناريوهات (مقسمة بالوحدة)، خريطة الشاشات والاعتماديات، خطة المكوّنات |
| `design/` | منهجية تحليل UI/UX، قالب مواصفة الشاشة، ومواصفات الشاشات المعتمدة |
| `OPEN_DECISIONS.md` | سجل واحد للنقاط المفتوحة والمؤجلة |

## قواعد صيانة الوثائق

- لا تُنسخ قاعدة من مرجعها إلى وثيقة أخرى؛ تُوضع إحالة (ADR-0001 بند 8).
- لا تُثبَّت أعداد تتقادم (عدد الملفات أو الأسطر).
- بند مفتوح جديد يُضاف إلى `OPEN_DECISIONS.md` فقط.
- قرار جديد يأخذ الرقم التالي في `product/scenarios/A4_decisions_log.md`.
