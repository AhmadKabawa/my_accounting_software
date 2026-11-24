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
| C04 SearchableDropdown | `test/core/presentation/widgets/app_searchable_dropdown_test.dart` | بحث محلي واختيار، remote debounce وتحديث نتائج desktop/mobile (بما فيها تحديث اللوحة المفتوحة مع الحفاظ على query/focus)، BottomSheet للجوال، error وdisabled، رسالة no-results مرة واحدة، تحديث قائمة جديدة بالمحتوى نفسه مع الحفاظ على query/focus، رجوع النص المكتوب إلى القيمة المختارة عند فقدان التركيز وتحرير الاستعلام، زر المسح (يظهر/يختفي/clearable)، إتاحة «إضافة جديد» عند انعدام النتائج، قراءة فقط مقابل معطّل، دلالات زر الهاتف (تسمية+قيمة+نقر)، تحرير الاستعلام بعد إغلاق الورقة، عروض 360/600/900/1200 وRTL/LTR وLight/Dark وTextScaler=2 | اجتاز ضمن `flutter test --no-pub` بتاريخ 2026-11-20 |
| C10 FilterBar | `test/core/presentation/widgets/app_filter_bar_test.dart` | debounce، إزالة/مسح المرشحات عبر AppBadge قابل للإزالة، namedArgs لاسم/قيمة المرشح، محرر desktop inline وmobile BottomSheet، عروض 360/600/900/1200 وRTL/LTR وLight/Dark وTextScaler=2 | اجتاز ضمن `flutter test --no-pub` بتاريخ 2026-11-20 |
| C01 DataTable | `test/core/presentation/widgets/app_data_table_test.dart` | بطاقات/مضغوط/كامل (تحقق من بطاقات AppCard وعناوين الأعمدة لكل عرض بمفاتيح اختبار مستقلة)، sort/page/pageSize callbacks، فرز الهاتف عبر BottomSheet، mobile load more، selection، retry/loading/empty، عروض 360/600/900/1200 وRTL/LTR وLight/Dark وTextScaler=2 | اجتاز ضمن `flutter test --no-pub` بتاريخ 2026-11-20 |
| AppPageBody + تمرير الصفحة | `test/core/presentation/widgets/app_page_body_test.dart` | الحشوة، العرض الأقصى المركزي، تمرير الصفحة كلها (رأس+جدول) عند 360 و1200، وبقاء التمرير الداخلي للجدول عند ارتفاع محدود | اجتاز ضمن `flutter test --no-pub` بتاريخ 2026-11-20 |
| T1 ListPageTemplate | `test/core/presentation/widgets/list_page_template_test.dart` | تكامل PageHeader/FilterBar/DataTable وحالات loading/empty/error؛ مصدر واحد لرسالة الخطأ وRetry، عروض 360/600/900/1200 وRTL/LTR وLight/Dark وTextScaler=2 | اجتاز ضمن `flutter test --no-pub` بتاريخ 2026-11-20 |

نتيجة هذا التحقق المحلي: `flutter analyze --no-fatal-infos --no-pub` اجتاز مع ملاحظات `info` غير مانعة، و`flutter test --no-pub` اجتاز (750 اختباراً)، وفحص تنسيق الملفات المعدّلة اجتاز. أما فشل التنسيق القديم في GitHub Actions فيبقى سجلاً تاريخياً.


### مراجعة جودة Catalog UI — 2026-11-19

أضيفت تغطية مكتوبة لتحديث خيارات C04 بقائمة جديدة مساوية في المحتوى مع التحقق من بقاء نص البحث والتركيز، وفرز C01 على الهاتف من BottomSheet، وملكية Retry واحدة في T1. هذه الاختبارات لم تُشغّل. لم تُنفذ dart format أو flutter analyze أو flutter test في هذه المهمة، لذلك لا توجد نتيجة تشغيل يمكن تسجيلها.


### إضافات إصلاحات المراجعة 2026-11-19

