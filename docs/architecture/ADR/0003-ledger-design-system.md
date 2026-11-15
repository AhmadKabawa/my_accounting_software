# ADR-0003: اعتماد Ledger Design System للثيم والتوكنز

- **الحالة:** معتمد (التنفيذ جزئي: انظر «المتبقي» في [DESIGN_SYSTEM.md](../DESIGN_SYSTEM.md))
- **التاريخ:** 2026-11-15
- **الجهة صاحبة القرار:** مشرفو المشروع
- **النطاق:** `lib/app/core/presentation/design_system/` والـ widgets المشتركة

## السياق

كان الثيم موروثاً من هوية أخرى: أخضر مع أصفر (secondary) وبرتقالي (tertiary)، ومدين/دائن بأحمر وأخضر، وأصغر خط 8–10 على الهاتف، وخمسة أنماط لشريط التنقل السفلي، وظلال على البطاقات. ملف «Ledger Design System» يحدد هوية مستقلة لبرنامج محاسبة عربي RTL.

## القرار

1. **الألوان طبقتان:** سلالم خام (`AppColors`) وأدوار بأسماء ثابتة (`AppLightColors`/`AppDarkColors`). الداكن تصميم مستقل. الشاشات تقرأ عبر `context.ui.theme` فقط.
2. **هوية واحدة:** أخضر `green-600` + محايدات. حُذف الأصفر والبرتقالي (`secondary` محايد، ولا `tertiary`).
3. **المحاسبة:** `debit`/`credit` محايدان يرافقهما نص أو أيقونة؛ الرصيد السالب `balanceNegative` مع علامة `−`؛ الأحمر للخطأ فقط.
4. **الطباعة:** IBM Plex Sans Arabic، حد أدنى 12، `letterSpacing` صفر، ارتفاع سطر 1.5 للنصوص، وأدوار مبالغ بـ `tnum` و`lnum`.
5. **العمق بالحدود:** البطاقات حدّ `outlineVariant` على `surface` دون ظل؛ الظل للطبقات العائمة بلون `shadow` وشفافية 12%.
6. **حقل الصفحة منفصل عن البطاقة:** `scaffoldBackgroundColor` = `background`، و`ColorScheme.surface` = البطاقات.
7. **شريط التنقل السفلي:** نمطان فقط `minimal` (الافتراضي) و`pill`؛ حُذفت `elegant` و`glassmorphism` و`neon` ومعها `blur` و`elevation`.
8. **التوكنز الجديدة:** `AppGrid` و`AppDensity` و`AppMotion` و`AppLayer`، وحُذف `AppFontSize.tiny`.
9. اللون وحده لا ينقل حالة، والحركة تُصفَّر عند «تقليل الحركة».

## النتائج

- اختبارات تباين WCAG تفشل إن كُسر زوج لوني (`app_colors_test`).
- تغيير breaking: حذف `NavBarStyle.elegant/glassmorphism/neon` ومعامل `elevation` و`AppFontSize.tiny`؛ ومن يستعمل `scheme.secondary/tertiary` يتغير لونه.
- حجم `AppButtonSize.small/medium` صار 36/44 بدل 32/40.

## التحقق

- لم يتوفر Flutter SDK في بيئة التنفيذ: لم تُشغَّل `flutter analyze` ولا `flutter test`. نسب التباين حُسبت بسكربت Python وتطابق جدول التصميم.
