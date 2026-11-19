# تغطية اختبارات Core

> تسجل هذه الوثيقة ملفات الاختبار الموجودة وما تغطيه والفجوات التي ظهرت في الفحص النصي. وجود ملف اختبار لا يثبت نجاحه، وغياب اختبار مباشر لا ينفي وجود تغطية غير مباشرة. اختبارات C47 و`session_access_integration_test` أضيفت في هذا الفرع؛ نتيجة CI هي المرجع للتحقق بعد اكتمال التشغيل.

## ملفات الاختبار الموجودة (`test/core/`)

الجدول من فحص ملفات الاختبار فعلياً. غياب اختبار مباشر لا يعني غياب أي تغطية غير مباشرة، لكن لم يُتحقق منها ما لم يُذكر.

| المجال | الاختبارات الموجودة | ما تغطيه |
|---|---|---|
| Access | `access_snapshot_test` و`access_remote_data_source_test` و`access_cubit_test` و`permission_gate_test` و`permission_test` | طلب RPC المصادق عليه وتحليل عقد `get_my_access`، تجاهل الأكواد غير المعروفة، البريد null، رفض الحقول المشوهة، حالات التحميل/الفشل/النجاح، retry، clear، تبديل الفرع، حجب Shell، fail-closed و`Permission.covers` |
| DI | `di_singletons_test` | أن `TokenManager` Singleton فقط |
| Error | `failure_translator_test` | ترجمة `Failure` مرة واحدة فقط |
| Architecture (Platform) | `platform_isolation_test` | لا `dart:io`/`dart:html`/`kIsWeb`/`Platform.isX` خارج `core/platform/` والاستثناءات الموثقة؛ لم يُشغَّل |
| Error (ERP) | `erp_error_test` | الرموز الـ 29 مقابل DATA_MODEL، ومسار الاستجابة ← الاستثناء ← Failure ← النص العربي/الإنجليزي |
| Foundation | `env_config_test` و`app_config_test` و`api_result_either_test` و`app_validator_test` | التحقق من `EnvConfig`، وتمرير `AppConfig` لقيم البيئة وخيارات حجم الصفحة، و`ApiResult.toEither/toEitherAsync`، وقواعد `AppValidator` |
| Network | `api_client_test` و`app_endpoints_test` و`language_interceptor_test` و`logger_redaction_test` و`network_info_test` و`refresh_token_interceptor_test` و`retry_interceptor_test` | تحليل الاستجابات، ترميز المسارات، Accept-Language، إخفاء الحقول الحساسة، `NetworkInfo`، تجديد الجلسة، سلوك Retry |
| Responsive | `adaptive_layout_test` و`rh_builder_test` و`responsive_helper_equivalence_test` و`ui_text_of_test` و`design_tokens_test` | اختيار التخطيط، `Rh.builder`، تكافؤ padding/radius، و`context.ui.text.of`، وقيم Tokens (radius/spacing/component/border) و`AppGrid` و`AppDensity` |
| Tokens | `app_motion_test` | مدد ومنحنيات الحركة و«تقليل الحركة» و`AppLayer` |
| Theme | `app_theme_test` و`app_semantic_colors_test` و`app_colors_test` و`app_text_styles_test` | بناء الثيم دون `BuildContext`، وربط أدوار الألوان وفحص التباين WCAG (نص 4.5، غير نص 3) للوضعين، وأحجام وأوزان أدوار الخط وأرقام tnum وصفر letterSpacing، و`AppSemanticColors` (`copyWith`/`lerp`/التسجيل/الوصول عبر `ui.theme`) و`ThemeModeExtension.nameKey` |
| State management | `base_cubit_test` و`effect_mixin_test` | Effects والـ replay |
| Widgets | `app_empty_state_test` (C08: AppIcon وAppKey للنصين وslot الإجراء والتخطيط المضغوط)؛ `app_skeleton_test` (C09: الأنواع الأربعة، تأخير الظهور، وتقليل الحركة)؛ `app_button_style_test` و`app_density_scope_test` و`nav_bar_item_test` و`app_navigation_bar_style_test` و`app_navigation_rail_style_test` و`app_sidebar_style_test` و`app_text_test` و`message_view_widgets_test` و`inline_banner_test` و`failure_banner_test` و`flash_messages_test` | أنماط وسلوك الأزرار والتنقل والنص، وألوان وسلوك رسائل SnackBar/Dialog/Loading، و`hideMessage` (لا يغلق الصفحة، يعمل داخل ShellRoute)، وبانر C38 (الأنواع الأربعة، Light/Dark، RTL/LTR، الإغلاق)، وفصل أخطاء التحقق عن النظام وعدم تسرب نص الخادم؛ لم تُشغَّل |
| Storage | `token_manager_test` | `TokenManager` فقط (الكتابة، التراجع، `sessionCleared`) |

