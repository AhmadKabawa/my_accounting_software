# نظام التصميم (Ledger Design System في الكود)

> المصدر: ملف `DESIGN.md` المعتمد (Ledger Design System). هذه الوثيقة تصف **كيف طُبّق في الكود** وما بقي. عند الاختلاف بين الوثيقة والكود يُعتمد الكود. القرار الملزم في [ADR-0003](ADR/0003-ledger-design-system.md).
> **حالة التحقق:** يُتحقق بـ CI في `flutter-ci.yml` بالأوامر: `pub get`, `dart format --set-exit-if-changed .`, `analyze --no-fatal-infos`, `test`.
> التحقق البصري اليدوي على Chrome عند 360 و1200، بالعربية والإنجليزية، والفاتح والداكن ما زال معلقاً.

## 1. الخريطة: أين يعيش كل شيء

| ما هو | الملف (تحت `lib/app/core/presentation/design_system/`) |
|---|---|
| السلالم الخام والأدوار (فاتح/داكن) | `theme/app_colors.dart` (`AppColors`, `AppLightColors`, `AppDarkColors`) |
| `ColorScheme` | `theme/light_theme.dart`, `theme/dark_theme.dart` |
| الألوان الدلالية والمحاسبية والحالات والرسوم | `theme/extensions/app_semantic_colors.dart` |
| الأنماط النصية والخط | `theme/app_text_styles.dart` (`AppTextStyles`, `AppFontFamily`) |
| تجميع الثيم | `theme/build_theme.dart`, `theme/app_theme.dart` |
| ثيمات مكونات Material | `theme/components/*.dart` |
| tokens المتجاوبة (spacing, radius, font, icon, elevation, border, component size, grid, density) | `responsive/engine/app_enums/` |
| الحركة وطبقات z-index | `tokens/app_motion.dart`, `tokens/app_layer.dart` |

الوصول من الواجهات: `context.ui.theme.colors` (ColorScheme) و`context.ui.theme.semanticColors` و`context.ui.text.of(AppTextType.x)`. لا ألوان ولا أرقام مباشرة في الميزات.
- كثافة المكونات: `context.ui.density.current` و`resolve(override)` و`fieldHeight/rowHeight/headerHeight` عبر `DensityHelper`. يحدد `AppDensityScope` الكثافة لشجرة فرعية، والافتراضي `comfortable`. يمكن تمرير `density` صراحةً إلى `AppButton` و`AppIconButton` و`AppTextField`؛ وعلى الهاتف لا يغيّر compact ارتفاع عناصر التحكم.

## 2. ما تغيّر

