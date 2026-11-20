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

- **ودجتات جديدة:** `AppCard` (`app_card_test`) و`AppIconButton` (`app_icon_button_test`، منطقة لمس >= 48) لهما اختبارات مباشرة. حارس الأرقام: `test/architecture/no_magic_numbers_test.dart`. أُزيل اختبار `home_cubit_test.dart` مع إزالة HomeCubit التجريبي؛ AUTH-04 لها اختبار شاشة مستقل أدناه.

- **Money وAmountFormatter:** `test/core/foundation/money/` (`money_test` و`money_rounding_test` و`amount_formatter_test`): دقة الجمع (`0.1 + 0.2`)، العمليات واختلاف العملات، قراءة PostgREST (نص/رقم/تدوين علمي/قيم مرفوضة)، طرق التقريب والخطوة، تنسيق المبالغ (فواصل، كسور العملة، `−`، عزل Bidi، رمز العملة). **لم تُشغَّل**؛ قيمها المتوقعة فُحصت بنسخة Python من الخوارزمية فقط. لا اختبار عرض بصري لاتجاه `−` داخل نص عربي (يتحقق منه الطيّار CAT-03).

## الفجوات المسجلة
- **Error:** لا يوجد اختبار مباشر لـ `ExceptionMapper`. (اختبارات Auth تستخدم أنواع `Failure` لكنها لا تختبره.) `FailureTranslator` له اختبار مباشر.
- **Localization:** لا يوجد اختبار مباشر لـ `LocaleCubit`. يُستخدم داخل `language_interceptor_test` لتأكيد أن تغيير اللغة يصل إلى الطلب التالي، وهي تغطية غير مباشرة محدودة.
- **Routing:** لا يوجد مجلد `test/core/routing`. حراس المسارات الفعلية (خارج Core) مغطاة في `test/routing/route_guards_test.dart`، ويعتمد على `allRoutes` من `route_registry.dart` (تصنيف public/protected، عدم تكرار path/name، وتطابق السجل مع ملفات `*_routes.dart`). `test/architecture/feature_imports_test.dart` يفرض حدّ الاستيراد بين الميزات، و`test/core/network/app_endpoint_test.dart` يغطي `AppEndpoint`/`encodePathSegment`. لا يغطي ذلك `RouteTransitions` أو `MyNavObserver`.
- **Storage:** لا يوجد اختبار شامل؛ لا اختبار مباشر لـ Hive (`HiveManager` و`HiveStorageService` و`HiveObjectBox` و`CacheManager`) أو `PrefsStorageService` أو `SecureStorageService` أو `AppSettingsManager`.
- **أخرى بلا ملف اختبار مباشر:** `AuthInterceptor` و`ConnectivityInterceptor` و`CancelTokenRegistry` و`AppIcon` و`AppImage` و`BlocEffectListener` و`AppBlocObserver` و`ThemeCubit`. وبالنسبة إلى `BlocEffectListener` تحديداً، تبقى سلامة التحليل وlifecycle `NOT_VERIFIED`؛ يلزم اختبار Widget مخصص.



## تغطية AUTH-04 — 2026-11-20

- `test/features/home/dashboard_screen_test.dart`: فلترة البطاقة حسب صلاحية AccessCubit، EmptyState عند غياب الصلاحية، إخفاء الوجهة غير المسجلة، التنقل للمسار المتوقع، semantics كزر، تفعيل Enter وSpace، وعروض 360/600/900/1200 مع RTL/LTR وLight/Dark.
- الاختبارات مكتوبة ولم تُشغّل في هذه المهمة. `dart format --set-exit-if-changed .` و`flutter analyze --no-fatal-infos` و`flutter test`: غير منفذة؛ حالة CI غير مفحوصة. لم يُنفذ تحقق بصري على Chrome. T5 وC08 يظلان «مراجعة» وفق R12.

## تغطية القشرة وقوالب الصفحات C46/C48