- app_text_field_test.dart (جديد): الافتراضيات، `readOnly` بمظهر فعّال مع `onTap`، و`enabled: false` حالة مختلفة.
- app_badge_test.dart: أضيفت مجموعة «removable badge» (استدعاء الإزالة، قراءة النص مرة واحدة وزر الإزالة عقدة مستقلة، مساحة اللمس >= 44 على الهاتف).
- app_data_table_test.dart وapp_searchable_dropdown_test.dart: أُزيل استعمال مفاتيح غير مرتبطة (search/filters/retry) لأسماء الأعمدة ورسائل الخطأ، واستُبدل `find.byType(Card), findsNothing` بتحقق من AppCard وعناوين الأعمدة.
- جميعها مكتوبة ولم تُشغّل (لا Flutter SDK في بيئة التنفيذ)؛ لا تُعد ناجحة قبل `flutter test`.


## تغطية AUTH-02 — 2026-11-19

- `test/routing/route_guards_test.dart`: يختبر أولوية علامة فرض كلمة المرور على اختيار الفرع، حصر المسارات في `/change-password`، والسماح بالانتقال بعد مسح العلامة إلى AUTH-03 أو AUTH-04، ورفض الوصول غير المصادق.
- `test/features/auth/session_cubit_test.dart`: قراءة العلامة من مصدرها، وإغلاق الجلسة عند فشل قراءة سياسة كلمة المرور. `test/features/auth/session_access_integration_test.dart`: انتظار إعادة تحميل الصلاحيات قبل تحرير حارس AUTH-02.
- `test/features/auth/force_password_change_screen_test.dart`: إخفاء الحقلين افتراضياً، ظهور تسجيل الخروج، رفض كلمة دون الحد الأدنى، رفض عدم التطابق، حالة الحفظ، خطأ InlineBanner، ومقاسات 360/1200 في RTL/LTR.
- `test/features/auth/auth_endpoints_test.dart`: مسارا REST users وRPC complete_password_change.
- **نتيجة التشغيل الفعلية:** اختبارات AUTH-02 في هذا القسم ناجحة في [GitHub Actions](https://github.com/AhmadKabawa/my_accounting_software/actions/runs/44651692540): route guards، session، integration لإعادة تحميل الصلاحيات، وWidget النموذج. شُغّل formatter على 22 ملف Dart خاصاً بـ AUTH-02 (19 تغيّرت). فحص التنسيق الشامل ما زال يفشل في ملفين موروثين من AUTH-04 (`access_status_gate.dart` و`dashboard_screen_test.dart`). `flutter analyze` شُغّل ولا توجد أخطاء في ملفات AUTH-02، لكنه يفشل بسبب أخطاء اختبار موروثة في access/dashboard/shell. `flutter test` شُغّل: 639 ناجحاً و9 فاشلة في اختبارات shell/access/home وAppBadge/SearchableDropdown؛ مجموعات الإخفاق نفسها موجودة في [تشغيل فرع AUTH-04 الأساسي](https://github.com/AhmadKabawa/my_accounting_software/actions/runs/44647274723). Catalog UI: 36 ناجحاً وواحد فاشل. Chrome visual check لم يُنفذ. الحالة «مراجعة» وفق R12، ولا تُسجل الميزة منجزة حتى تُحل موانع الأساس وتكتمل المراجعة البصرية.

## تحديث: مكوّنات S2

- `test/core/presentation/widgets/app_row_actions_test.dart`: أيقونات فقط، قائمة «المزيد».
- `app_filter_bar_test.dart`: زر x، شريحة البحث، نص الشريحة بلا متغيرات.
- `app_searchable_dropdown_test.dart`: إعادة الفتح بعد الاختيار تعرض كل الخيارات.
- `app_data_table_test.dart`: نص الترقيم بلا `@`/`{`.
- `test/architecture/ui_quality_gate_test.dart`: بوابة جودة الواجهة (P-06..P-10).


## تغطية مكونات UX Foundation (هذه المجموعة) — تحديث 2026-11-22

- `app_searchable_dropdown_test.dart`: اختبار إعادة الخلل لاختيار «الكل» مع بقاء التركيز، autocomplete القديم، ونمط `panel` على desktop والهاتف: فتح/اختيار/إعادة فتح/اختيار آخر، «الكل» و✓، إغلاق الاختيار، البحث ثم الإغلاق وإعادة الفتح باستعلام فارغ، ArrowUp/ArrowDown/Enter/Esc، وحالة لا نتائج. الاختبار التمهيدي أضيف قبل إصلاح callback؛ لم يُشغّل في بيئة التعديل (Flutter SDK غير متاح)، ونتيجته `NOT_VERIFIED` حتى التشغيل المحلي.
- `brands_filter_bar_test.dart` و`colors_filter_bar_test.dart`: ربط البحث وتغيير الحالة إلى inactive، وتمثيل البحث والحالة النشطين كشرائح قابلة للإزالة. تدفق المصدر: FilterBar يرسل البحث فوراً، وBrandsListCubit/ColorsListCubit يملكان debounce (300ms)؛ تغيير الحالة يستدعي setStatus ثم load، ومسح الكل يعيد البحث والحالة والصفحة. لم يُشغّل.
- `app_filter_bar_test.dart`: مسح البحث، إزالة شريحة البحث، مسح الكل، تخطيط responsive، محرر الهاتف/سطح المكتب.
- `app_color_picker_test.dart`: null، HEX صالح/غير صالح، حفظ alpha عند السحب، إدخال RGB يدوي مع الحفاظ على alpha الحالي، إدخال RGBA صريح، الحفاظ على alpha عند اختيار preset، تجاهل preset غير صالح، واختيار preset صالح ومزامنة قيمة خارجية. لم يُشغّل.
- `app_icon_tone_test.dart`: يثبت ربط كل AppIconTone بدور ColorScheme أو AppSemanticColors الموافق في light/dark؛ `test/architecture/icon_tone_test.dart` يمنع تمرير `color:` مباشرة إلى AppIcon داخل Features، ويقارن المخالفات مع `_knownDebt` التي يجب أن تتقلص. قائمة الدين في الاختبار الجديد فارغة؛ لم يُشغّل.
- `test/core/foundation/color_name_resolver_test.dart`: يثبت `#228B22` = forestGreen (أخضر غامق)، `#F57C21` = orange، و`#05AD9D` = turquoise، إضافة إلى RGB/RGBA والمدخلات غير الصالحة؛ لم يُشغّل.
- **حالة التحقق لهذه المجموعة:** أضيفت الاختبارات والتعديلات فقط. `dart format`, `flutter analyze` و`flutter test` لم تُشغّل من بيئة التعديل لعدم توفر Flutter SDK. نتائج التشغيل السابقة التي أرسلها المستخدم محفوظة في المحادثة ولا تثبت نجاح الكود بعد هذه التعديلات.

## اختبارات توحيد الواجهات (لم تُشغَّل بعد — لا Flutter في بيئة التنفيذ)

`app_saas_colors_test`، `app_data_view_test` (مصفوفة العرض)، `app_filter_bar_test`، `list_page_template_test`، `app_stat_card_test`، `app_row_actions_test`، `message_view_widgets_test`، `test/shell/app_shell_windows_sidebar_test`، اختبارات الماركات (الاستعلام، الإحصاءات، الفلاتر، الشاشة).
فجوات: اختبار شجرة «المزيد» على الهاتف، واختبار صلاحيات الشجرة في الشريط الجانبي، ولقطات Golden.


## Shared CRUD list widgets — 2026-11-22

- `test/core/presentation/widgets/list_stats_bar_test.dart`: card counts 1–6 at widths 360/600/1200, equal widths, no full-row singleton, and loading placeholders preserving count.
- `test/core/presentation/widgets/crud_empty_state_test.dart`: empty/no-results copy, optional create action, callback, and denied-permission visibility.
- These tests were added in this change; they have not been run in a Flutter environment. Treat their runtime status as NOT_VERIFIED until the specified Flutter commands pass.


## Paged list state management — 2026-11-22

- `test/core/presentation/state_management/paged_list/paged_list_cubit_test.dart`: stale request protection (including search invalidation), close safety, 300ms debounce and timer cancellation on load/clear/close, page no-op behavior, refresh failure retention, initial failure, both page-two delete recovery paths, and deletion flash-before-effect ordering.
- `test/features/catalog/brands/presentation/cubit/brands_cubit_test.dart`: existing list lifecycle and mutation coverage plus public `setStatus` / `setSorts` behavior and deletion rejection for unknown/in-use product counts.
- The tests were added but not run in the repository environment for this change. Verify with the commands in the task report.

## Shared CRUD list additions — 2026-11-22

- test/core/presentation/widgets/app_filter_bar_test.dart covers all available sort options, duplicate-field disabling, visible conflict guidance, direction preservation when changing a field, priority reordering, and the wide AppDropdownMenu nesting path.
- test/core/presentation/widgets/app_data_view_responsive_test.dart covers card-shaped loading placeholders for narrow content on a wide viewport; list_page_template_test.dart covers the same fallback in the page template.
- test/core/presentation/widgets/app_bulk_action_bar_test.dart covers icon-only compact actions at 280 logical pixels.
- test/core/presentation/state_management/paged_list/paged_list_bulk_test.dart verifies success-only flash delivery and no flash on partial/complete failure (the result dialog owns failure reporting).
- New query tests test/features/catalog/brands/domain/entity/brand_list_query_test.dart and test/features/catalog/colors/domain/entity/color_list_query_test.dart verify every criterion is preserved in priority order.
- These tests and dart format/flutter analyze/flutter test have not been run in this environment (Flutter/Dart SDK unavailable). Runtime status: NOT_VERIFIED.

- test/core/presentation/state_management/paged_list/paged_list_cubit_test.dart additionally verifies that the delete-success flash is emitted immediately after the successful mutation response, before the subsequent list refresh completes. This distinguishes a successful delete from a later refresh failure.

## Platform capabilities

- `test/core/platform/platform_capabilities_test.dart` verifies the native/VM send-timeout capability and the layout-only collapsible-sidebar capability. The browser adapter's `false` send-timeout value is selected by conditional import; it still requires the web CI build for runtime verification.
- These tests were added in the current change and have not been executed yet. Runtime status: NOT_VERIFIED.


## CRUD list engine and catalog adoption — 2026-11-24

| المكوّن | الاختبار | التغطية المكتوبة | حالة التشغيل |
|---|---|---|---|
| `CrudListScreen` / `CrudListConfig` | `test/core/presentation/widgets/crud_list/crud_list_screen_test.dart` | تحميل/فشل/إعادة المحاولة، الاحتفاظ بالبيانات، effects وتحديث الإحصاءات، slots الاختيارية، `extraToolbarActions` و`extraBulkActions`، `showCount` إظهاراً وإخفاءً، تدفقات الإضافة/التعديل/الحذف والحالة، وتصفير التحديد عند تبديل العرض. يتضمن fixture صغيراً يستخدم `PagedListCubit` و`CrudDataSection`. | تُسجّل بعد اكتمال CI الخاص بالمراجعة الحالية؛ وجود الاختبار وحده لا يثبت نجاحه. |
| `CrudDataSection` | `test/core/presentation/widgets/crud_list/crud_data_section_test.dart` | table/cards/grid، عمود الحالة وحالة الانشغال، الإجراء الإضافي في صف السجل مع بقاء edit/delete، empty/no-results، RTL بعرض 280 وTextScale 1.5. | تُسجّل بعد اكتمال CI الخاص بالمراجعة الحالية؛ وجود الاختبار وحده لا يثبت نجاحه. |
| Brands + Colors engine integration | `test/features/catalog/crud_list_screens_matrix_test.dart` إضافة إلى اختبارات الشاشة الحالية | كل أوضاع العرض الثلاثة للشاشتين عند 280 logical px، RTL، TextScale 1.5؛ فحص استثناءات Flutter بعد كل وضع. | تُسجّل بعد اكتمال CI الخاص بالمراجعة الحالية؛ وجود الاختبار وحده لا يثبت نجاحه. |

لا يشمل اختبار Widget بديلاً عن الفحص اليدوي على هاتف ومتصفح فعلي. يجب فحص التحديد الجماعي، مسح التحديد عند تغيير الوضع، تحديث الإحصاءات بعد mutations، عروض 280–360 والحاسوب، وRTL بصرياً.
