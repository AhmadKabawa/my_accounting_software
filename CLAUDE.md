# تعليمات وكيل البرمجة للمشروع

قبل تنفيذ أي مهمة، اقرأ `AGENTS.md` والتزم بقواعده.

إذا كانت المهمة تمس `lib/app/core` أو تحتاج أداة مشتركة:
1. اقرأ `docs/architecture/CORE_MAP.md`.
2. اقرأ `docs/architecture/CORE_USAGE.md` و`ARCHITECTURE_RULES.md` حسب الحاجة.
3. افحص الكود الفعلي والاختبارات؛ لا تعتمد على الخريطة وحدها.
4. ابحث عن أداة موجودة قبل إنشاء أي بديل.
5. إذا كانت القدرة عامة ومناسبة لـ Core وغير موجودة، أضفها في موضعها الصحيح ثم استخدمها.
6. إذا كانت خاصة بميزة واحدة، أبقها داخل Feature.
7. حدّث توثيق Core والاختبارات عند تغيير القدرة المشتركة.

لا تنفذ إعادة هيكلة أو حذفاً خارج نطاق طلب المستخدم. لا تدّعِ نجاح analyze/test إلا إذا شُغّلا فعلياً.

مراجع Core:
- `docs/architecture/CORE_MAP.md`
- `docs/architecture/CORE_USAGE.md`
- `docs/architecture/ARCHITECTURE_RULES.md`
