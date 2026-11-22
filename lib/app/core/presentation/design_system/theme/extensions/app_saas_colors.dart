import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_colors.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_semantic_colors.dart';

/// مصدر واحد لشكل لوحة الإدارة (SaaS): تعديل قيمة هنا أو في `app_colors.dart`
/// يغيّر الشكل كله دون المساس بالمكوّنات.
///
/// - [canvas] خلفية الصفحة، و[surface] البطاقة الرئيسية التي تضم الأدوات
///   والفلاتر والبيانات (تساوي `ColorScheme.surface`، وتُعاد هنا لتُقرأ من
///   مكان واحد مع بقية التوكنات).
/// - [tableHeaderBand] و[onTableHeader] شريط رأس الجدول ونصه.
/// - [tableZebra] و[tableRowHover] تظليل الصفوف.
/// - [selected] و[onSelected] عنصر التنقل النشط (لون العلامة).
/// - حبات الحالة الخمس ([pillSuccess] ...): نص + خلفية هادئة تعمل في الفاتح
///   والداكن. اللون وحده لا ينقل الحالة؛ يُرافقه نص صريح دائماً.
///
/// لا يعتمد هذا الملف على محرك Responsive (الثيم مستقل عنه).
@immutable
class AppSaasColors extends ThemeExtension<AppSaasColors> {
  const AppSaasColors({
    required this.canvas,
    required this.surface,
    required this.tableHeaderBand,
    required this.onTableHeader,
    required this.tableZebra,
    required this.tableRowHover,
    required this.selected,
    required this.onSelected,
    required this.pillSuccess,
    required this.pillError,
    required this.pillWarning,
    required this.pillInfo,
    required this.pillNeutral,
  });

  final Color canvas;
  final Color surface;
  final Color tableHeaderBand;
  final Color onTableHeader;
  final Color tableZebra;
  final Color tableRowHover;
  final Color selected;
  final Color onSelected;
  final StatusColor pillSuccess;
  final StatusColor pillError;
  final StatusColor pillWarning;
  final StatusColor pillInfo;
  final StatusColor pillNeutral;

  static const light = AppSaasColors(
    canvas: AppLightColors.canvas,
    surface: AppLightColors.surface,
    tableHeaderBand: AppLightColors.tableHeaderBand,
    onTableHeader: AppLightColors.onTableHeader,
    tableZebra: AppLightColors.tableZebra,
    tableRowHover: AppLightColors.tableRowHover,
    selected: AppLightColors.selected,
    onSelected: AppLightColors.onSelected,
    pillSuccess: StatusColor(
      foreground: AppLightColors.success,
      container: AppLightColors.successContainer,
    ),
    pillError: StatusColor(
      foreground: AppLightColors.error,
      container: AppLightColors.errorContainer,
    ),
    pillWarning: StatusColor(
      foreground: AppLightColors.warning,
      container: AppLightColors.warningContainer,
    ),
    pillInfo: StatusColor(
      foreground: AppLightColors.info,
      container: AppLightColors.infoContainer,
    ),
    pillNeutral: StatusColor(
      foreground: AppLightColors.statusDraft,
      container: AppLightColors.statusDraftContainer,
    ),
  );

  static const dark = AppSaasColors(
    canvas: AppDarkColors.canvas,
    surface: AppDarkColors.surface,
    tableHeaderBand: AppDarkColors.tableHeaderBand,
    onTableHeader: AppDarkColors.onTableHeader,
    tableZebra: AppDarkColors.tableZebra,
    tableRowHover: AppDarkColors.tableRowHover,
    selected: AppDarkColors.selected,
    onSelected: AppDarkColors.onSelected,
    pillSuccess: StatusColor(
      foreground: AppDarkColors.success,
      container: AppDarkColors.successContainer,
    ),
    pillError: StatusColor(
      foreground: AppDarkColors.error,
      container: AppDarkColors.errorContainer,
    ),
    pillWarning: StatusColor(
      foreground: AppDarkColors.warning,
      container: AppDarkColors.warningContainer,
    ),
    pillInfo: StatusColor(
      foreground: AppDarkColors.info,
      container: AppDarkColors.infoContainer,
    ),
    pillNeutral: StatusColor(
      foreground: AppDarkColors.statusDraft,
      container: AppDarkColors.statusDraftContainer,
    ),
  );

  @override
  AppSaasColors copyWith({
    Color? canvas,
    Color? surface,
    Color? tableHeaderBand,
    Color? onTableHeader,
    Color? tableZebra,
    Color? tableRowHover,
    Color? selected,
    Color? onSelected,
    StatusColor? pillSuccess,
    StatusColor? pillError,
    StatusColor? pillWarning,
    StatusColor? pillInfo,
    StatusColor? pillNeutral,
  }) => AppSaasColors(
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    tableHeaderBand: tableHeaderBand ?? this.tableHeaderBand,
    onTableHeader: onTableHeader ?? this.onTableHeader,
    tableZebra: tableZebra ?? this.tableZebra,
    tableRowHover: tableRowHover ?? this.tableRowHover,
    selected: selected ?? this.selected,
    onSelected: onSelected ?? this.onSelected,
    pillSuccess: pillSuccess ?? this.pillSuccess,
    pillError: pillError ?? this.pillError,
    pillWarning: pillWarning ?? this.pillWarning,
    pillInfo: pillInfo ?? this.pillInfo,
    pillNeutral: pillNeutral ?? this.pillNeutral,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSaasColors &&
          canvas == other.canvas &&
          surface == other.surface &&
          tableHeaderBand == other.tableHeaderBand &&
          onTableHeader == other.onTableHeader &&
          tableZebra == other.tableZebra &&
          tableRowHover == other.tableRowHover &&
          selected == other.selected &&
          onSelected == other.onSelected &&
          pillSuccess == other.pillSuccess &&
          pillError == other.pillError &&
          pillWarning == other.pillWarning &&
          pillInfo == other.pillInfo &&
          pillNeutral == other.pillNeutral;

  @override
  int get hashCode => Object.hash(
    canvas,
    surface,
    tableHeaderBand,
    onTableHeader,
    tableZebra,
    tableRowHover,
    selected,
    onSelected,
    pillSuccess,
    pillError,
    pillWarning,
    pillInfo,
    pillNeutral,
  );

  @override
  AppSaasColors lerp(ThemeExtension<AppSaasColors>? other, double t) {
    if (other is! AppSaasColors) return this;
    return AppSaasColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      tableHeaderBand: Color.lerp(tableHeaderBand, other.tableHeaderBand, t)!,
      onTableHeader: Color.lerp(onTableHeader, other.onTableHeader, t)!,
      tableZebra: Color.lerp(tableZebra, other.tableZebra, t)!,
      tableRowHover: Color.lerp(tableRowHover, other.tableRowHover, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      onSelected: Color.lerp(onSelected, other.onSelected, t)!,
      pillSuccess: StatusColor.lerp(pillSuccess, other.pillSuccess, t),
      pillError: StatusColor.lerp(pillError, other.pillError, t),
      pillWarning: StatusColor.lerp(pillWarning, other.pillWarning, t),
      pillInfo: StatusColor.lerp(pillInfo, other.pillInfo, t),
      pillNeutral: StatusColor.lerp(pillNeutral, other.pillNeutral, t),
    );
  }
}
