> وثيقة تاريخية بتاريخ 2026-11-04، ليست سياسة حالية.

# التقرير النهائي — إعادة هيكلة core

الفرع: `claude/core-refactor` (من `vscode`). لم يُنفَّذ `flutter analyze` ولا `flutter test` (Flutter غير مثبّت في بيئة العمل)؛ يُشغَّلان محليًا.

## الـ Commits (كل مرحلة دُفعت فور اكتمالها)

| # | الرسالة | commit |
|---|---|---|
| 1 | organize foundation (+ localization، وإعادة تسمية `enum_app_language` إلى `app_language`) | 85a0211 |
| 2 | organize error handling | 7134b03 |
| 3 | organize services (network وstorage، و`app_settings_manager`) | 44e9f69 |
| 4 | organize presentation foundation (state_management) | faccb59 |
| 5 | organize design system | 99ea6e4 |
| 6 | organize shared widgets (+ تغيير أسماء الكلاسات، وحذف AppStyles وstyles_extension) | 081b07f |
| 7 | organize access and routing | d8be401 |
| 8 | normalize naming and tests | fbb3d62 |

## الكلاسات التي تغيّرت أسماؤها

- `ButtonStyles` إلى `AppButtonStyle`
- `NavbarStyles` إلى `AppNavigationBarStyle`
- `CustomNavigationBar` إلى `AppNavigationBar` (و`_CustomNavigationBarState` الخاص إلى `_AppNavigationBarState`)

## الملفات المحذوفة (الاستثناء الوحيد، §9)

`app_styles.dart` و`styles_extension.dart`، واستُبدل `context.uiStyles.*` بـ `AppButtonStyle(context)` و`AppNavigationBarStyle(context)`.

## ما لم يُنفَّذ لأنه غير موجود في الفرع

`spacing.dart` و`app_responsive_configs.dart` و`utils/helper/extensions.dart` و`server_error_translator.dart`.

## التحقق الذي أُجري

- فحص نصّي: كل الـ imports/exports/parts المحلية (611) تشير إلى ملفات موجودة، بلا أي مرجع غير محلول.
- لا مراجع متبقية لأسماء المجلدات القديمة (`services/network` و`services/local_storage` و`foundation/localization` و`foundation/validator` و`presentation/theme` و`presentation/responsive` و`presentation/styles` و`utils/observer`).
- `part / part of` في Responsive وTheme وAccess بقيت كما هي، لأن المجلدات نُقلت كاملة.

## الاختبارات التي نُقلت

`di_singletons_test` إلى `test/core/di/`، `env_config_test` إلى `foundation/config/`، `api_result_either_test` إلى `foundation/types/`، `base_cubit_test` و`effect_mixin_test` إلى `presentation/state_management/`، `token_manager_test` إلى `storage/secure/`، اختبارا الـ Styles إلى `widgets/app_button/app_button_style_test.dart` و`widgets/app_navigation_bar/app_navigation_bar_style_test.dart`، `app_theme_test` إلى `design_system/theme/`، `responsive_helper_equivalence_test` إلى `design_system/responsive/`.

**ملاحظة:** `token_manager_test` يستورد `helpers/memory_storage.dart` بمسار نسبي، ولا يمكن تحويله إلى `package:` لأن `test/helpers` خارج `lib`. لذلك حُدّث عمق المسار النسبي فقط (`../../../helpers/...`) بدل إبقاء الاختبار في مكانه.

## ملاحظات ميت مرصود (بدون حذف)

- `BlocEffectListener` معرَّف مرتين في `bloc_effect_listener.dart` (تكرار كلاس).
- تعليقات imports تشير إلى ملفات غير موجودة: `app_strings.dart` و`app_message_helpers.dart` و`adaptive_helper.dart` و`responsive_helper.dart` (في features).
- `home_screen copy.dart` في `features/home`.
- تعليق ترويسة قديم في `bloc_effect_listener.dart` (`core/widgets/...`).
- `NavBarStyle` (enum) بجوار الكلاس `AppNavigationBarStyle` بتشابه أسماء.
- اسم `ThemeExtension` يتشابه مع كلاس Flutter.
- ملفات access غير المستخدمة (`access_extension.dart` و`ModulePermissions` و`SystemRoles`) أُبقيت كما هي.
