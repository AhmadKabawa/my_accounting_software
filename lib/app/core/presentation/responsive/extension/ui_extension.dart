// ═══════════════════════════════════════════════════════════════════
// UI Extensions System
// نظام شامل لتسهيل الوصول للقيم responsive والـ design tokens
// استخدام: context.ui.padding.all, context.ui.size.width, إلخ
// ═══════════════════════════════════════════════════════════════════
export '../engine/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_gap.dart';
import 'package:accounting_software/app/core/presentation/responsive/helper/responsive_helper.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/theme/app_text_styles.dart';

part 'ui_extension/ui_helper.dart';
part 'ui_extension/direction_helper.dart';
part 'ui_extension/theme_helper.dart';
part 'ui_extension/padding_helper.dart';
part 'ui_extension/size_helper.dart';
part 'ui_extension/typography_helper.dart';
part 'ui_extension/spacing_helper.dart';
part 'ui_extension/radius_helper.dart';
part 'ui_extension/icon_helper.dart';
part 'ui_extension/elevation_helper.dart';
part 'ui_extension/grid_helper.dart';
part 'ui_extension/screen_helper.dart';
part 'ui_extension/app_text_style_resolver.dart';

// ═══════════════════════════════════════════════════════════════════
// MAIN EXTENSION على BuildContext
// ═══════════════════════════════════════════════════════════════════

extension UIContextExtension on BuildContext {
  /// الدخول الرئيسي لكل نظام UI
  /// استخدام: context.ui.padding.all(...), context.ui.spacing.md, إلخ
  UIHelper get ui => UIHelper(this);
}
