part of '../ui_extension.dart';

// ═══════════════════════════════════════════════════════════════════
// AppTextType — the single set of text roles for UI.
// Lives in design_system so context.ui.text.of(...) can use it without
// design_system depending on widgets. `widgets/app_text/app_text_enum.dart`
// and `app_text_extension.dart` re-export it for compatibility.
// ═══════════════════════════════════════════════════════════════════

enum AppTextType {
  displayLarge,
  displayMedium,
  displaySmall,

  headlineLarge,
  headlineMedium,
  headlineSmall,

  titleLarge,
  titleMedium,
  titleSmall,

  bodyLarge,
  bodyMedium,
  bodySmall,

  labelLarge,
  labelMedium,
  labelSmall,

  /// Button labels (the theme has no text role for them, so no theme color).
  buttonText,
  buttonTextSmall,
}

extension AppTextTypeX on AppTextType {
  /// The token description of this type (size, clamp range, weight).
  AppTextStyle get descriptor => switch (this) {
    AppTextType.displayLarge => AppTextStyles.displayLarge,
    AppTextType.displayMedium => AppTextStyles.displayMedium,
    AppTextType.displaySmall => AppTextStyles.displaySmall,
    AppTextType.headlineLarge => AppTextStyles.headlineLarge,
    AppTextType.headlineMedium => AppTextStyles.headlineMedium,
    AppTextType.headlineSmall => AppTextStyles.headlineSmall,
    AppTextType.titleLarge => AppTextStyles.titleLarge,
    AppTextType.titleMedium => AppTextStyles.titleMedium,
    AppTextType.titleSmall => AppTextStyles.titleSmall,
    AppTextType.bodyLarge => AppTextStyles.bodyLarge,
    AppTextType.bodyMedium => AppTextStyles.bodyMedium,
    AppTextType.bodySmall => AppTextStyles.bodySmall,
    AppTextType.labelLarge => AppTextStyles.labelLarge,
    AppTextType.labelMedium => AppTextStyles.labelMedium,
    AppTextType.labelSmall => AppTextStyles.labelSmall,
    AppTextType.buttonText => AppTextStyles.buttonText,
    AppTextType.buttonTextSmall => AppTextStyles.buttonTextSmall,
  };

  /// The color the theme gives this type (it differs per type and between
  /// Light / Dark), so it is read from the theme instead of being repeated.
  Color? _themeColor(TextTheme textTheme) {
    final TextStyle? themeStyle = switch (this) {
      AppTextType.displayLarge => textTheme.displayLarge,
      AppTextType.displayMedium => textTheme.displayMedium,
      AppTextType.displaySmall => textTheme.displaySmall,
      AppTextType.headlineLarge => textTheme.headlineLarge,
      AppTextType.headlineMedium => textTheme.headlineMedium,
      AppTextType.headlineSmall => textTheme.headlineSmall,
      AppTextType.titleLarge => textTheme.titleLarge,
      AppTextType.titleMedium => textTheme.titleMedium,
      AppTextType.titleSmall => textTheme.titleSmall,
      AppTextType.bodyLarge => textTheme.bodyLarge,
      AppTextType.bodyMedium => textTheme.bodyMedium,
      AppTextType.bodySmall => textTheme.bodySmall,
      AppTextType.labelLarge => textTheme.labelLarge,
      AppTextType.labelMedium => textTheme.labelMedium,
      AppTextType.labelSmall => textTheme.labelSmall,
      // No theme role: the caller (e.g. AppButton) supplies the color.
      AppTextType.buttonText || AppTextType.buttonTextSmall => null,
    };
    return themeStyle?.color;
  }

  /// The responsive style for the screen under [context]. [mode] overrides the
  /// descriptor's own [ResponsiveMode].
  TextStyle resolve(BuildContext context, {ResponsiveMode? mode}) =>
      descriptor
          .resolve(context, mode: mode)
          .copyWith(color: _themeColor(Theme.of(context).textTheme));
}
