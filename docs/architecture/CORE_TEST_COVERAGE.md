# تغطية اختبارات Core

> تسجل هذه الوثيقة ملفات الاختبار الموجودة وما تغطيه والفجوات التي ظهرت في الفحص النصي. وجود ملف اختبار لا يثبت نجاحه، وغياب اختبار مباشر لا ينفي وجود تغطية غير مباشرة.

## ملفات الاختبار الموجودة (`test/core/`)

الجدول من فحص ملفات الاختبار فعلياً. غياب اختبار مباشر لا يعني غياب أي تغطية غير مباشرة، لكن لم يُتحقق منها ما لم يُذكر.

| المجال | الاختبارات الموجودة | ما تغطيه |
|---|---|---|
| Access | `access_cubit_test` و`permission_gate_test` و`permission_test` | حالة الدور، `can/canAny/canAll/require`، `PermissionGate`، `Permission.covers` و`Role` |
| DI | `di_singletons_test` | أن `TokenManager` Singleton فقط |
| Error | `failure_translator_test` | ترجمة `Failure` مرة واحدة فقط |
| Foundation | `env_config_test` و`app_config_test` و`api_result_either_test` و`app_validator_test` | التحقق من `EnvConfig`، وتمرير `AppConfig` لقيم البيئة، و`ApiResult.toEither/toEitherAsync`، وقواعد `AppValidator` |
| Network | `api_client_test` و`app_endpoints_test` و`language_interceptor_test` و`logger_redaction_test` و`network_info_test` و`refresh_token_interceptor_test` و`retry_interceptor_test` | تحليل الاستجابات، ترميز المسارات، Accept-Language، إخفاء الحقول الحساسة، `NetworkInfo`، تجديد الجلسة، سلوك Retry |
| Responsive | `adaptive_layout_test` و`rh_builder_test` و`responsive_helper_equivalence_test` و`ui_text_of_test` | اختيار التخطيط، `Rh.builder`، تكافؤ padding/radius، و`context.ui.text.of` |
| Theme | `app_theme_test` و`app_semantic_colors_test` | بناء الثيم دون `BuildContext`، و`AppSemanticColors` (`copyWith`/`lerp`/التسجيل/الوصول عبر `ui.theme`) و`ThemeModeExtension.nameKey` |
| State management | `base_cubit_test` و`effect_mixin_test` | Effects والـ replay |
| Widgets | `app_button_style_test` و`app_navigation_bar_style_test` و`app_navigation_rail_style_test` و`app_sidebar_style_test` و`app_text_test` و`message_view_widgets_test` | أنماط وسلوك الأزرار والتنقل والنص، وألوان وسلوك رسائل SnackBar/Dialog/Loading |
| Storage | `token_manager_test` | `TokenManager` فقط (الكتابة، التراجع، `sessionCleared`) |

- **ودجتات جديدة:** `AppCard` (`app_card_test`) و`AppIconButton` (`app_icon_button_test`، منطقة لمس >= 48) لهما اختبارات مباشرة. حارس الأرقام: `test/architecture/no_magic_numbers_test.dart`. ميزة الهوم: `test/features/home/home_cubit_test.dart`.

## الفجوات المسجلة
- **Error:** لا يوجد اختبار مباشر لـ `ExceptionMapper`. (اختبارات Auth تستخدم أنواع `Failure` لكنها لا تختبره.) `FailureTranslator` له اختبار مباشر.
- **Localization:** لا يوجد اختبار مباشر لـ `LocaleCubit`. يُستخدم داخل `language_interceptor_test` لتأكيد أن تغيير اللغة يصل إلى الطلب التالي، وهي تغطية غير مباشرة محدودة.
- **Routing:** لا يوجد مجلد `test/core/routing`. حراس المسارات الفعلية (خارج Core) مغطاة في `test/routing/route_guards_test.dart`، ولا يغطي ذلك `AppRoutes` أو `RouteTransitions` أو `MyNavObserver`.
- **Storage:** لا يوجد اختبار شامل؛ لا اختبار مباشر لـ Hive (`HiveManager` و`HiveStorageService` و`HiveObjectBox` و`CacheManager`) أو `PrefsStorageService` أو `SecureStorageService` أو `AppSettingsManager`.
- **أخرى بلا ملف اختبار مباشر:** `AuthInterceptor` و`ConnectivityInterceptor` و`CancelTokenRegistry` و`AppIcon` و`AppImage` و`BlocEffectListener` و`AppBlocObserver` و`ThemeCubit`. وبالنسبة إلى `BlocEffectListener` تحديداً، تبقى سلامة التحليل وlifecycle `NOT_VERIFIED`؛ يلزم اختبار Widget مخصص.


## حالة التشغيل

لم تُشغّل `flutter test` أو `flutter analyze` ضمن الفحص النصي؛ وجود الملفات لا يثبت نجاحها. اتبع قاعدة توثيق نتائج الفحوصات في [قواعد المعمارية §9](ARCHITECTURE_RULES.md).
