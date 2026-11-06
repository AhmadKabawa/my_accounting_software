# تعليمات Claude للمشروع

اقرأ `AGENTS.md` أولاً؛ فهو يحتوي تعليمات المستودع العامة.

مرجع العمل المعماري والـ Core هو [فهرس الوثائق](docs/architecture/README.md):
- `ARCHITECTURE_RULES.md`: السياسة المعمارية وحدود الطبقات (المرجع الوحيد لهذه السياسة).
- `CORE_MAP.md`: اكتشاف الأدوات الموجودة، ثم التحقق من تنفيذها الفعلي.
- `CORE_TEST_COVERAGE.md`: ملفات الاختبار الموجودة والفجوات المعروفة.
- `CORE_USAGE.md`: أمثلة الاستخدام.
- `CODING_STANDARDS.md`: أسلوب كتابة Dart/Flutter.
- `FEATURE_CHECKLIST.md`: مراجعة تنفيذ الميزة.

استخدم Skill `.claude/skills/core-usage/SKILL.md` فقط في الحالات المحددة في وصفه. لا تنسخ قواعد الوثائق إلى هذه التعليمات؛ حدّث المرجع المختص عند تغييرها.

القواعد الجديدة (فجوة الـ core، النصوص، الممنوعات في features) موجودة في `ARCHITECTURE_RULES.md` و[LOCALIZATION.md](docs/architecture/LOCALIZATION.md)؛ لا تنسخها هنا.
