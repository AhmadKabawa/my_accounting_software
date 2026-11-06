import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// Every visual value of `AppTextField`, resolved for the current context.
/// Reads tokens only (radius, spacing, text roles, icon sizes) so the field
/// scales with the screen exactly like `AppButton`.
class AppTextFieldStyle {
  const AppTextFieldStyle(this.context);

  final BuildContext context;

  static const _adaptive = ResponsiveMode.adaptiveOnly;
  static const _borderWidth = 1.0;
  static const _focusedBorderWidth = 2.0;

  ColorScheme get _scheme => Theme.of(context).colorScheme;

  BorderRadius get radius =>
      Rh.circularRadius(context, AppRadius.md, mode: _adaptive);

  EdgeInsets get contentPadding => Rh.symmetricPadding(
    context,
    horizontal: AppSpacing.md,
    vertical: AppSpacing.smMd,
    mode: _adaptive,
  );

  double get iconSize => context.ui.icon.size(AppIconSize.md, mode: _adaptive);

  Color get iconColor => _scheme.onSurfaceVariant;

  TextStyle get textStyle => context.ui.text.of(AppTextType.bodyLarge);

  TextStyle get labelStyle => context.ui.text
      .of(AppTextType.bodyMedium)
      .copyWith(color: _scheme.onSurfaceVariant);

  TextStyle get floatingLabelStyle => context.ui.text
      .of(AppTextType.labelLarge)
      .copyWith(color: _scheme.onSurfaceVariant);

  TextStyle get errorStyle =>
      context.ui.text.of(AppTextType.bodySmall).copyWith(color: _scheme.error);

  OutlineInputBorder _border(Color color, {double width = _borderWidth}) =>
      OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
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
      contentPadding: contentPadding,
      labelStyle: labelStyle,
      floatingLabelStyle: floatingLabelStyle,
      errorStyle: errorStyle,
      errorMaxLines: 3,
      border: _border(_scheme.outline),
      enabledBorder: _border(_scheme.outline),
      focusedBorder: _border(_scheme.primary, width: _focusedBorderWidth),
      errorBorder: _border(_scheme.error),
      focusedErrorBorder: _border(_scheme.error, width: _focusedBorderWidth),
      disabledBorder: _border(disabled),
    );
  }
}
