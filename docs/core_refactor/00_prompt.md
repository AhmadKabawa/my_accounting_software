هذا الطلب المعدّل. حذفت كل ما يخص حذف الأكواد الميتة، وأضفت قاعدة صريحة تمنع ذلك، وحدّثته بما ظهر في فحص الفرع.

---

# المهمة: إعادة تنظيم Core في مشروع Flutter

أريد إعادة تنظيم مجلد `core` وفق الهيكل أدناه، مع تنظيم أسماء الملفات والكلاسات وتوزيع المسؤوليات.

المطلوب: تحسين البنية والتسمية والحفاظ الكامل على سلوك التطبيق والوظائف الحالية.

**لا يُحذف أي كود أو ملف ميت في هذه المهمة (انظر القسم 12).**

قبل أي تعديل، افحص الفرع الفعلي وطابق الملفات والمسارات، ولا تعتمد على افتراضات.

# 1. الهيكل المستهدف

```text
core/
│
├── foundation/
│   ├── base/
│   ├── config/
│   ├── constants/
│   ├── types/
│   ├── utils/
│   └── validation/
│
├── access/
│   ├── cubit/
│   ├── extensions/
│   ├── permission_gate/
│   └── ...
│
├── di/
│
├── error/
│   ├── exceptions/
│   ├── failures/
│   ├── mappers/
│   └── translators/
│
├── localization/
│   ├── cubit/
│   └── translations/
│
├── network/
│   ├── dio/
│   │   └── interceptors/
│   ├── cancel/
│   ├── network_info/
│   ├── realtime/
│   ├── api_client_interface.dart
│   └── api_end_points.dart
│
├── storage/
│   ├── hive/
│   ├── secure/
│   ├── shared_preferences/
│   ├── storage_service.dart
│   ├── storage_key.dart
│   └── storage_keys.dart
│
├── routing/
│
└── presentation/
    ├── state_management/
    │
    ├── design_system/
    │   ├── responsive/
    │   │   ├── engine/
    │   │   ├── extension/
    │   │   └── helper/
    │   │
    │   └── theme/
    │       ├── cubit/
    │       │   ├── theme_cubit.dart
    │       │   └── theme_state.dart
    │       │
    │       └── extensions/
    │           └── theme_extension.dart
    │
    └── widgets/
        ├── app_button/
        ├── app_navigation_bar/
        ├── app_message/
        ├── app_text/
        ├── app_icon/
        └── ...
```

الملفات التي لا تذكرها الشجرة صراحة (مثل `app_colors.dart` و`app_text_styles.dart` و`app_theme.dart` في جذر `theme/`، و`permission.dart` و`permissions.dart` و`role.dart` في جذر `access/`) تبقى في مكانها النسبي ولا تُنشأ لها مجلدات جديدة.

# 2. Foundation

| المصدر الحالي | الوجهة |
|---|---|
| `foundation/base_mixin/base/base_usecases/use_case.dart` | `foundation/base/use_case.dart` |
| `foundation/base_mixin/base/base_usecases/use_case_no_params.dart` | `foundation/base/use_case_no_params.dart` |
| `foundation/config/` | `foundation/config/` (بلا تغيير) |
| `foundation/constants/` | `foundation/constants/` (بلا تغيير، ويشمل `image_constants.dart` و`spacing.dart`) |
| `foundation/types/` | `foundation/types/` (بلا تغيير) |
| `foundation/validator/` | `foundation/validation/` |
| `utils/logger.dart` | `foundation/utils/logger.dart` |

- `spacing.dart` **يبقى** ولا يُحذف.
- لا تنقل `image_constants.dart` إلى `presentation/assets/`.
- لا تنشئ ملفات غير موجودة لمجرد استكمال الهيكل.

# 3. Localization

انقل `foundation/localization/` إلى `core/localization/`، مع الحفاظ على:
- `cubit/`: LocaleCubit وLocaleState.
- `translations/`: ملفات اللغات والمفاتيح وAsset Loader وLocalization Extension.

أعد تسمية `enum_app_language.dart` إلى `app_language.dart` (الكلاس `AppLanguage` مطابق أصلًا).

# 4. Error Handling

| المصدر | الوجهة |
|---|---|
| `error/error_handling/exceptions/exceptions.dart` | `error/exceptions/app_exception.dart` |
| `error/error_handling/exceptions/api_exception.dart` | `error/exceptions/api_exception.dart` |
| `error/error_handling/failure/failure.dart` | `error/failures/failure.dart` |
| `error/error_handling/mapper/` | `error/mappers/` |
| `error/translators/` | `error/translators/` (بلا تغيير، بكل ملفاته) |

احتفظ بجميع الاستثناءات والـ Failures الموجودة.

