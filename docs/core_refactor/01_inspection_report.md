# تقرير الفحص — إعادة تنظيم Core (قبل أي تعديل)

- الفرع الأساس: `vscode` (آخر commit: `3545dd1 delete files`)
- فرع العمل: `claude/core-refactor`
- لم يُنفَّذ أي نقل أو تعديل على الكود حتى الآن.

## 1. حالة البيئة

- حزمة المشروع: `accounting_software`.
- **Flutter/Dart غير مثبّتين في بيئة العمل**، لذا **المرحلة 0** (`flutter analyze` و`flutter test` كخط أساس) لم تُنفَّذ بعد. بدونها لا يمكن التحقق بعد كل مرحلة.
- عدد أسطر الـ imports التي تشير إلى `app/core`: **378** (الخطة ذكرت ~382)، منها في **86 ملفًا** خارج `core` (مطابق).

## 2. تعارضات بين الخطة والكود الفعلي

| # | ما تقوله الخطة | الواقع في الفرع | المقترح |
|---|---|---|---|
| 1 | `spacing.dart` في `constants/` | **غير موجود** (فيه `image_constants.dart` فقط) | لا شيء يُنقل |
| 2 | `app_responsive_configs.dart` موجود | **غير موجود** في الفرع | لا شيء يُنقل |
| 3 | `utils/helper/extensions.dart` يُنقل | **غير موجود** (`utils/` فيه `logger.dart` و`observer/` فقط) | تخطّيه |
| 4 | `server_error_translator.dart` ضمن translators | **غير موجود** (يوجد `failure_translator.dart` فقط) | نقل `failure_translator.dart` |
| 5 | Responsive بلا علاقات `part` | **توجد `part / part of` كثيرة** (`app_enums.dart` + 12 ملفًا، `ui_extension.dart` + 13 ملفًا، `responsive_helper` + ملف) | نقل المجلدات كاملة بترتيبها الداخلي، دون فصل أي ملف |
| 6 | `access_extension.dart` يذهب إلى `access/extensions/` وCubit إلى `access/cubit/` | كلها حاليًا في جذر `access/` | ينفَّذ كما في الخطة |
| 7 | استخدامات `context.uiStyles`: 5 في widgets + 2 في الاختبارات | الفعلي: **4** في widgets (`app_button.dart` ×1، `custom_navigation_bar.dart` ×3) + **2** في الاختبارات + تعليقان + تعريف الامتداد | تحديث الكل |
| 8 | `BlocEffectListener` كلاس واحد | **معرَّف مرتين في الملف نفسه** (السطر 10 والسطر 87) | حسب §12: تسجيل فقط، دون إصلاح |
| 9 | `CustomNavigationBar` يُستخدم من features | يُستخدم في `lib/app/main_navigation_bar/.../main_pages_screen.dart` | تحديثه كما في §8 |
| 10 | `home_screen copy.dart` | ملف في features يحتوي مراجع للـ spacing | يتبع تحديث الـ imports فقط |

## 3. الملفات التي ستُنقل (ملخّص حسب المرحلة)

1. **foundation:** `use_case.dart` و`use_case_no_params.dart` إلى `foundation/base/`، `validator/form_validator.dart` إلى `foundation/validation/`، `utils/logger.dart` إلى `foundation/utils/`.
2. **error:** `exceptions.dart` إلى `exceptions/app_exception.dart`، `api_exception.dart`، `failure/` إلى `failures/`، `mapper/` إلى `mappers/`.
3. **services:** `services/network` إلى `network/`، `services/local_storage` إلى `storage/` (hive/secure/shared_preferences)، تسمية `app_settings_manager_sorage.dart` إلى `app_settings_manager.dart`، و`localization/` من `foundation/` إلى `core/`، و`enum_app_language.dart` إلى `app_language.dart`.
4. **presentation foundation:** `base_cubit.dart` و`effect_mixin.dart` و`base_widget_listener.dart` (إلى `bloc_effect_listener.dart`) و`app_bloc_observer.dart` إلى `presentation/state_management/`.
5. **design system:** `responsive/` و`theme/` إلى `presentation/design_system/`، و`theme/logic/cubit` إلى `theme/cubit`، و`theme/logic/theme_extension.dart` إلى `theme/extensions/`.
6. **widgets:** `button_styles.dart` و`navbar_styles.dart` و`custom_navigation_bar.dart` و`message_view_widgets.dart` + تغيير أسماء الكلاسات (`ButtonStyles` و`NavbarStyles` و`CustomNavigationBar`) + حذف `app_styles.dart` و`styles_extension.dart` فقط.
7. **access/routing:** `access/` إلى cubit/extensions/permission_gate، و`app_router_observer.dart` إلى `routing/`.
8. **tests:** نقل حسب جدول §13، مع تحويل الـ imports النسبية (`../../helpers/memory_storage.dart` و`fake_adapter.dart`) إلى `package:accounting_software/...` أو إبقاء الاختبار في مكانه وتسجيل ذلك.

## 4. ملاحظات

- `AGENTS.md` يمنع نقل الملفات دون ضرورة، لكن طلبك الصريح لهذه المهمة يعدّ الضرورة؛ لن أخالف باقي قواعده (لا طبقات جديدة، لا تغيير منطق).
- لا حذف لأي كود ميت؛ سيُسجَّل فقط (مثل تكرار `BlocEffectListener` أعلاه).

## 5. المطلوب منك قبل البدء

1. الموافقة على هذا الفحص والتعارضات أعلاه.
2. تحديد كيفية تنفيذ المرحلة 0: لا يوجد Flutter هنا، فإما أحاول تثبيته (قد يمنعه الـ proxy)، أو أتابع بدونه معتمدًا على فحص نصّي صارم (grep للمراجع القديمة) وأنت تشغّل `flutter analyze` و`flutter test` محليًا بعد كل push.