- `test/shell/app_shell_test.dart`: التنقل responsive، وعدم وجود استثناءات عند العروض 360/600/900/1200 مع أسماء فروع طويلة، إخفاء ScopeSelector عند غياب الفروع، شارة العرض فقط، استدعاء `beforeBranchChange`، تعطيل الجرس، تنفيذ عناصر قائمة المستخدم، وقائمة «المزيد» لست وجهات مع اختبار الانتقال ومؤشر النشاط.
- `test/shell/destinations_test.dart`: اختبار وحدة لفلترة الوجهات وفق مصفوفة الأدوار السبعة المعرّفة في `ERP_Screen_Navigation_Map.md` وبأكواد الصلاحيات الموثقة في `A3_permissions_views.md`.
- `test/core/presentation/widgets/app_breadcrumb_test.dart`: الفاصل في RTL/LTR، مساحة لمس الرابط، وعدم تكرار اسم العنصر الحالي في شجرة semantics.
- `test/core/presentation/widgets/app_menu_test.dart`: مساحة اللمس، عدم تكرار اسم القائمة في شجرة semantics، واستدعاء الإجراء المختار.
- `test/core/presentation/widgets/app_page_header_test.dart`: تكديس الإجراء في العرض الضيق، بقاؤه بجانب العنوان في العرض الواسع، والعداد الاختياري المعزول اتجاهياً.
- `test/shell/app_page_templates_test.dart`: FormPageTemplate في Loading/Empty/Error/Content، عدم وجود Expanded داخل ScrollView، تمركز EmptyState في مساحة التمرير، تأكيد الخروج مرة واحدة، الإلغاء يبقي الصفحة، والتأكيد يخرج ويستدعي `onDiscard`.
- `test/shell/dashboard_template_test.dart`: DashboardTemplate في Loading/Empty/Error/Grid.
- `test/core/presentation/widgets/app_icon_button_test.dart`: مساحة اللمس وسلوك التفعيل والتعطيل لـ `AppIconButton`.
- `test/shell/stateful_shell_route_preservation_test.dart`: اختبار مكتوب للتحقق من بقاء حالة نموذج الفرع عند التبديل إلى فرع آخر والعودة ضمن indexedStack.
- `test/shell/app_shell_windows_sidebar_test.dart`: اختبار مكتوب لطي Sidebar واستعادة التفضيل من AppSettingsManager.
- `test/shell/unsaved_changes_guard_test.dart`: اختبارات مكتوبة للسماح والرفض، الحالة النظيفة، النقر المزدوج، الشريط السفلي وRail وSidebar وورقة المزيد وقائمة المستخدم وتغيير الفرع المؤسسي.
- أضيفت app_badge_test.dart (كل Tone × Size، مع/بدون أيقونة، RTL/LTR، فاتح/داكن، comfortable/compact، 360/600، نص طويل، وتباين 4.5) وdoc_status_badge_test.dart (كل الحالات الموثقة والحالة غير المعروفة). كما حُدّث unsaved_changes_guard_test.dart لتغطية التبويب غير النشط والنشط، رفض المالك، ترتيب تغيير الفرع، discard بعد النجاح، والنقر السريع على «المزيد».
- نتيجة CI لهذا التحديث: لم يُتحقق من نتيجة GitHub Actions بعد. لذلك لا تُسجّل اختبارات الحارس وAppBadge وDocStatusBadge و`stateful_shell_route_preservation_test.dart` على أنها ناجحة؛ حالة اختبار route preservation: لم يُتحقق من تشغيله. لا يوجد تحقق بصري على المتصفح أو أجهزة فعلية.

## حالة التشغيل

تُسجّل نتيجة كل أمر فقط بعد تشغيله فعلياً في بيئة Dart/Flutter أو في GitHub Actions. وجود الاختبار في المستودع لا يعني نجاح تشغيله.


## تغطية Catalog UI — 2026-11-19

