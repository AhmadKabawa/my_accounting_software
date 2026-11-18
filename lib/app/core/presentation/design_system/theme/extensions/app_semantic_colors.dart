import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_colors.dart';

/// لون نص (fg) وخلفيته (bg) لحالة واحدة: شارة حالة المستند مثلاً.
/// اللون وحده لا ينقل الحالة: تُرافقه أيقونة ونص دائماً.
@immutable
class StatusColor {
  const StatusColor({required this.foreground, required this.container});

  final Color foreground;
  final Color container;

  static StatusColor lerp(StatusColor a, StatusColor b, double t) =>
      StatusColor(
        foreground: Color.lerp(a.foreground, b.foreground, t)!,
        container: Color.lerp(a.container, b.container, t)!,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusColor &&
          foreground == other.foreground &&
          container == other.container;

  @override
  int get hashCode => Object.hash(foreground, container);
}

/// الألوان الخاصة بالتطبيق، وهي ليست جزءاً من [ColorScheme]:
///
/// - **دلالية:** success / warning / info بثلاثة أدوار لكل منها: اللون
///   (نص أو تعبئة)، ولون ما فوقه `onX` عند استعماله تعبئة (Snackbar)، وحاويته
///   `xContainer` للخلفيات الخفيفة (النص فوقها بلون `x`). الخطأ من
///   `ColorScheme.error` و`errorContainer`.
/// - **محاسبية:** [debit] و[credit] محايدان عمداً (ليس أحمر/أخضر)؛ يُرافقهما
///   دائماً وسم «مدين»/«دائن». [balanceNegative] مع علامة سالب صريحة.
/// - **حالات المستندات:** مسودة، معتمد، مرحَّل، ملغى، معكوس.
/// - **رسوم بيانية:** 8 سلاسل آمنة لعمى الألوان، تُستعمل بالترتيب.
/// - **أدوار محايدة بلا خانة في ColorScheme:** [onSurfaceMuted]، و[outlineStrong]،
///   و[focusRing].
///
/// الوصول من الواجهات: `context.ui.theme.semanticColors`.
/// يُسجَّل في الثيمين عبر `ThemeData(extensions: [...])` داخل `buildTheme`.
/// لا يعتمد هذا الملف على محرك Responsive (الثيم لا يعتمد عليه).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.debit,
    required this.credit,
    required this.balancePositive,
    required this.balanceNegative,
    required this.statusDraft,
    required this.statusApproved,
    required this.statusPosted,
    required this.statusCanceled,
    required this.statusReversed,
    required this.chart,
    required this.onSurfaceMuted,
    required this.outlineStrong,
    required this.focusRing,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;

  /// مدين: نص يُرافقه وسم «مدين» أو أيقونة.
  final Color debit;

  /// دائن: نص يُرافقه وسم «دائن» أو أيقونة.
  final Color credit;

  /// رصيد موجب: بلون النص العادي.
  final Color balancePositive;

  /// رصيد سالب: لون صدأ + علامة `−` صريحة.
  final Color balanceNegative;

  final StatusColor statusDraft;
  final StatusColor statusApproved;
  final StatusColor statusPosted;
  final StatusColor statusCanceled;
  final StatusColor statusReversed;

  /// سلاسل الرسوم البيانية بالترتيب. أكثر من 5 سلاسل تحتاج أنماط خطوط أو
  /// علامات إضافة إلى اللون. استعمل [chartColor].
  final List<Color> chart;

  /// نص مساعد وPlaceholder.
  final Color onSurfaceMuted;

  /// فاصل أو حدّ أقوى من `ColorScheme.outlineVariant`.
  final Color outlineStrong;

  /// حلقة التركيز (2px مع إزاحة 2).
  final Color focusRing;

  /// لون السلسلة [index] (يدور على 8 ألوان).
  Color chartColor(int index) => chart[index % chart.length];

  static const light = AppSemanticColors(
    success: AppLightColors.success,
    onSuccess: AppLightColors.onSuccess,
    successContainer: AppLightColors.successContainer,
    warning: AppLightColors.warning,
    onWarning: AppLightColors.onWarning,
    warningContainer: AppLightColors.warningContainer,
    info: AppLightColors.info,
    onInfo: AppLightColors.onInfo,
    infoContainer: AppLightColors.infoContainer,
    debit: AppLightColors.debit,
    credit: AppLightColors.credit,
    balancePositive: AppLightColors.balancePositive,
    balanceNegative: AppLightColors.balanceNegative,
    statusDraft: StatusColor(
      foreground: AppLightColors.statusDraft,
      container: AppLightColors.statusDraftContainer,
    ),
    statusApproved: StatusColor(
      foreground: AppLightColors.statusApproved,
      container: AppLightColors.statusApprovedContainer,
    ),
    statusPosted: StatusColor(
      foreground: AppLightColors.statusPosted,
      container: AppLightColors.statusPostedContainer,
    ),
    statusCanceled: StatusColor(
      foreground: AppLightColors.statusCanceled,
      container: AppLightColors.statusCanceledContainer,
    ),
    statusReversed: StatusColor(
      foreground: AppLightColors.statusReversed,
      container: AppLightColors.statusReversedContainer,
    ),
    chart: AppLightColors.chart,
    onSurfaceMuted: AppLightColors.onSurfaceMuted,
    outlineStrong: AppLightColors.outlineStrong,
    focusRing: AppLightColors.focusRing,
  );

