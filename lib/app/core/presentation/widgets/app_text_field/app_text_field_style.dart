import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_density_scope.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// Every visual value of `AppTextField`, resolved for the current context.
/// Reads tokens only (radius, spacing, text roles, icon sizes) so the field
/// scales with the screen exactly like `AppButton`.
class AppTextFieldStyle {
  const AppTextFieldStyle(this.context, {this.density});

  final BuildContext context;

  /// null = the density of the nearest `AppDensityScope`.
  final AppDensity? density;

  AppDensity get _density => density ?? AppDensityScope.of(context);

  /// The field height in compact density on a non-phone screen, else null.
  double? get _compactHeight =>
      AppDensityScope.compactHeight(context, _density);

  /// Dense layout is used only when compact density applies.
  bool get isDense => _compactHeight != null;

  static const _adaptive = ResponsiveMode.adaptiveOnly;

  ColorScheme get _scheme => Theme.of(context).colorScheme;

  BorderRadius get radius =>
      Rh.circularRadius(context, AppRadius.md, mode: _adaptive);

  EdgeInsets get contentPadding {
    final padding = Rh.symmetricPadding(
      context,
      horizontal: AppSpacing.md,
      vertical: AppSpacing.smMd,
      mode: _adaptive,
    );
    final target = _compactHeight;
    if (target == null) return padding;
    // Vertical padding that makes the field about [target] tall: the room left
    // around one line of text, split on both sides (never more than the
    // comfortable padding).
    final textStyle = this.textStyle;
    final line = (textStyle.fontSize ?? 0) * (textStyle.height ?? 1.2);
    final vertical = ((target - line) / 2).clamp(0.0, padding.top);
    return padding.copyWith(top: vertical, bottom: vertical);
  }

  double get iconSize => context.ui.icon.size(AppIconSize.md, mode: _adaptive);

  Color get iconColor => _scheme.onSurfaceVariant;

  Color get _focusRing => context.ui.theme.semanticColors.focusRing;

  TextStyle get textStyle => context.ui.text.of(AppTextType.bodyLarge);

  TextStyle get labelStyle => context.ui.text
      .of(AppTextType.bodyMedium)
      .copyWith(color: _scheme.onSurfaceVariant);

  TextStyle get floatingLabelStyle => context.ui.text
      .of(AppTextType.labelLarge)
      .copyWith(color: _scheme.onSurfaceVariant);

  TextStyle get errorStyle =>
      context.ui.text.of(AppTextType.bodySmall).copyWith(color: _scheme.error);

  OutlineInputBorder _border(Color color, {bool emphasized = false}) =>
      OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: color,
          width: (emphasized ? AppBorderWidth.thick : AppBorderWidth.thin).of(
            context,
          ),
        ),
      );

  /// The decoration for a labelled field. [prefix] / [suffix] are optional.
  InputDecoration decoration({
    required String label,
    String? hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    final disabled = _scheme.onSurface.withOpacity(0.12);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefix,
      suffixIcon: suffix,
      isDense: isDense,
      contentPadding: contentPadding,
      labelStyle: labelStyle,
      floatingLabelStyle: floatingLabelStyle,
      errorStyle: errorStyle,
      errorMaxLines: 3,
      border: _border(_scheme.outline),
      enabledBorder: _border(_scheme.outline),
      focusedBorder: _border(_focusRing, emphasized: true),
      errorBorder: _border(_scheme.error),
      focusedErrorBorder: _border(_scheme.error, emphasized: true),
      disabledBorder: _border(disabled),
    );
  }
}