# 5. Network وStorage

انقل `services/network/` بالكامل إلى `core/network/` مع الحفاظ على بنيته الداخلية، **بما فيها مجلد `realtime/` بملفيه**.

انقل `services/local_storage/` إلى `core/storage/`:
- `hive_storage/` إلى `hive/`.
- `secure_storage/` إلى `secure/`.
- `shared_storage/` إلى `shared_preferences/`.
- `storage_service.dart` و`storage_key.dart` و`storage_keys.dart` إلى جذر `storage/`.

أعد تسمية `app_settings_manager_sorage.dart` إلى `app_settings_manager.dart` (الكلاس `AppSettingsManager` مطابق أصلًا).

لا تغيّر واجهات الخدمات أو سلوكها.

# 6. State Management

اجمع داخل `presentation/state_management/`:
- `base_cubit.dart`
- `effect_mixin.dart`
- `bloc_effect_listener.dart` (من `base_widget_listener.dart`، والكلاس `BlocEffectListener` مطابق أصلًا)
- `app_bloc_observer.dart`

افرد مسارات `base_mixin/base/base_cubit/base_side_effects/` المتداخلة، ولا تُبقِ مجلدات فارغة.

# 7. Responsive وTheme

انقل `presentation/responsive/` بالكامل إلى `presentation/design_system/responsive/`، و`presentation/theme/` بالكامل إلى `presentation/design_system/theme/`.

بنية الـ Theme:

```text
theme/
├── cubit/
│   ├── theme_cubit.dart
│   └── theme_state.dart
└── extensions/
    └── theme_extension.dart
```

ملاحظات:
- `theme/logic/cubit/*` ينتقل إلى `theme/cubit/`، و`theme/logic/theme_extension.dart` إلى `theme/extensions/`.
- `theme_state.dart` يبقى بجانب `theme_cubit.dart` بسبب `part / part of`.
- في Responsive لا توجد علاقات `part`، لكن توجد `export` نسبية (`../engine/app_enums.dart`) و`import 'screen_engine.dart'`. انقل المجلدات كاملة بحيث تبقى صحيحة.
- لا تحذف أي ملف في Responsive أو Theme، بما فيها `app_responsive_configs.dart` و`card_theme.dart`.
- لا تعدّل اسم امتداد `ThemeExtension` أو محتوى `theme_extension.dart`.

# 8. Widgets وStyles

اعتمد بنية موحدة لكل Widget داخل مجلد خاص به:

```text
app_button/
├── app_button.dart
├── app_button_style.dart
├── app_button_enum.dart
└── app_button_extension.dart
```

هذه هي البنية المعيارية للمستقبل. لا تنشئ هذه الملفات إلا إذا كانت موجودة أو لها حاجة فعلية. وبحسب §14 لا تفصل الـ enums الموجودة داخل ملفات الـ Style (`AppButtonVariant/Size/State` و`NavBarStyle`) إلى ملفات جديدة الآن.

أعد تسمية ونقل:

| الحالي | الجديد |
|---|---|
| `styles/components/button_styles.dart` | `widgets/app_button/app_button_style.dart` |
| `styles/components/navbar_styles.dart` | `widgets/app_navigation_bar/app_navigation_bar_style.dart` |
| `widgets/app_navigation_bar/custom_navigation_bar.dart` | `widgets/app_navigation_bar/app_navigation_bar.dart` |
| `widgets/message_view_widgets.dart` | `widgets/app_message/message_view_widgets.dart` |

وتغيّر أسماء الكلاسات التابعة:
- `ButtonStyles` إلى `AppButtonStyle`.
- `NavbarStyles` إلى `AppNavigationBarStyle`.
- `CustomNavigationBar` إلى `AppNavigationBar`.

لا تغيّر أسماء الـ enums ولا `NavbarVariant` ولا `ButtonVisual`.

حدّث جميع المراجع والاختبارات والتعليقات التي تذكر الأسماء القديمة (بما فيها `main_pages_screen.dart` في features).

باقي الـ Widgets (`app_text`, `app_icon`, `app_image`, `app_appbar`) تبقى في مجلداتها دون حذف أي ملف، بما فيها `app_icon`.

# 9. استبدال AppStyles وstyles_extension

هذا استثناء صريح من قاعدة "لا حذف" لأنه جزء من إعادة هيكلة الـ Styles وليس تنظيفًا لكود ميت:

- احذف `app_styles.dart` و`styles_extension.dart` فقط.
- استبدل `context.uiStyles.button` بـ `AppButtonStyle(context)`.
- استبدل `context.uiStyles.navbar` بـ `AppNavigationBarStyle(context)`.
- تحقق من كل الاستخدامات في lib وtest (الحالية: 5 مواضع في widgets وموضعان في اختبارين).
- لا تترك Imports أو مراجع قديمة، وحدّث التعليقات التي تذكر `context.uiStyles`.
- احذف مجلد `presentation/styles/` بعد أن يفرغ.