| المكوّن | الاختبار | التغطية المكتوبة | حالة التشغيل |
|---|---|---|---|
| C04 SearchableDropdown | `test/core/presentation/widgets/app_searchable_dropdown_test.dart` | بحث محلي واختيار، remote debounce وتحديث نتائج desktop/mobile، BottomSheet للجوال، error وdisabled، رسالة no-results مرة واحدة، تحديث قائمة جديدة بالمحتوى نفسه مع الحفاظ على query/focus، رجوع النص المكتوب إلى القيمة المختارة عند فقدان التركيز وتحرير الاستعلام، زر المسح (يظهر/يختفي/clearable)، إتاحة «إضافة جديد» عند انعدام النتائج، قراءة فقط مقابل معطّل، دلالات زر الهاتف (تسمية+قيمة+نقر)، تحرير الاستعلام بعد إغلاق الورقة، عروض 360/600/900/1200 وRTL/LTR وLight/Dark وTextScaler=2 | مكتوب؛ لم يُشغّل في هذه المراجعة |
| C10 FilterBar | `test/core/presentation/widgets/app_filter_bar_test.dart` | debounce، إزالة/مسح المرشحات عبر AppBadge قابل للإزالة، namedArgs لاسم/قيمة المرشح، محرر desktop inline وmobile BottomSheet، عروض 360/600/900/1200 وRTL/LTR وLight/Dark وTextScaler=2 | مكتوب؛ لم يُشغّل في هذه المراجعة |
| C01 DataTable | `test/core/presentation/widgets/app_data_table_test.dart` | بطاقات/مضغوط/كامل (تحقق من بطاقات AppCard وعناوين الأعمدة لكل عرض بمفاتيح اختبار مستقلة)، sort/page/pageSize callbacks، فرز الهاتف عبر BottomSheet، mobile load more، selection، retry/loading/empty، عروض 360/600/900/1200 وRTL/LTR وLight/Dark وTextScaler=2 | مكتوب؛ لم يُشغّل في هذه المراجعة |
| T1 ListPageTemplate | `test/core/presentation/widgets/list_page_template_test.dart` | تكامل PageHeader/FilterBar/DataTable وحالات loading/empty/error؛ مصدر واحد لرسالة الخطأ وRetry، عروض 360/600/900/1200 وRTL/LTR وLight/Dark وTextScaler=2 | مكتوب؛ لم يُشغّل في هذه المراجعة |

نتيجة GitHub Actions للدفعة: `dart format --set-exit-if-changed .` فشل؛ Analyze وTest تم تخطيهما. لم يُشغّل Flutter محلياً. لا توجد نتيجة نجاح موثقة لهذه الاختبارات.


### مراجعة جودة Catalog UI — 2026-11-19

أضيفت تغطية مكتوبة لتحديث خيارات C04 بقائمة جديدة مساوية في المحتوى مع التحقق من بقاء نص البحث والتركيز، وفرز C01 على الهاتف من BottomSheet، وملكية Retry واحدة في T1. هذه الاختبارات لم تُشغّل. لم تُنفذ dart format أو flutter analyze أو flutter test في هذه المهمة، لذلك لا توجد نتيجة تشغيل يمكن تسجيلها.


### إضافات إصلاحات المراجعة 2026-11-19

- app_text_field_test.dart (جديد): الافتراضيات، `readOnly` بمظهر فعّال مع `onTap`، و`enabled: false` حالة مختلفة.
- app_badge_test.dart: أضيفت مجموعة «removable badge» (استدعاء الإزالة، قراءة النص مرة واحدة وزر الإزالة عقدة مستقلة، مساحة اللمس >= 44 على الهاتف).
- app_data_table_test.dart وapp_searchable_dropdown_test.dart: أُزيل استعمال مفاتيح غير مرتبطة (search/filters/retry) لأسماء الأعمدة ورسائل الخطأ، واستُبدل `find.byType(Card), findsNothing` بتحقق من AppCard وعناوين الأعمدة.
- جميعها مكتوبة ولم تُشغّل (لا Flutter SDK في بيئة التنفيذ)؛ لا تُعد ناجحة قبل `flutter test`.


## تغطية AUTH-02 — 2026-11-19

- `test/routing/route_guards_test.dart`: يختبر أولوية علامة فرض كلمة المرور على اختيار الفرع، حصر المسارات في `/change-password`، والسماح بالانتقال بعد مسح العلامة إلى AUTH-03 أو AUTH-04، ورفض الوصول غير المصادق.
- `test/features/auth/session_cubit_test.dart`: قراءة العلامة من مصدرها، وإغلاق الجلسة عند فشل قراءة سياسة كلمة المرور.
- `test/features/auth/force_password_change_screen_test.dart`: إخفاء الحقلين افتراضياً، ظهور تسجيل الخروج، رفض كلمة دون الحد الأدنى، رفض عدم التطابق، حالة الحفظ، خطأ InlineBanner، ومقاسات 360/1200 في RTL/LTR.
- `test/features/auth/auth_endpoints_test.dart`: مسارا REST users وRPC complete_password_change.
- الاختبارات مكتوبة ولم تُشغّل. `dart format --set-exit-if-changed .` و`flutter analyze --no-fatal-infos` و`flutter test` غير منفذة لعدم توفر Flutter/Dart SDK؛ التحقق البصري على Chrome غير منفذ، وCI غير مفحوص. الحالة «مراجعة» وفق R12.