- **ودجتات جديدة:** `AppCard` (`app_card_test`) و`AppIconButton` (`app_icon_button_test`، منطقة لمس >= 48) لهما اختبارات مباشرة. حارس الأرقام: `test/architecture/no_magic_numbers_test.dart`. ميزة الهوم: `test/features/home/home_cubit_test.dart`. اختبارات cubits الـ auth والهوم (`session` و`auth_flow` و`profile` و`home`) مكتوبة بـ `blocTest`.

- **Money وAmountFormatter:** `test/core/foundation/money/` (`money_test` و`money_rounding_test` و`amount_formatter_test`): دقة الجمع (`0.1 + 0.2`)، العمليات واختلاف العملات، قراءة PostgREST (نص/رقم/تدوين علمي/قيم مرفوضة)، طرق التقريب والخطوة، تنسيق المبالغ (فواصل، كسور العملة، `−`، عزل Bidi، رمز العملة). **لم تُشغَّل**؛ قيمها المتوقعة فُحصت بنسخة Python من الخوارزمية فقط. لا اختبار عرض بصري لاتجاه `−` داخل نص عربي (يتحقق منه الطيّار CAT-03).

## الفجوات المسجلة
- **Error:** لا يوجد اختبار مباشر لـ `ExceptionMapper`. (اختبارات Auth تستخدم أنواع `Failure` لكنها لا تختبره.) `FailureTranslator` له اختبار مباشر.
- **Localization:** لا يوجد اختبار مباشر لـ `LocaleCubit`. يُستخدم داخل `language_interceptor_test` لتأكيد أن تغيير اللغة يصل إلى الطلب التالي، وهي تغطية غير مباشرة محدودة.
- **Routing:** لا يوجد مجلد `test/core/routing`. حراس المسارات الفعلية (خارج Core) مغطاة في `test/routing/route_guards_test.dart`، ويعتمد على `allRoutes` من `route_registry.dart` (تصنيف public/protected، عدم تكرار path/name، وتطابق السجل مع ملفات `*_routes.dart`). `test/architecture/feature_imports_test.dart` يفرض حدّ الاستيراد بين الميزات، و`test/core/network/app_endpoint_test.dart` يغطي `AppEndpoint`/`encodePathSegment`. لا يغطي ذلك `RouteTransitions` أو `MyNavObserver`.
- **Storage:** لا يوجد اختبار شامل؛ لا اختبار مباشر لـ Hive (`HiveManager` و`HiveStorageService` و`HiveObjectBox` و`CacheManager`) أو `PrefsStorageService` أو `SecureStorageService` أو `AppSettingsManager`.
- **أخرى بلا ملف اختبار مباشر:** `AuthInterceptor` و`ConnectivityInterceptor` و`CancelTokenRegistry` و`AppIcon` و`AppImage` و`BlocEffectListener` و`AppBlocObserver` و`ThemeCubit`. وبالنسبة إلى `BlocEffectListener` تحديداً، تبقى سلامة التحليل وlifecycle `NOT_VERIFIED`؛ يلزم اختبار Widget مخصص.



## تغطية القشرة وقوالب الصفحات C46/C48

- `test/shell/app_shell_test.dart`: تخطيط التنقل responsive، اختيار الوجهات، وفحص إظهار الوجهات بحسب الصلاحيات.
- `test/shell/app_page_templates_test.dart`: تأكيد الخروج بعد حارس التغييرات دون تكرار الحوار، رسالة الخطأ الافتراضية، دعم `ListView` دون تمرير متداخل، وتعطيل الحفظ أثناء `saving`.
- `test/core/presentation/widgets/app_icon_button_test.dart`: مساحة اللمس وسلوك التفعيل والتعطيل لـ `AppIconButton`.
- لا يوجد حتى الآن اختبار مباشر مستقل لـ `AppBreadcrumb` أو `AppMenu` أو `AppPageHeader` أو `AppShellTopBar`. لا تغطي اختبارات AppShell وحدها كل خصائص هذه المكونات.
- لا تزال اختبارات جميع الأدوار السبعة وحارس النماذج في كل الحالات، والتحقق البصري على المتصفح، فجوات معروفة.

## حالة التشغيل

تُسجّل نتيجة كل أمر فقط بعد تشغيله فعلياً في بيئة Dart/Flutter أو في GitHub Actions. وجود الاختبار في المستودع لا يعني نجاح تشغيله.
