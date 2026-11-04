import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_colors.dart';

/// الألوان الدلالية الخاصة بالتطبيق، وهي ليست جزءاً من [ColorScheme].
///
/// الوصول من الواجهات: `context.ui.theme.semanticColors`.
/// يُسجَّل في الثيمين عبر `ThemeData(extensions: [...])` داخل `buildTheme`.
/// لا يعتمد هذا الملف على محرك Responsive (الثيم لا يعتمد عليه).
///
/// لون الخطأ: استخدم `ColorScheme.error`؛ لا يوجد خطأ دلالي منفصل حالياً.
/// القيم الخام تأتي من [AppColors]. قيم `debit` و`credit` PLACEHOLDER.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.debit,
    required this.credit,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  /// مدين (PLACEHOLDER بانتظار الهوية البصرية).
  final Color debit;

  /// دائن (PLACEHOLDER بانتظار الهوية البصرية).
  final Color credit;

  static const light = AppSemanticColors(
    success: AppColors.success,
    onSuccess: AppColors.white,
    warning: AppColors.warning,
    onWarning: AppColors.white,
    info: AppColors.info,
    onInfo: AppColors.white,
    debit: AppColors.debit,
    credit: AppColors.credit,
  );

  static const dark = AppSemanticColors(
    success: AppColors.successDark,
    onSuccess: AppColors.black,
    warning: AppColors.warningDark,
    onWarning: AppColors.black,
    info: AppColors.infoDark,
    onInfo: AppColors.black,
    debit: AppColors.debitDark,
    credit: AppColors.creditDark,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? debit,
    Color? credit,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      debit: Color.lerp(debit, other.debit, t)!,
      credit: Color.lerp(credit, other.credit, t)!,
    );
  }
}