### الألوان
- أخضر فيروزي واحد (`green-600`) + محايدات بميل أخضر؛ حُذف الأصفر (secondary) والبرتقالي (tertiary) وأي أزرق/تدرجات موروثة.
- الداكن تصميم مستقل (`AppDarkColors`) بالأسماء نفسها.
- `surface` = البطاقات والجداول (أبيض/#1C1C1C)، و`scaffoldBackgroundColor` = SaaS `canvas` (#F0F2F1/#171717) عبر معامل `background` في `buildTheme`. في الفاتح يبقى `AppLightColors.background` = neutral-50 (#F7F8F7)، بينما `AppLightColors.canvas` = neutral-100 (#F0F2F1) وفق قرار توكنات SaaS في commit 0609028 واختبار `app_colors_test` في commit 1ee9d17.
- `ColorScheme.outline` = `outline-control` (حدود الحقول، تباين 3:1)، و`outlineVariant` = `outline` (حدود البطاقات والفواصل). `surfaceTint` شفاف.
- `AppSemanticColors` توسّع: `x/onX/xContainer` لـ success/warning/info، `debit/credit` محايدان، `balancePositive/Negative`، خمس حالات مستندات (`StatusColor`)، 8 سلاسل رسوم (`chartColor(i)`)، و`onSurfaceMuted/outlineStrong/focusRing`.
- `onSuccess/onWarning/onInfo` في الداكن مشتقة من `background` (غير واردة في ملف التصميم) لضمان تباين ≥ 4.5.
- `inverseSurface` للداكن مشتق (#ECECEC على #171717) لعدم ورود قيمته.

### الطباعة
- الخط `IBM Plex Sans Arabic` في `ThemeData.fontFamily`؛ `IBM Plex Mono` للباركود/SKU فقط (`AppTextType.codeMono`).
- `AppFontSize.tiny` حُذف و`xs` صار 12/12/13 و`sm` 13/13/14.
- أدوار جديدة في `AppTextStyles` و`AppTextType`: `amountKpi` و`amountLg` و`amountTable` و`docCode` (مع `tnum`+`lnum`) و`tableHeader` و`codeMono`. `AppTextStyle` صار يحمل `fontFamily` و`fontFeatures` ويحترمهما `resolve`.
- ارتفاع السطر 1.5 للنصوص و1.2–1.4 للعناوين والمبالغ، و`letterSpacing` صفر.
- أُصلح سقف `bodyMedium` (كان `sm` ويقصّ 14 إلى 12 على الهاتف): صار `md`.

### التوكنز والـ enums
| التوكن | التغيير |
|---|---|
| `AppRadius` | سلم التصميم (4/6/8/12/16)؛ أُضيف `xxl` خارج السلم لشريط pill فقط؛ `full` للشارات |
| `AppFontSize` | حذف `tiny`، رفع `xs` و`sm` |
| `AppSpacing` / `AppElevation` / `AppIconSize` / `AppBorderWidth` / `AppComponentSize` / breakpoints (600/1200) / أقصى عرض محتوى (720/1200) | **مطابقة أصلاً لملف التصميم، لم تتغير** (تحقق منها `design_tokens_test`)؛ أُضيف `AppComponentSize.logoPreview` (72/80/88) لمعاينات الشعارات في الشبكة |
| `AppGrid` **جديد** | أعمدة/هامش/فاصل: 4/16/12 · 8/24/16 · 12/32/24 |
| `AppDensity` **جديد** | comfortable (صف 48، رأس 40، حقل 44) وcompact (36/32/36) مع حد لمس 44 على الهاتف |
| `AppMotionDuration` + `AppMotion` **جديد** | 150/200/300ms، ثلاثة منحنيات، وتصير المدة 0 مع «تقليل الحركة» |
| `AppLayer` **جديد** | z-index: content 0 … loading-overlay 80 |
| لون الظل | من `ColorScheme.shadow` بشفافية 12% بدل `Colors.black` |

### المكونات
- ثيمات Material: بطاقة بحدّ بلا ظل، حقل بحدّ control وحلقة تركيز 2px بـ `focusRing`، شريحة `StadiumBorder`، Bottom sheet زاوية `xl`، شريط تنقل Material بمؤشر `primaryContainer`، أزرار بارتفاع 44 وزاوية `md`.
- `AppButton`: `small` = 36 و`medium` = 44 (hitArea).
- `AppCard`: سطح `surface` وزاوية `lg`.
- `AppNavigationRail`/`AppSidebar`: العنصر النشط `primaryContainer`/`onPrimaryContainer` (`nav-item-active`).
- `AppNavigationBar`: نمطان فقط (`minimal` افتراضي، `pill`)؛ حُذف `blur` ومعامل `elevation`؛ حركته تحترم `AppMotion`.
- AppBadge (C02): L1، نغمات neutral/success/warning/info/error وأحجام small/medium، أيقونة اختيارية ونص AppKey إلزامي. يستخدم أزواج الألوان الدلالية الموجودة وColorScheme مع تباين نص مستهدف >= 4.5؛ AppBadgeStyle يحل التوكنز. DocStatusBadge يجهز حالات DRAFT/POSTED/REVERSED/CANCELLED وUNPAID/PARTIAL/PAID فوقه؛ يُستخدم حالياً في C12 ويصل إليه C46 عبر ScopeSelector، بينما CAT-07 لم يُبنَ بعد.
- نوافذ الرسائل (Dialog) زاوية `xl`. `AppTextField` يستخدم `focusRing`.
- `home_overview_section`: لم تعد تستعمل `secondary/tertiary/error` لأرقام الملخص بل ألوان الرسوم.

### تنسيق المبالغ
- `AmountFormatter` (C13) و`Money` في `lib/app/core/foundation/money/` ([ADR-0005](ADR/0005-money-type-and-amount-formatter.md)): أرقام غربية، فاصل آلاف `,` وعشري `.`، كسور حسب العملة، علامة `−` (U+2212) تختفي لقيمة تصير صفراً، عزل Bidi (`LRI…PDI`) حول الرقم بعلامته، رمز العملة خارج العزل، ولا اختصار. اجتازت اختبارات الوحدة الآلية في CI؛ لم يُستعمل في شاشة بعد (طيّاره CAT-03).

### الاختبارات
جديد: `app_colors_test` (ربط الأدوار + تباين WCAG للوضعين)، `app_text_styles_test`، `design_tokens_test` (radius/spacing/component/grid/density)، `tokens/app_motion_test`. معدَّل: semantic colors وtheme وbutton وnavigation bar/rail/sidebar.

## 3. المتبقي (لم يُنفَّذ أو يحتاج قراراً)

1. **ملفات الخط:** لم يُضمَّن `IBM Plex Sans Arabic` ولا `IBM Plex Mono` (لا شبكة في بيئة التنفيذ). نزّل الملفات (ترخيص OFL) إلى `assets/fonts/` وصرّح بها في `pubspec.yaml` بأوزان 400/500/600/700 (والـ Mono 400). حتى ذلك يستخدم التطبيق خط النظام. تصريح الخط دون الملفات يكسر البناء، لذلك لم يُضف.
2. **التحقق الآلي:** يُتحقق بـ CI في `flutter-ci.yml` بالأوامر: `pub get`, `dart format --set-exit-if-changed .`, `analyze --no-fatal-infos`, `test`. بقي التحقق البصري اليدوي على Chrome عند 360 و1200، بالعربية والإنجليزية، والفاتح والداكن.
3. **تباين قيم radius لـ tablet/desktop:** نص التصميم يذكر «xs 4/6/8 · sm 8/10/12 · md 12/14/16 …» وهذا يتعارض مع قيم الهاتف (sm=6, md=8). طُبّقت قيم الهاتف المنصوص عليها وقيم التابلت/المكتب بزيادة تدريجية (xs 4/6/8، sm 6/8/10، md 8/10/12، lg 12/14/16، xl 16/20/24). **يحتاج اعتماد صاحب التصميم.**
4. **مكوّنات ذات أولوية لم تُبنَ:** جدول بيانات (3 تمثيلات)، حقل مبلغ مع عملة، قائمة منسدلة مع بحث، منتقي تاريخ/فترة، بطاقة KPI، نافذة تأكيد، شريط فلاتر، شاشة POS، اختيار فرع/مستودع/عملة. بُني AppBadge وDocStatusBadge (C02) ويُستخدمان في C12/C46؛ CAT-07 لم يُبنَ بعد، لذلك يظل C02 «مراجعة» وفق R12. نُفِّذ AppSkeleton (C09) وAppEmptyState (C08) في core/presentation/widgets/، لكنهما لم يُستخدما في شاشة طيّارة بعد. التوكنز اللازمة للبقية جاهزة (status*، amount*، AppDensity، AppGrid).
5. **حالات الاتصال والمزامنة** (غير متصل، بانتظار المزامنة، فشل، تعارض…): غير منفذة.
6. **تنسيق المبالغ:** نُفِّذ (`AmountFormatter` في `core/foundation/money/`، انظر «تنسيق المبالغ» في §2). المتبقي: استعماله في شاشة طيّار (CAT-03) والتحقق البصري من موضع `−` داخل نص عربي؛ اجتازت اختبارات الوحدة الآلية في CI.
7. **الأيقونات:** Material Symbols Outlined (وزن 400) وانعكاس الاتجاهية وأيقونات مخصصة (مستودع، جلسة صندوق…): غير منفذة. ما زالت أيقونات Material الحالية.
8. **تقليل الحركة:** `AppMotion` جاهز لكن بقية widgets/انتقالات الصفحات لم تُنقل إليه (نُقل شريط التنقل السفلي فقط).
9. **`AppLayer`** لا يستعمله شيء بعد (توكن جاهز).
10. **نقطة 900 لتخطيط قائمة+تفاصيل داخل التابلت:** موجودة في توثيق التصميم، لا توكن لها بعد.
11. **`AppDensity` على `AppTextField` و`AppButton` و`AppIconButton`:** نُفِّذ بـ `AppDensityScope` (بلا نطاق = comfortable بمظهر مطابق للسابق). compact على غير الهاتف يقصّر الارتفاع المرئي لـ `AppButton` و`AppTextField` إلى `AppDensity.field` (36)، بينما يحافظ `AppIconButton` على هدف لا يقل عن `AppComponentSize.hitArea` حتى في compact. على الهاتف لا يغيّر compact ارتفاع عناصر التحكم ويحافظ زر الأيقونة على هدفه الطبيعي. اختبارات `app_density_scope_test.dart` و`density_helper_test.dart` تتحقق من الفصل بين ارتفاع الزر المرئي وهدف الأيقونة. لم يُطبَّق بعد على الجدول (C01). **تعارض مفتوح (قرارك):** هذا الملف يذكر الزر الصغير 36 والمتوسط 44 بينما الكود يتدرج حسب الجهاز (44/52 على المكتب في comfortable)؛ لم يُغيَّر comfortable.
12. **افتراضات تنتظر صاحب المشروع:** اسم العلامة والشعار، الأرقام الغربية في الواجهة العربية، ومتى تُستعمل الأزرار الحبّية (`button-primary-pill` غير مضاف كنوع).
13. **Figma بمتغيرات تطابق الأسماء** وملفات الشعار: خارج نطاق الكود.


### مكونات القوائم C04/C10/C01/T1 — 2026-11-19

- SearchableDropdown وFilterBar وAppDataTable وListPageTemplate تستخدم `context.ui`, AppText/AppIcon/AppButton وtokens الموجودة؛ لا نظام ألوان أو قياسات موازٍ ولا حزمة جديدة.
- C01 يقيس عرض الحاوية عبر `ScreenEngine.screenTypeForWidth` (600 و1200 من ScreenEngine)، ويستخدم AppDensityScope: compact لجدول desktop وcomfortable للعرض الأصغر، مع override من المستدعي.
- الفرز والبحث والفلاتر والترقيم من callbacks ومصدر بيانات الشاشة؛ Core لا ينفذ استعلامات ولا يفرز مجموعة الخادم محلياً.
- لم يُتحقق بعد من التباين/overflow بصرياً على Chrome عند 360/600/900/1200 أو من دعم المنصات الأخرى؛ الاختبارات المكتوبة لا تُعد ناجحة قبل تشغيلها.

- C01 يختار mobile load more من `hasMore/onLoadMore`، بينما tablet/desktop يرسلان page/pageSize callbacks؛ لا تُحمّل المجموعة كاملة لفرزها محلياً.

- C01 يستعمل AppCard لسطح بطاقات الهاتف؛ لا يُعاد تعريف radius أو border أو surface colors داخل DataTable.


## نغمات الأيقونات (AppIconTone)

| tone | المعنى واستخدامه |
|---|---|
| danger | حذف/تعطيل/خطر؛ من `colors.error` |
| success | تفعيل/نجاح؛ من `semanticColors.success` |
| warning | تحذير؛ من `semanticColors.warning` |
| info | معلومة؛ من `semanticColors.info` |
| primary | إضافة/إجراء أساسي؛ من `ColorScheme.primary` |
| neutral | تعديل/عرض/ثانوي؛ من `ColorScheme.onSurface` |

هذه دلالات عامة لا تنشئ palette موازية. تمرير لون مباشر يتجاوز دلالة tone ويُمنع في Features.
