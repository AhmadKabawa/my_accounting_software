import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/theme/app_text_styles.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text_enum.dart';

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
