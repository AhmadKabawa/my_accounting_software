# قالب الميزة: Auth هو المرجع

ميزة `features/auth` هي النموذج الذي تُبنى عليه بقية الميزات. هذا الملف يصف بنيتها وما يُنسخ منها؛ القواعد الملزمة في [قواعد المعمارية](ARCHITECTURE_RULES.md) وقائمة التسليم في [قائمة مراجعة الميزة](FEATURE_CHECKLIST.md).

## الشجرة

```
features/<feature>/
  di/                      تسجيل اعتماديات الميزة فقط (يستدعيه app_di.dart)
  domain/
    entity/                كيانات نقية (freezed) بلا Flutter/Dio
    repositories/          عقود Repository
    usecase/               حالة استخدام لكل فعل
  data/
    models/                DTO وتحويل JSON
    datasources/           remote / local
    repositories/          تنفيذ العقود وتحويل AppException إلى Failure
  presentation/
    cubit/                 Cubit + states/ (حالة مستمرة) + effect/ (أفعال لمرة واحدة)
    pages/<page>/          شاشة واحدة لكل مجلد، وبجانبها widgets/ الخاصة بها
    sections/              أقسام الشاشة عندما تكبر (مثل profile وhome)
    widgets/               ودجتات مشتركة بين صفحات الميزة نفسها
```

## ما يُنسخ من Auth

- **إطار الصفحة:** `AuthPageScaffold` يجمع التخطيط والتمرير وحد العرض والعنوان، وهو المكان الوحيد الذي يحوّل `AuthEffect` إلى رسالة. صفحة جديدة تعطيه `child` فقط.
- **الحالة مقابل الأثر:** البيانات المستمرة في `AuthState`، والرسائل في `AuthEffect` عبر `AppKey` (لا نصاً مترجماً). أثر يجب أن يبقى بعد انتقال الصفحة يُرسَل `replayable: true`.
- **الحقول:** `AuthTextField` و`PasswordField` مع `AppValidator`؛ لا validator موازياً.
- **النصوص والأزرار:** `AppText` و`AppButton` ومفاتيح `AppKeys` في ملفي ar/en.
- **المسارات:** المسار في `AppRoutes` وفي `AppRoutes.all` وفي `publicRoutes` أو `protectedRoutes`، ثم تسجيله في `app_go_router.dart`. الصفحات التي تشارك Cubit مفرداً تأخذه بـ `BlocProvider.value` (`AppRouter._withAuth`).
- **الحراس:** `resolveRedirect` دالة نقية مغطاة في `test/routing/route_guards_test.dart`.

## كيف تضيف ميزة جديدة

1. أنشئ الشجرة أعلاه بالطبقات التي لها مسؤولية فعلية فقط.
2. سجّل الاعتماديات في `features/<feature>/di/` واستدعِها من `app_di.dart` بعد ما تعتمد عليه.
3. أضف المسارات ومفاتيح الترجمة بلغتين.
4. اتبع [قائمة مراجعة الميزة](FEATURE_CHECKLIST.md).

## قيود معروفة

- `features/home` ما زال محتوى تجريبياً من قالب سابق (بيانات banners ثابتة وألوان خام) ولم يُحوَّل إلى هذا القالب.
- `splash_di.dart` يستورد `AuthCubit` مباشرة؛ انظر «المخالفات المعروفة» في قواعد المعمارية.
