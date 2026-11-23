# قياس أسطر presentation — المهمة 3-ب

تم قياس ملفات Dart في مجلدي presentation للميزتين على الفرع قبل تطبيق التغييرات، ثم حُدّث عدد السطرين للملفين اللذين تغيرا. العدّ مأخوذ من محتوى الملفات في GitHub بعد استبعاد سطر النهاية الفارغ؛ لم يُشغّل أمر wc -l محلياً لأن بيئة التنفيذ لا تحتوي نسخة عمل للمستودع.

| الميزة | الملف النسبي داخل presentation | قبل | بعد |
|---|---|---:|---:|
| brands | cubit/brand_form/brand_form_cubit.dart | 54 | 54 |
| brands | cubit/brand_form/brand_form_effect.dart | 18 | 18 |
| brands | cubit/brand_logo_upload/brand_logo_upload_cubit.dart | 64 | 64 |
| brands | cubit/brand_logo_upload/brand_logo_upload_state.dart | 48 | 48 |
| brands | cubit/brand_stats/brand_stats_cubit.dart | 39 | 39 |
| brands | cubit/brand_stats/brand_stats_state.dart | 55 | 55 |
| brands | cubit/brands_list/brands_list_cubit.dart | 123 | 123 |
| brands | cubit/brands_list/brands_list_effect.dart | 21 | 21 |
| brands | cubit/brands_list/brands_list_state.dart | 6 | 6 |
| brands | dialogs/brand_editor_dialog.dart | 250 | 250 |
| brands | localization/brands_keys.dart | 127 | 127 |
| brands | pages/brands_screen.dart | 292 | 241 |
| brands | routing/brands_routes.dart | 6 | 6 |
| brands | sections/brand_details_section.dart | 25 | 25 |
| brands | sections/brand_identity_section.dart | 67 | 67 |
| brands | sections/brand_logo_section.dart | 93 | 93 |
| brands | sections/brands_table_section.dart | 164 | 164 |
| brands | widgets/brand_card.dart | 38 | 38 |
| brands | widgets/brand_field_validators.dart | 35 | 35 |
| brands | widgets/brand_grid_tile.dart | 39 | 39 |
| brands | widgets/brand_logo.dart | 84 | 84 |
| brands | widgets/brand_stats_bar.dart | 56 | 56 |
| brands | widgets/brand_status_badge.dart | 35 | 35 |
| brands | widgets/brands_filter_bar.dart | 110 | 110 |
| colors | cubit/color_form/color_form_cubit.dart | 54 | 54 |
| colors | cubit/color_form/color_form_effect.dart | 18 | 18 |
| colors | cubit/color_stats/color_stats_cubit.dart | 36 | 36 |
| colors | cubit/color_stats/color_stats_state.dart | 31 | 31 |
| colors | cubit/colors_list/colors_list_cubit.dart | 119 | 119 |
| colors | cubit/colors_list/colors_list_effect.dart | 11 | 11 |
| colors | dialogs/color_editor_dialog.dart | 240 | 240 |
| colors | localization/colors_keys.dart | 127 | 127 |
| colors | pages/colors_screen.dart | 275 | 227 |
| colors | routing/colors_routes.dart | 6 | 6 |
| colors | sections/color_appearance_section.dart | 97 | 97 |
| colors | sections/color_identity_section.dart | 79 | 79 |
| colors | sections/color_stats_section.dart | 76 | 76 |
| colors | sections/colors_table_section.dart | 176 | 176 |
| colors | widgets/color_field_validators.dart | 53 | 53 |
| colors | widgets/color_identity.dart | 21 | 21 |
| colors | widgets/color_presets.dart | 20 | 20 |
| colors | widgets/color_status_badge.dart | 16 | 16 |
| colors | widgets/colors_filter_bar.dart | 96 | 96 |

| الإجمالي | Brands | 1849 | 1798 |
| الإجمالي | Colors | 1551 | 1503 |

نسبة Colors إلى Brands: قبل 83.9%، وبعد 83.6%. الهدف ≤70% لم يتحقق بعد؛ التكرار المحدد في الشاشة نُقل إلى Core، لكن بقيت أجزاء عرض خاصة بكل ميزة.

عدد الملفات: Brands 24، Colors 19.