  static const dark = AppSemanticColors(
    success: AppDarkColors.success,
    onSuccess: AppDarkColors.onSuccess,
    successContainer: AppDarkColors.successContainer,
    warning: AppDarkColors.warning,
    onWarning: AppDarkColors.onWarning,
    warningContainer: AppDarkColors.warningContainer,
    info: AppDarkColors.info,
    onInfo: AppDarkColors.onInfo,
    infoContainer: AppDarkColors.infoContainer,
    debit: AppDarkColors.debit,
    credit: AppDarkColors.credit,
    balancePositive: AppDarkColors.balancePositive,
    balanceNegative: AppDarkColors.balanceNegative,
    statusDraft: StatusColor(
      foreground: AppDarkColors.statusDraft,
      container: AppDarkColors.statusDraftContainer,
    ),
    statusApproved: StatusColor(
      foreground: AppDarkColors.statusApproved,
      container: AppDarkColors.statusApprovedContainer,
    ),
    statusPosted: StatusColor(
      foreground: AppDarkColors.statusPosted,
      container: AppDarkColors.statusPostedContainer,
    ),
    statusCanceled: StatusColor(
      foreground: AppDarkColors.statusCanceled,
      container: AppDarkColors.statusCanceledContainer,
    ),
    statusReversed: StatusColor(
      foreground: AppDarkColors.statusReversed,
      container: AppDarkColors.statusReversedContainer,
    ),
    chart: AppDarkColors.chart,
    onSurfaceMuted: AppDarkColors.onSurfaceMuted,
    outlineStrong: AppDarkColors.outlineStrong,
    focusRing: AppDarkColors.focusRing,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? debit,
    Color? credit,
    Color? balancePositive,
    Color? balanceNegative,
    StatusColor? statusDraft,
    StatusColor? statusApproved,
    StatusColor? statusPosted,
    StatusColor? statusCanceled,
    StatusColor? statusReversed,
    List<Color>? chart,
    Color? onSurfaceMuted,
    Color? outlineStrong,
    Color? focusRing,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      balancePositive: balancePositive ?? this.balancePositive,
      balanceNegative: balanceNegative ?? this.balanceNegative,
      statusDraft: statusDraft ?? this.statusDraft,
      statusApproved: statusApproved ?? this.statusApproved,
      statusPosted: statusPosted ?? this.statusPosted,
      statusCanceled: statusCanceled ?? this.statusCanceled,
      statusReversed: statusReversed ?? this.statusReversed,
      chart: chart ?? this.chart,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      outlineStrong: outlineStrong ?? this.outlineStrong,
      focusRing: focusRing ?? this.focusRing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSemanticColors &&
          success == other.success &&
          onSuccess == other.onSuccess &&
          successContainer == other.successContainer &&
          warning == other.warning &&
          onWarning == other.onWarning &&
          warningContainer == other.warningContainer &&
          info == other.info &&
          onInfo == other.onInfo &&
          infoContainer == other.infoContainer &&
          debit == other.debit &&
          credit == other.credit &&
          balancePositive == other.balancePositive &&
          balanceNegative == other.balanceNegative &&
          statusDraft == other.statusDraft &&
          statusApproved == other.statusApproved &&
          statusPosted == other.statusPosted &&
          statusCanceled == other.statusCanceled &&
          statusReversed == other.statusReversed &&
          listEquals(chart, other.chart) &&
          onSurfaceMuted == other.onSurfaceMuted &&
          outlineStrong == other.outlineStrong &&
          focusRing == other.focusRing;

  @override
  int get hashCode => Object.hashAll([
    success,
    onSuccess,
    successContainer,
    warning,
    onWarning,
    warningContainer,
    info,
    onInfo,
    infoContainer,
    debit,
    credit,
    balancePositive,
    balanceNegative,
    statusDraft,
    statusApproved,
    statusPosted,
    statusCanceled,
    statusReversed,
    Object.hashAll(chart),
    onSurfaceMuted,
    outlineStrong,
    focusRing,
  ]);

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      debit: Color.lerp(debit, other.debit, t)!,
      credit: Color.lerp(credit, other.credit, t)!,
      balancePositive: Color.lerp(balancePositive, other.balancePositive, t)!,
      balanceNegative: Color.lerp(balanceNegative, other.balanceNegative, t)!,
      statusDraft: StatusColor.lerp(statusDraft, other.statusDraft, t),
      statusApproved: StatusColor.lerp(statusApproved, other.statusApproved, t),
      statusPosted: StatusColor.lerp(statusPosted, other.statusPosted, t),
      statusCanceled: StatusColor.lerp(statusCanceled, other.statusCanceled, t),
      statusReversed: StatusColor.lerp(statusReversed, other.statusReversed, t),
      chart: [
        for (var i = 0; i < chart.length; i++)
          Color.lerp(chart[i], other.chart[i % other.chart.length], t)!,
      ],
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
    );
  }
}
