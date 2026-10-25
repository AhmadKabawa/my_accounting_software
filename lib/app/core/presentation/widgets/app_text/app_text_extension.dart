import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text_enum.dart';

extension AppTextTypeX on AppTextType {
  TextStyle resolve(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    switch (this) {
      case AppTextType.displayLarge:
        return textTheme.displayLarge!;

      case AppTextType.displayMedium:
        return textTheme.displayMedium!;

      case AppTextType.displaySmall:
        return textTheme.displaySmall!;

      case AppTextType.headlineLarge:
        return textTheme.headlineLarge!;

      case AppTextType.headlineMedium:
        return textTheme.headlineMedium!;

      case AppTextType.headlineSmall:
        return textTheme.headlineSmall!;

      case AppTextType.titleLarge:
        return textTheme.titleLarge!;

      case AppTextType.titleMedium:
        return textTheme.titleMedium!;

      case AppTextType.titleSmall:
        return textTheme.titleSmall!;

      case AppTextType.bodyLarge:
        return textTheme.bodyLarge!;

      case AppTextType.bodyMedium:
        return textTheme.bodyMedium!;

      case AppTextType.bodySmall:
        return textTheme.bodySmall!;

      case AppTextType.labelLarge:
        return textTheme.labelLarge!;

      case AppTextType.labelMedium:
        return textTheme.labelMedium!;

      case AppTextType.labelSmall:
        return textTheme.labelSmall!;
    }
  }
}
