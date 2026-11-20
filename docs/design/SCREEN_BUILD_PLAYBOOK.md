# دليل بناء شاشة (للوكيل والمطوّر)

الغاية: أن تمر أي شاشة جديدة بالمسار نفسه فلا تُقبل واجهة ضعيفة.

## الخطوات

1. **المواصفة أولاً:** انسخ `SCREEN_UIUX_SPEC_TEMPLATE.md` إلى `docs/design/specs/`. سجّل بطاقة تحليل: المستخدم، الأعمدة والمعلومات المعروضة، مصدر وسبب كل فلتر، الإجراءات، الحالات (تحميل/فارغ/خطأ)، سلوك الهاتف.
2. **اقرأ** [KNOWN_PITFALLS](../architecture/KNOWN_PITFALLS.md) و[CORE_MAP](../architecture/CORE_MAP.md)؛ استخدم مكوّنات Core ولا تبنِ بديلاً (قاعدة فجوة الـ core).
3. **الهيكل:** `pages/<page>/<page>_screen.dart` رقيقة + `widgets/` و`sections/`؛ ملف ≤ 250 سطراً.
4. **الإطار:** `ListPageTemplate` للقوائم، `AppPageBody` لغيرها؛ لا `Scaffold` مع `Expanded` يحبس التمرير.
5. **القائمة:** `AppDataTable` + `FilterBar` + `AppRowActions`؛ حالات التحميل والفارغ والخطأ كلها.
6. **النصوص:** enum مفاتيح مسجّل في `key_registry.dart`، متغيرات `{name}`.
7. **الاختبار:** اختبار عرض لـ 360/600/900/1200 × RTL/LTR × فاتح/داكن (انظر `brands_screen_responsive_test.dart`).
8. **التحقق:** `dart format .` ثم `flutter analyze` ثم `flutter test`؛ دوّن ما شُغِّل فعلاً وما لم يُشغَّل.
9. إن اكتُشف خطأ جديد فأضفه إلى KNOWN_PITFALLS مع اختبار يفرضه إن أمكن.

## البوابة الآلية

`test/architecture/ui_quality_gate_test.dart` يفشل CI عند: ملف عرض كبير، SnackBar يدوي، `—` أو ربط نصوص، أزرار نصية في الصفوف، جدول بلا `ListPageTemplate`.