# 10. Access

احتفظ بوحدة Access كاملة داخل `core/access/`:

```text
access/
├── cubit/
│   ├── access_cubit.dart
│   └── access_state.dart
├── extensions/
│   └── access_extension.dart
├── permission_gate/
│   └── permission_gate.dart
├── permission.dart
├── permissions.dart
└── role.dart
```

- انقل `PermissionGate` من `widgets/permission_gate/` إلى `access/permission_gate/`.
- حافظ على علاقة `part / part of` بين AccessCubit وAccessState (يبقيان معًا في `cubit/`).
- ملفات access غير المستخدمة (`access_extension.dart`, `ModulePermissions`, `SystemRoles`) **تبقى**.

# 11. Routing وUtils

- `utils/observer/app_router_observer.dart` إلى `routing/`.
- `utils/observer/app_bloc_observer.dart` إلى `presentation/state_management/`.
- `utils/logger.dart` إلى `foundation/utils/`.
- `utils/helper/extensions.dart` إلى `foundation/utils/extensions.dart` (يُنقل ولا يُحذف رغم أنه كله تعليقات).
- احذف مجلدات `utils/` و`services/` وأي مجلد آخر **بعد أن يصبح فارغًا** فقط.

# 12. عدم حذف الأكواد الميتة

لا تحذف في هذه المهمة:
- أي ملف غير مستخدم.
- أي كلاس أو دالة أو تعريف غير مستخدم.
- الكود المعلق (commented code) أو الملفات المعلقة بالكامل.
- أي ملف أو كلاس ثبت أنه مستخدم في الاختبارات فقط.

الاستثناءات الوحيدة:
1. `app_styles.dart` و`styles_extension.dart` (القسم 9).
2. المجلدات التي أصبحت فارغة بعد النقل.
3. الملفات التي يُعاد إنشاؤها بنفس المحتوى بعد إعادة تسميتها (أي استبدال لا حذف).

إذا لاحظت كودًا ميتًا أثناء العمل، لا تحذفه؛ سجّله في قائمة تُعرض في نهاية كل مرحلة تحت عنوان "ملاحظات ميت مرصود (بدون حذف)".

لا تُصلح مشاكل وظيفية مستقلة (مثل التكرار في `base_widget_listener.dart`، أو تشابه اسم `ThemeExtension` مع كلاس Flutter، أو الـ enum `NavBarStyle` المجاور للكلاس الجديد)؛ سجّلها فقط.

# 13. الاختبارات

أعد تنظيم `test/` ليطابق الهيكل الجديد وحدّث Imports:

| الحالي | الهدف |
|---|---|
| `test/core/access/*` | يبقى |
| `test/core/di_singletons_test.dart` | `test/core/di/` |
| `test/core/env_config_test.dart` | `test/core/foundation/config/` |
| `test/core/foundation/api_result_either_test.dart` | `test/core/foundation/types/` |
| `test/core/foundation/{base_cubit,effect_mixin}_test.dart` | `test/core/presentation/state_management/` |
| `test/core/network/*` | يبقى |
| `test/core/services/token_manager_test.dart` | `test/core/storage/secure/` |
| `test/core/presentation/styles/button_styles_test.dart` | `test/core/presentation/widgets/app_button/app_button_style_test.dart` |
| `test/core/presentation/styles/navbar_styles_test.dart` | `test/core/presentation/widgets/app_navigation_bar/app_navigation_bar_style_test.dart` |
| `test/core/presentation/theme/app_theme_test.dart` | `test/core/presentation/design_system/theme/` |
| `test/core/responsive/*` | `test/core/presentation/design_system/responsive/` |

- بعض الاختبارات تستورد `helpers/memory_storage.dart` و`fake_adapter.dart` بمسارات **نسبية**. عند نقل اختبار، حوّل هذه الـ imports إلى `package:accounting_software/...`، أو أبقِ الاختبار في مكانه إن كان التحويل غير ممكن، وسجّل ذلك.
- لا تحذف اختبارًا لمجرد أنه يحتاج تحديث مساره.
- حدّث اختباري الـ Styles لاستعمال `AppButtonStyle(context)` و`AppNavigationBarStyle(context)`.

# 14. قواعد التنفيذ

- حافظ على سلوك التطبيق ولا تغيّر Business Logic.
- لا تغيّر واجهات الخدمات أو توقيعات الدوال إلا ما يلزم لتغيير أسماء Widget/Style المذكورة في القسمين 8 و9.
- لا تنشئ طبقات معمارية إضافية مثل `contracts/` أو `models/` أو `infrastructure/`.
- لا تفصل ملفات `part / part of` عن بعضها.
- لا تقسّم الملفات الكبيرة لمجرد تحسين التنظيم.
- لا تخلط إصلاحات وظيفية مع هذه المهمة.
- استخدم `git mv` للنقل ليحتفظ git بالتاريخ، ولا تعدّل محتوى الملف (غير الـ imports) في نفس commit النقل إلا لإعادة تسمية الكلاس المطلوبة.
- حدّث جميع Imports وExports والمراجع والاختبارات (يوجد حاليًا حوالي 382 import يشير إلى `app/core`، منها في 86 ملفًا خارج `core`).
- بعد كل نقل ابحث نصيًا عن أسماء المجلدات القديمة (`services/network`, `services/local_storage`, `foundation/localization`, `foundation/validator`, `presentation/theme`, `presentation/responsive`, `presentation/styles`, `utils/observer`) للتأكد من عدم بقاء مراجع، بما فيها التعليقات.

# 15. تقسيم العمل إلى Commits

0. **خط أساس:** نفّذ `flutter analyze` و`flutter test` على الفرع قبل أي تعديل، وسجّل النتائج لتمييز الأخطاء السابقة عن الأخطاء الناتجة عن النقل.

ثم كل مرحلة في Commit مستقل:

1. `refactor(core): organize foundation`
2. `refactor(core): organize error handling`
3. `refactor(core): organize services`
4. `refactor(core): organize presentation foundation`
5. `refactor(core): organize design system`
6. `refactor(core): organize shared widgets`
7. `refactor(core): organize access and routing`
8. `refactor(core): normalize naming and tests`

يمكن دمج إعادة التسمية مع مرحلة نقل الملف نفسه. المرحلة 8 للتسميات المتبقية وتنظيم `test/` النهائي، **وليست للحذف**.

بعد كل مرحلة نفّذ:

```bash
dart format .
flutter analyze
flutter test
git status
git diff
```

إذا ظهرت أخطاء، أصلح الناتجة عن المرحلة الحالية فقط، ولا تنتقل للتالية قبل حلها.

# 16. طريقة العمل

قبل أي تعديل:

1. افحص الفرع الحالي وحالة Git.
2. افحص Core وTest بالكامل.
3. طابق الملفات الفعلية مع الخطة.
4. قدّم تقريرًا بالملفات التي ستُنقل وتُعاد تسميتها.
5. اذكر أي تعارض بين الخطة والكود الفعلي.

بعد موافقتي على الفحص، ابدأ مرحلة واحدة فقط في كل مرة.

في نهاية كل مرحلة اعرض:
- الملفات المنقولة.
- الملفات المعاد تسميتها.
- الكلاسات التي تغيرت أسماؤها.
- الاختبارات التي نُقلت.
- ملاحظات الكود الميت المرصود (بدون حذف).
- نتائج `flutter analyze` و`flutter test`.
- رقم الـ Commit.

الهدف النهائي: Core واضح ومنظم وقابل للتوسع، مع توحيد أسماء Widgets وStyles وExtensions، والحفاظ على كل الكود والوظائف الحالية.

---

## ما غيّرته عن النسخة السابقة

1. **القسم 12** صار "عدم حذف الأكواد الميتة" بدل الحذف، مع قائمة صريحة بما يبقى، وطلب تسجيل الميت المرصود دون حذفه.
2. **`spacing.dart` يبقى** (كان مطلوبًا حذفه سابقًا).
3. **`app_responsive_configs.dart` و`card_theme.dart` و`realtime/` و`app_icon/` و`form_validator` و`use_case_no_params.dart` و`server_error_translator.dart` و`extensions.dart`** كلها تُنقل ولا تُحذف.
4. **القسم 9** أبقيته كاستثناء وحيد، لأن حذف `AppStyles` و`styles_extension` جزء من استبدال `context.uiStyles` وليس تنظيف كود ميت. إن أردت إبقاءهما أيضًا فاحذف القسم 9 وأبقِ النظام القديم كما هو، لكن عندها تبقى حلقة الاعتماد بين widgets وstyles.
5. أضفت **المرحلة 0** (خط أساس للـ analyze والاختبارات)، وقاعدة `git mv`، وجدول نقل الاختبارات، وقاعدة التعامل مع الـ imports النسبية في الاختبارات.
6. صححت ما لا يطابق الفرع: لا توجد `part` في Responsive، و`image_constants.dart` أصلًا في `constants/`، وأسماء الكلاسات `AppLanguage` و`AppSettingsManager` و`BlocEffectListener` مطابقة أصلًا للتسمية الجديدة.